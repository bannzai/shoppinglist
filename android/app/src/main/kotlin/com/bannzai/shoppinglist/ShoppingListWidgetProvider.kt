package com.bannzai.shoppinglist

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import es.antonborri.home_widget.HomeWidgetProvider

class ShoppingListWidgetProvider : HomeWidgetProvider() {
    companion object {
        const val ACTION_TOGGLE_ITEM = "com.bannzai.shoppinglist.ACTION_TOGGLE_ITEM"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_TOGGLE_ITEM) {
            val groupID = intent.getStringExtra("groupID") ?: return
            val shoppingListID = intent.getStringExtra("shoppingListID") ?: return
            val itemID = intent.getStringExtra("itemID") ?: return
            val currentStatus = intent.getStringExtra("currentStatus") ?: return
            toggleItemStatus(context, groupID, shoppingListID, itemID, currentStatus)
        } else {
            super.onReceive(context, intent)
        }
    }

    private fun toggleItemStatus(context: Context, groupID: String, shoppingListID: String, itemID: String, currentStatus: String) {
        FirebaseApp.initializeApp(context)
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            updateLocalCache(context, groupID, shoppingListID, itemID, currentStatus)
            return
        }
        val newStatus = if (currentStatus == "checked") "unchecked" else "checked"
        val pendingResult = goAsync()

        FirebaseFirestore.getInstance()
            .collection("groups/$groupID/shoppingLists/$shoppingListID/items")
            .document(itemID)
            .set(mapOf(
                "status" to newStatus,
                "updatedDateTime" to FieldValue.serverTimestamp(),
                "serverUpdatedDateTime" to FieldValue.serverTimestamp()
            ), SetOptions.merge())
            .addOnCompleteListener {
                updateLocalCache(context, groupID, shoppingListID, itemID, currentStatus)
                pendingResult.finish()
            }
    }

    private fun updateLocalCache(context: Context, groupID: String, shoppingListID: String, itemID: String, currentStatus: String) {
        val newStatus = if (currentStatus == "checked") "unchecked" else "checked"
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
        } catch (_: Exception) {}

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

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.shopping_list_widget)

            val shoppingListName = widgetData.getString("widget_current_shopping_list_name", "買い物リスト") ?: "買い物リスト"
            views.setTextViewText(R.id.widget_title, shoppingListName)

            val groupID = widgetData.getString("widget_current_group_id", "") ?: ""
            val shoppingListID = widgetData.getString("widget_current_shopping_list_id", "") ?: ""
            val key = "widget_items_${groupID}_${shoppingListID}"
            val itemsJson = widgetData.getString(key, "[]") ?: "[]"

            try {
                val items = org.json.JSONArray(itemsJson)
                val itemCount = minOf(items.length(), 10)

                for (i in 0 until itemCount) {
                    val item = items.getJSONObject(i)
                    val itemId = item.getString("id")
                    val message = item.getString("message")
                    val status = item.getString("status")
                    val isChecked = status == "checked"

                    val toggleIntent = PendingIntent.getBroadcast(
                        context,
                        itemId.hashCode(),
                        Intent(context, ShoppingListWidgetProvider::class.java).apply {
                            action = ACTION_TOGGLE_ITEM
                            putExtra("groupID", groupID)
                            putExtra("shoppingListID", shoppingListID)
                            putExtra("itemID", itemId)
                            putExtra("currentStatus", status)
                        },
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    if (i == 0) {
                        views.setTextViewText(R.id.item_text_0, message)
                        views.setTextViewText(R.id.item_check_0, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_0, android.view.View.VISIBLE)
                        views.setOnClickPendingIntent(R.id.item_row_0, toggleIntent)
                    }
                    if (i == 1) {
                        views.setTextViewText(R.id.item_text_1, message)
                        views.setTextViewText(R.id.item_check_1, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_1, android.view.View.VISIBLE)
                        views.setOnClickPendingIntent(R.id.item_row_1, toggleIntent)
                    }
                    if (i == 2) {
                        views.setTextViewText(R.id.item_text_2, message)
                        views.setTextViewText(R.id.item_check_2, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_2, android.view.View.VISIBLE)
                        views.setOnClickPendingIntent(R.id.item_row_2, toggleIntent)
                    }
                    if (i == 3) {
                        views.setTextViewText(R.id.item_text_3, message)
                        views.setTextViewText(R.id.item_check_3, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_3, android.view.View.VISIBLE)
                        views.setOnClickPendingIntent(R.id.item_row_3, toggleIntent)
                    }
                    if (i == 4) {
                        views.setTextViewText(R.id.item_text_4, message)
                        views.setTextViewText(R.id.item_check_4, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_4, android.view.View.VISIBLE)
                        views.setOnClickPendingIntent(R.id.item_row_4, toggleIntent)
                    }
                }

                // 未使用の行を非表示
                for (i in itemCount until 5) {
                    val rowId = when (i) {
                        0 -> R.id.item_row_0
                        1 -> R.id.item_row_1
                        2 -> R.id.item_row_2
                        3 -> R.id.item_row_3
                        4 -> R.id.item_row_4
                        else -> continue
                    }
                    views.setViewVisibility(rowId, android.view.View.GONE)
                }
            } catch (e: Exception) {
                // JSON解析エラー時は空表示
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
