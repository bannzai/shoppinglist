import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_item.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListItem>> textShoppingListItems(Ref ref,
    {required String groupID,
    required String shoppingListID,
    required bool showChecked}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  Query<GroupShoppingListItem> query =
      database.shoppingListItemsReference(shoppingListID: shoppingListID);
  if (!showChecked) {
    query = query.where(GroupShoppingListItemFirestoreKeys.status,
        isEqualTo: GroupShoppingListItemStatus.unchecked.name);
  }
  return query
      .orderBy(GroupShoppingListItemFirestoreKeys.order, descending: false)
      .snapshots()
      .map((event) {
    final items = event.docs.map((doc) => doc.data()).toList();
    debugPrint(
        '[textShoppingListItems] Stream データ取得: アイテム数=${items.length}, showChecked=$showChecked, shoppingListID=$shoppingListID');
    return items;
  });
}

class AddShoppingListItem {
  final GroupDatabase database;

  AddShoppingListItem({required this.database});

  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String message,
    required int order,
    required String? groupShoppingListItemCategoryID,
    required String? description,
    required String? color,
  }) async {
    debugPrint(
        '[AddShoppingListItem] 書き込み前: shoppingListID=$shoppingListID, order=$order, groupID=${database.groupID}');
    final docRef = database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc();
    final item = GroupShoppingListItem(
        id: docRef.id,
        groupID: database.groupID,
        shoppingListID: shoppingListID,
        message: message,
        order: order,
        groupShoppingListItemCategoryID: groupShoppingListItemCategoryID,
        description: description,
        color: color);
    await docRef.set(item, SetOptions(merge: true));
    debugPrint('[AddShoppingListItem] 書き込み完了: docRef.id=${docRef.id}');
    return item;
  }
}

@Riverpod(dependencies: [groupDatabase])
AddShoppingListItem addShoppingListItem(Ref ref, {required String groupID}) {
  return AddShoppingListItem(
      database: ref.watch(groupDatabaseProvider(groupID: groupID)));
}

class ShoppingListItemBatchUpdate {
  final GroupDatabase database;

  ShoppingListItemBatchUpdate({required this.database});

  Future<void> call({
    required String shoppingListID,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in shoppingListItems) {
      final docRef = database
          .shoppingListItemsReference(shoppingListID: shoppingListID)
          .doc(item.id);
      batch.set(docRef, item, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListItemBatchUpdate shoppingListItemBatchUpdate(Ref ref,
    {required String groupID}) {
  return ShoppingListItemBatchUpdate(
      database: ref.watch(groupDatabaseProvider(groupID: groupID)));
}
