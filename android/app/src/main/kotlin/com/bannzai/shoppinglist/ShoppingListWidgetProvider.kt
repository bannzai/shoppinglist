package com.bannzai.shoppinglist

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ShoppingListWidgetProvider : HomeWidgetProvider() {
    companion object {
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
                        Intent(context, ShoppingListWidgetToggleReceiver::class.java).apply {
                            action = ShoppingListWidgetToggleReceiver.ACTION_TOGGLE_ITEM
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
