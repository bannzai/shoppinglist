import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/store_review_request.dart';

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

  /// チェック (未チェック → チェック) の書き込みが完了した後に呼ぶ。
  /// チェックボックスのタップと右スワイプの両方がこの class を通るため、
  /// 「買った」の回数はここで数える (Issue #651)。
  final RequestStoreReviewOnPurchasedItemCheck
  requestStoreReviewOnPurchasedItemCheck;

  ToggleShoppingListItemCheck({
    required this.database,
    required this.requestStoreReviewOnPurchasedItemCheck,
  });

  /// [item] のチェック状態をトグルする。
  ///
  /// entity 全体を `set(..., merge: true)` で書き戻すのではなく、変更するフィールドだけを
  /// `.update({...})` で部分更新する。チェックは「チェック状態だけを変える」操作であり、
  /// build 後に別端末や詳細シートで message / description / imageURL / order 等が更新されて
  /// いると、build 時点の古い entity 全体を書き戻して並行編集を巻き戻してしまうため
  /// (create_list_spotlight 対応時の codex レビュー指摘)。
  ///
  /// `.claude/rules/firestore-fieldvalue-rules.md` は set + copyWith + merge への統一を
  /// 推奨するが、それは FieldValue.delete 回避と null 扱いを一貫させる文脈のもの。ここは
  /// フィールド削除を含まず、並行編集の巻き戻し防止を優先するため部分更新にしている。
  /// タイムスタンプは `.claude/rules/firestore-timestamp-rules.md` に従い
  /// updatedDateTime / serverUpdatedDateTime を serverTimestamp で付与する。
  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String userID,
  }) async {
    final isChecking = item.status == GroupShoppingListItemStatus.unchecked;
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc(item.id)
        .update({
          GroupShoppingListItemFirestoreKeys.status:
              (isChecking
                      ? GroupShoppingListItemStatus.checked
                      : GroupShoppingListItemStatus.unchecked)
                  .name,
          // チェック時のみ checkedByUserID / lastCheckedDateTime を書く。チェック解除時は
          // lastCheckedDateTime をクリアしない(create_list_spotlight の条件2 が「最後に
          // チェックした時刻」を見るため既存挙動を維持する)。
          if (isChecking) ...{
            GroupShoppingListItemFirestoreKeys.checkedByUserID: userID,
            GroupShoppingListItemFirestoreKeys
                .lastCheckedDateTime: Timestamp.fromDate(DateTime.now()),
          },
          GroupShoppingListItemFirestoreKeys.updatedDateTime:
              FieldValue.serverTimestamp(),
          GroupShoppingListItemFirestoreKeys.serverUpdatedDateTime:
              FieldValue.serverTimestamp(),
        });
    // 書き込みが失敗したチェックは数えないよう update の後に呼ぶ。
    if (isChecking) {
      await requestStoreReviewOnPurchasedItemCheck.call();
    }
  }
}

@Riverpod(dependencies: [groupDatabase, requestStoreReviewOnPurchasedItemCheck])
ToggleShoppingListItemCheck toggleShoppingListItemCheck(
  Ref ref, {
  required String groupID,
}) {
  return ToggleShoppingListItemCheck(
    database: ref.watch(groupDatabaseProvider(groupID: groupID)),
    requestStoreReviewOnPurchasedItemCheck: ref.watch(
      requestStoreReviewOnPurchasedItemCheckProvider,
    ),
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
    final batch = firestore.batch();

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
