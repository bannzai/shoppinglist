import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';
import 'package:shoppinglist/utils/config/app_identity.dart' as app_identity;
import 'package:shoppinglist/utils/development/debug.dart';
import 'package:shoppinglist/utils/firebase_app_check/firebase_app_check.dart';
import 'package:shoppinglist/utils/firebase_emulator/firebase_emulator.dart';

@pragma('vm:entry-point')
FutureOr<void> homeWidgetBackgroundCallback(Uri? uri) async {
  // この callback は main() と別 entry-point の isolate で動くため、
  // debugPrint の差し替え (isolate ごとのグローバル変数) をここでも行う。
  overrideDebugPrint();
  if (uri?.host == 'toggle-item') {
    final groupID = uri!.queryParameters['groupID']!;
    final shoppingListID = uri.queryParameters['shoppingListID']!;
    final itemID = uri.queryParameters['itemID']!;
    final currentStatus = uri.queryParameters['currentStatus']!;

    await Firebase.initializeApp();
    // この callback は main() と別 entry-point の isolate で動くため、
    // App Check の有効化と Emulator 接続 (isolate ごとの設定) をここでも行う。
    await activateAppCheck();
    await connectFirebaseEmulatorIfEnabled();
    await FirebaseAuth.instance.setSettings(
      userAccessGroup: app_identity.keychainAccessGroup,
    );
    await HomeWidget.setAppGroupId(HomeWidgetDataSync.appGroupId);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[homeWidgetBackgroundCallback] user is null, skipping');
      return;
    }

    final newStatus =
        currentStatus == 'checked'
            ? GroupShoppingListItemStatus.unchecked
            : GroupShoppingListItemStatus.checked;

    final docRef = firestore
        .collection('/groups/$groupID/shoppingLists/$shoppingListID/items')
        .doc(itemID);
    await docRef.set({'status': newStatus.name}, SetOptions(merge: true));

    // SharedStorage のローカルデータも更新
    final key = 'widget_items_${groupID}_$shoppingListID';
    final existingData = await HomeWidget.getWidgetData<String>(key);
    if (existingData != null) {
      final List<dynamic> items = jsonDecode(existingData);
      final updatedItems =
          items.map((item) {
            if (item['id'] == itemID) {
              return {...item, 'status': newStatus.name};
            }
            return item;
          }).toList();
      await HomeWidget.saveWidgetData(key, jsonEncode(updatedItems));
    }

    await HomeWidgetDataSync.updateWidget();
    debugPrint(
      '[homeWidgetBackgroundCallback] toggled item $itemID to ${newStatus.name}',
    );
  }
}
