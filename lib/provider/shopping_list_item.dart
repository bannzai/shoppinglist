import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_item.g.dart';

/// 買い物リストのアイテム一覧(チェック済み含む全件)を order 昇順で購読する。
@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListItem>> textShoppingListItems(
  Ref ref, {
  required String groupID,
  required String shoppingListID,
}) {
  return ref
      .watch(groupDatabaseProvider(groupID: groupID))
      .shoppingListItemsReference(shoppingListID: shoppingListID)
      .orderBy(GroupShoppingListItemFirestoreKeys.order, descending: false)
      .snapshots()
      .map((event) {
        final items = event.docs.map((doc) => doc.data()).toList();
        debugPrint(
          '[textShoppingListItems] Stream データ取得: アイテム数=${items.length}, shoppingListID=$shoppingListID',
        );
        return items;
      });
}

/// 表示中の買い物リストに対する「自分(ローカル端末)の編集」の累積回数を購読する。
///
/// Firestore snapshot の `metadata.hasPendingWrites` は、その snapshot に自分の端末からの
/// 未コミット書き込み(latency compensation)が含まれる時のみ true になる。他メンバーの編集が
/// 同期されてきた snapshot は false。これを使い「自分が変更した時だけ」家族へ通知を促すための
/// 単調増加カウンタを発行する。値が変わること自体が「ローカル編集が起きた」イベントを表す。
///
/// 追加/文言編集/チェック/解除/並び替え/削除のいずれも、自分の端末からの書き込みなら
/// hasPendingWrites=true の snapshot を伴うため、操作種別に依存せず一様に判別できる。
/// (アイテムの lastEditedByUserID 等は操作ごとに設定が不統一で、削除では残らないため使えない)。
///
/// 注: 累積カウンタのため count を加算する副作用を持ち冪等ではないが、これは「イベントの
/// 発生回数」を表現する Stream の本質的な状態であるため許容する。hasPendingWrites=true の
/// snapshot は必ずデータ変更を伴うため、includeMetadataChanges は不要。
@Riverpod(dependencies: [groupDatabase])
Stream<int> localShoppingListItemEditCount(
  Ref ref, {
  required String groupID,
  required String shoppingListID,
}) {
  var localEditCount = 0;
  return ref
      .watch(groupDatabaseProvider(groupID: groupID))
      .shoppingListItemsReference(shoppingListID: shoppingListID)
      .snapshots()
      .where((snapshot) => snapshot.metadata.hasPendingWrites)
      .map((_) => ++localEditCount);
}

class AddShoppingListItem {
  final GroupDatabase database;

  AddShoppingListItem({required this.database});

  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    debugPrint(
      '[AddShoppingListItem] 書き込み前: shoppingListID=$shoppingListID, order=$order, groupID=${database.groupID}',
    );
    final docRef =
        database
            .shoppingListItemsReference(shoppingListID: shoppingListID)
            .doc();
    final item = GroupShoppingListItem(
      id: docRef.id,
      groupID: database.groupID,
      shoppingListID: shoppingListID,
      userID: userID,
      message: message,
      order: order,
      description: description,
      color: color,
      checkedByUserID: null,
      imageURL: null,
      lastEditedByUserID: null,
    );
    await docRef.set(item, SetOptions(merge: true));
    debugPrint('[AddShoppingListItem] 書き込み完了: docRef.id=${docRef.id}');
    return item;
  }
}

@Riverpod(dependencies: [groupDatabase])
AddShoppingListItem addShoppingListItem(Ref ref, {required String groupID}) {
  return AddShoppingListItem(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
  );
}

/// 買い物リストアイテムを削除する。
///
/// スワイプ削除など、ユーザーの明示的な削除操作で使用する。
/// 削除前のアイテムを保持しておけば [RestoreShoppingListItem] で復元できる。
class DeleteShoppingListItem {
  final GroupDatabase database;

  DeleteShoppingListItem({required this.database});

  Future<void> call({
    required String shoppingListID,
    required String itemID,
  }) async {
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc(itemID)
        .delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
DeleteShoppingListItem deleteShoppingListItem(
  Ref ref, {
  required String groupID,
}) {
  return DeleteShoppingListItem(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
  );
}

/// 削除した買い物リストアイテムを、削除前の ID・内容のまま復元する。
///
/// スワイプ削除直後の「元に戻す」(Undo) 操作で使用する。
/// 削除前に保持していた [GroupShoppingListItem] を同じ ID で書き戻すため、
/// order・status・description などが削除前の状態のまま復元される。
class RestoreShoppingListItem {
  final GroupDatabase database;

  RestoreShoppingListItem({required this.database});

  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
  }) async {
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc(item.id)
        .set(item, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
RestoreShoppingListItem restoreShoppingListItem(
  Ref ref, {
  required String groupID,
}) {
  return RestoreShoppingListItem(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
  );
}

class ToggleShoppingListItemCheck {
  final GroupDatabase database;

  ToggleShoppingListItemCheck({required this.database});

  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String userID,
  }) async {
    final isChecking = item.status == GroupShoppingListItemStatus.unchecked;
    final updated =
        isChecking
            ? item.copyWith(
              status: GroupShoppingListItemStatus.checked,
              checkedByUserID: userID,
              lastCheckedDateTime: DateTime.now(),
            )
            : item.copyWith(status: GroupShoppingListItemStatus.unchecked);
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc(item.id)
        .set(updated, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
ToggleShoppingListItemCheck toggleShoppingListItemCheck(
  Ref ref, {
  required String groupID,
}) {
  return ToggleShoppingListItemCheck(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
  );
}

class UpdateShoppingListItem {
  final GroupDatabase database;

  UpdateShoppingListItem({required this.database});

  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String editedByUserID,
  }) async {
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc(item.id)
        .set(
          item.copyWith(
            lastEditedByUserID: editedByUserID,
            lastEditedDateTime: DateTime.now(),
          ),
          SetOptions(merge: true),
        );
  }
}

@Riverpod(dependencies: [groupDatabase])
UpdateShoppingListItem updateShoppingListItem(
  Ref ref, {
  required String groupID,
}) {
  return UpdateShoppingListItem(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
  );
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
ShoppingListItemBatchUpdate shoppingListItemBatchUpdate(
  Ref ref, {
  required String groupID,
}) {
  return ShoppingListItemBatchUpdate(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
  );
}
