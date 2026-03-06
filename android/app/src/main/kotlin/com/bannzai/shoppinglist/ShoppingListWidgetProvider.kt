package com.bannzai.shoppinglist

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ShoppingListWidgetProvider : HomeWidgetProvider() {
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

                    if (i == 0) {
                        views.setTextViewText(R.id.item_text_0, message)
                        views.setTextViewText(R.id.item_check_0, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_0, android.view.View.VISIBLE)
                        val intent0 = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("shoppinglist://toggle-item?groupID=$groupID&shoppingListID=$shoppingListID&itemID=$itemId&currentStatus=$status")
                        )
                        views.setOnClickPendingIntent(R.id.item_row_0, intent0)
                    }
                    if (i == 1) {
                        views.setTextViewText(R.id.item_text_1, message)
                        views.setTextViewText(R.id.item_check_1, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_1, android.view.View.VISIBLE)
                        val intent1 = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("shoppinglist://toggle-item?groupID=$groupID&shoppingListID=$shoppingListID&itemID=$itemId&currentStatus=$status")
                        )
                        views.setOnClickPendingIntent(R.id.item_row_1, intent1)
                    }
                    if (i == 2) {
                        views.setTextViewText(R.id.item_text_2, message)
                        views.setTextViewText(R.id.item_check_2, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_2, android.view.View.VISIBLE)
                        val intent2 = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("shoppinglist://toggle-item?groupID=$groupID&shoppingListID=$shoppingListID&itemID=$itemId&currentStatus=$status")
                        )
                        views.setOnClickPendingIntent(R.id.item_row_2, intent2)
                    }
                    if (i == 3) {
                        views.setTextViewText(R.id.item_text_3, message)
                        views.setTextViewText(R.id.item_check_3, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_3, android.view.View.VISIBLE)
                        val intent3 = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("shoppinglist://toggle-item?groupID=$groupID&shoppingListID=$shoppingListID&itemID=$itemId&currentStatus=$status")
                        )
                        views.setOnClickPendingIntent(R.id.item_row_3, intent3)
                    }
                    if (i == 4) {
                        views.setTextViewText(R.id.item_text_4, message)
                        views.setTextViewText(R.id.item_check_4, if (isChecked) "\u2611" else "\u2610")
                        views.setViewVisibility(R.id.item_row_4, android.view.View.VISIBLE)
                        val intent4 = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("shoppinglist://toggle-item?groupID=$groupID&shoppingListID=$shoppingListID&itemID=$itemId&currentStatus=$status")
                        )
                        views.setOnClickPendingIntent(R.id.item_row_4, intent4)
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
