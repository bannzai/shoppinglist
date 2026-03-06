import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';

class HomeWidgetDataSync {
  static const appGroupId = 'group.com.bannzai.shoppinglist';
  static const iOSWidgetName = 'ShoppingListWidget';
  static const androidWidgetName = 'ShoppingListWidgetProvider';

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
