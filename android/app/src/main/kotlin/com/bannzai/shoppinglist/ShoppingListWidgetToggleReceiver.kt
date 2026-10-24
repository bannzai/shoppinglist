package com.bannzai.shoppinglist

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore

/**
 * ウィジェットの行タップでアイテムのチェック状態を切り替える receiver。
 * APPWIDGET_UPDATE を受けるために export が必要な ShoppingListWidgetProvider と分け、
 * manifest で android:exported="false" にして同じアプリの PendingIntent からだけ届くようにしている。
 */
class ShoppingListWidgetToggleReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_TOGGLE_ITEM = "com.bannzai.shoppinglist.ACTION_TOGGLE_ITEM"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TOGGLE_ITEM) return
        val itemID = intent.getStringExtra("itemID") ?: return
        val currentStatus = intent.getStringExtra("currentStatus") ?: return

        // 書き込み先はウィジェットが表示している現在のリストに固定し、そのリストのキャッシュに無いアイテムは書かない
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val groupID = prefs.getString("widget_current_group_id", "") ?: ""
        val shoppingListID = prefs.getString("widget_current_shopping_list_id", "") ?: ""
        if (groupID.isEmpty() || shoppingListID.isEmpty()) return
        if (!isWidgetCachedItem(itemsJson = prefs.getString("widget_items_${groupID}_${shoppingListID}", "[]") ?: "[]", itemID = itemID)) return

        toggleItemStatus(context, groupID, shoppingListID, itemID, currentStatus)
    }

    private fun toggleItemStatus(context: Context, groupID: String, shoppingListID: String, itemID: String, currentStatus: String) {
        val newStatus = if (currentStatus == "checked") "unchecked" else "checked"
        FirebaseApp.initializeApp(context)
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            updateLocalCache(context, groupID, shoppingListID, itemID, newStatus)
            return
        }
        val pendingResult = goAsync()

        // update は文書が無ければ失敗するため、存在しないアイテム文書を作らない
        FirebaseFirestore.getInstance()
            .collection("groups/$groupID/shoppingLists/$shoppingListID/items")
            .document(itemID)
            .update(mapOf(
                "status" to newStatus,
                "updatedDateTime" to FieldValue.serverTimestamp(),
                "serverUpdatedDateTime" to FieldValue.serverTimestamp()
            ))
            .addOnCompleteListener {
                updateLocalCache(context, groupID, shoppingListID, itemID, newStatus)
                pendingResult.finish()
            }
    }

    private fun updateLocalCache(context: Context, groupID: String, shoppingListID: String, itemID: String, newStatus: String) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val key = "widget_items_${groupID}_${shoppingListID}"
        val itemsJson = prefs.getString(key, "[]") ?: "[]"
        try {
            val items = org.json.JSONArray(itemsJson)
            for (i in 0 until items.length()) {
                val item = items.getJSONObject(i)
                if (item.getString("id") == itemID) {
                    item.put("status", newStatus)
                    break
                }
            }
            prefs.edit().putString(key, items.toString()).apply()
        } catch (e: Exception) { e.printStackTrace() }

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(context, ShoppingListWidgetProvider::class.java)
        )
        val updateIntent = Intent(context, ShoppingListWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
        }
        context.sendBroadcast(updateIntent)
    }
}

/**
 * ウィジェットのアイテムキャッシュ (Flutter 側 home_widget_data_sync.dart が保存する JSON 配列) に itemID が含まれるかを返す。
 * JSON を解析できない時は含まれないものとして false を返す。
 */
fun isWidgetCachedItem(itemsJson: String, itemID: String): Boolean {
    return try {
        val items = org.json.JSONArray(itemsJson)
        (0 until items.length()).any { items.getJSONObject(it).optString("id") == itemID }
    } catch (e: org.json.JSONException) {
        false
    }
}
