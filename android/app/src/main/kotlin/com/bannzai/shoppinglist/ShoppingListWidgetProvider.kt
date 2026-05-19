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
        /** テーマカラーの16進カラーコードバリデーション用パターン */
        private val HEX_COLOR_PATTERN = Regex("^#([0-9A-F]{6}|[0-9A-F]{8})$")

        /** 5 色プリセット（朱 / 抹茶 / 藍 / 墨 / 朽葉）。Flutter 側 AccentPreset と同期させること。 */
        private val SUPPORTED_THEME_COLOR_HEXES = setOf(
            "#C2410C", // 朱
            "#1F6B4E", // 抹茶
            "#0F4C81", // 藍
            "#1B1B1B", // 墨
            "#B45309", // 朽葉
        )
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
        val newStatus = if (currentStatus == "checked") "unchecked" else "checked"
        FirebaseApp.initializeApp(context)
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            updateLocalCache(context, groupID, shoppingListID, itemID, newStatus)
            return
        }
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

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // 朱（5 色プリセットのデフォルト）。Flutter 側 AccentPreset.shu と一致。
        val defaultThemeColorHex = "#C2410C"
        val isPremium = widgetData.getBoolean("widget_is_premium", false)
        val rawThemeColorHex = widgetData.getString("widget_theme_color_hex", defaultThemeColorHex) ?: defaultThemeColorHex
        val normalizedHex = rawThemeColorHex.trim().uppercase()
        val themeColorHex = if (isPremium &&
            HEX_COLOR_PATTERN.matches(normalizedHex) &&
            SUPPORTED_THEME_COLOR_HEXES.contains(normalizedHex)
        ) {
            normalizedHex
        } else {
            defaultThemeColorHex
        }
        val themeColor = runCatching { android.graphics.Color.parseColor(themeColorHex) }
            .getOrDefault(android.graphics.Color.parseColor(defaultThemeColorHex))

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.shopping_list_widget)

            val shoppingListName = widgetData.getString("widget_current_shopping_list_name", "買い物リスト") ?: "買い物リスト"
            views.setTextViewText(R.id.widget_title, shoppingListName)
            views.setTextColor(R.id.widget_title, themeColor)

            val groupID = widgetData.getString("widget_current_group_id", "") ?: ""
            val shoppingListID = widgetData.getString("widget_current_shopping_list_id", "") ?: ""
            val key = "widget_items_${groupID}_${shoppingListID}"
            val itemsJson = widgetData.getString(key, "[]") ?: "[]"

            // done/total を mono count に反映（progress 状況用）。Flutter 側 home_widget_data_sync.dart と同期。
            val countKey = "${groupID}_${shoppingListID}"
            val doneCount = widgetData.getInt("widget_done_count_$countKey", 0)
            val totalCount = widgetData.getInt("widget_total_count_$countKey", 0)
            views.setTextViewText(R.id.widget_count, "${doneCount}/${totalCount}")
            views.setTextColor(R.id.widget_count, themeColor)

            val textIds = arrayOf(R.id.item_text_0, R.id.item_text_1, R.id.item_text_2, R.id.item_text_3, R.id.item_text_4)
            val checkIds = arrayOf(R.id.item_check_0, R.id.item_check_1, R.id.item_check_2, R.id.item_check_3, R.id.item_check_4)
            val rowIds = arrayOf(R.id.item_row_0, R.id.item_row_1, R.id.item_row_2, R.id.item_row_3, R.id.item_row_4)

            try {
                val items = org.json.JSONArray(itemsJson)
                val itemCount = minOf(items.length(), 5)

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

                    views.setTextViewText(textIds[i], message)
                    views.setTextViewText(checkIds[i], if (isChecked) "\u2611" else "\u2610")
                    views.setViewVisibility(rowIds[i], android.view.View.VISIBLE)
                    views.setOnClickPendingIntent(rowIds[i], toggleIntent)
                }

                // 未使用の行を非表示
                for (i in itemCount until 5) {
                    views.setViewVisibility(rowIds[i], android.view.View.GONE)
                }
            } catch (e: Exception) {
                // JSON解析エラー時は空表示
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
