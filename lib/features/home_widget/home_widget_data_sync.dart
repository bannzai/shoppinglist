import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';

class HomeWidgetDataSync {
  static const appGroupId = 'group.com.bannzai.shoppinglist';
  static const iOSWidgetName = 'ShoppingListWidget';
  static const androidWidgetName = 'ShoppingListWidgetProvider';

  static final _hexColorRegExp =
      RegExp(r'^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  /// 朱（5 色プリセットのデフォルト）。
  /// design_handoff_shopping_list の AccentPreset.shu と同じ値。
  static const _defaultThemeColorHex = '#C2410C';

  /// 5 色プリセット以外（旧 10 色や不正値）を朱に倒すための許可リスト。
  static const _supportedHexes = {
    '#C2410C', // 朱
    '#1F6B4E', // 抹茶
    '#0F4C81', // 藍
    '#1B1B1B', // 墨
    '#B45309', // 朽葉
  };

  /// HEX値を正規化する。フォーマット不正値・旧 10 色プリセット値は朱にフォールバックする。
  static String _normalizeThemeColorHex(String value) {
    final normalized = value.trim().toUpperCase();
    if (_hexColorRegExp.hasMatch(normalized) &&
        _supportedHexes.contains(normalized)) {
      return normalized;
    }
    return _defaultThemeColorHex;
  }

  /// ユーザーのテーマカラーHEXをウィジェットストレージに同期する。
  static Future<void> syncThemeColor({
    required String themeColorHex,
  }) async {
    await HomeWidget.saveWidgetData(
      'widget_theme_color_hex',
      _normalizeThemeColorHex(themeColorHex),
    );
    debugPrint('[HomeWidgetDataSync] syncThemeColor');
    await updateWidget();
  }

  /// プレミアム状態をウィジェットストレージに同期する。
  static Future<void> syncPremiumStatus({
    required bool isPremium,
  }) async {
    await HomeWidget.saveWidgetData('widget_is_premium', isPremium);
    debugPrint('[HomeWidgetDataSync] syncPremiumStatus');
    await updateWidget();
  }

  static Future<void> syncShoppingLists({
    required List<GroupShoppingList> shoppingLists,
    required String groupID,
    required String groupName,
  }) async {
    final listsJson = shoppingLists
        .map((sl) => {
              'id': sl.id,
              'name': sl.name,
              'groupID': sl.groupID,
              'groupName': groupName,
            })
        .toList();
    await HomeWidget.saveWidgetData(
      'widget_shopping_lists',
      jsonEncode(listsJson),
    );
    await HomeWidget.saveWidgetData('widget_current_group_id', groupID);
    debugPrint(
        '[HomeWidgetDataSync] syncShoppingLists: ${shoppingLists.length}件');
  }

  static Future<void> syncCurrentShoppingListItems({
    required String groupID,
    required String shoppingListID,
    required String shoppingListName,
    required List<GroupShoppingListItem> items,
  }) async {
    await HomeWidget.saveWidgetData(
        'widget_current_shopping_list_id', shoppingListID);
    await HomeWidget.saveWidgetData(
        'widget_current_shopping_list_name', shoppingListName);

    final itemsJson = items
        .map((item) => {
              'id': item.id,
              'groupID': item.groupID,
              'shoppingListID': item.shoppingListID,
              'message': item.message,
              'status': item.status.name,
              'order': item.order,
              'color': item.color,
            })
        .toList();
    final key = 'widget_items_${groupID}_$shoppingListID';
    await HomeWidget.saveWidgetData(key, jsonEncode(itemsJson));
    debugPrint(
        '[HomeWidgetDataSync] syncCurrentShoppingListItems: ${items.length}件, key=$key');
    await updateWidget();
  }

  static Future<void> updateWidget() async {
    await HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }
}
