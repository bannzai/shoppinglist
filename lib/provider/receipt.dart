import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group_shopping_list_receipt.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'receipt.g.dart';

/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListReceipt>> receipts(
  Ref ref, {
  required String groupID,
  required String shoppingListID,
}) {
  return ref
      .watch(groupDatabaseProvider(groupID: groupID))
      .receiptsReference(shoppingListID: shoppingListID)
      .orderBy(
        GroupShoppingListReceiptFirestoreKeys.createdDateTime,
        descending: true,
      )
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

/// 採番済みの receiptID でレシートドキュメントを新規作成する。
///
/// レシート画像のアップロード（[FirebaseFunctionsExt.uploadReceiptImage]）には
/// receiptID が先に必要なため、ID は呼び出し元が
/// [GroupDatabase.newReceiptReference] で採番して渡す。
class AddReceipt {
  final GroupDatabase database;

  AddReceipt({required this.database});

  Future<void> call({
    required String shoppingListID,
    required String receiptID,
    required String userID,
    required String? storagePath,
    required int? amount,
    required String? memo,
  }) async {
    await database
        .receiptReference(shoppingListID: shoppingListID, receiptID: receiptID)
        .set(
          GroupShoppingListReceipt(
            id: receiptID,
            groupID: database.groupID,
            shoppingListID: shoppingListID,
            userID: userID,
            storagePath: storagePath,
            amount: amount,
            memo: memo,
          ),
          SetOptions(merge: true),
        );
  }
}

@Riverpod(dependencies: [groupDatabase])
AddReceipt addReceipt(Ref ref, {required String groupID}) =>
    AddReceipt(database: ref.watch(groupDatabaseProvider(groupID: groupID)));

/// レシートの画像URL・金額・メモを更新する。
class UpdateReceipt {
  final GroupDatabase database;

  UpdateReceipt({required this.database});

  Future<void> call({required GroupShoppingListReceipt receipt}) async {
    await database
        .receiptReference(
          shoppingListID: receipt.shoppingListID,
          receiptID: receipt.id,
        )
        .set(receipt, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
UpdateReceipt updateReceipt(Ref ref, {required String groupID}) =>
    UpdateReceipt(database: ref.watch(groupDatabaseProvider(groupID: groupID)));
