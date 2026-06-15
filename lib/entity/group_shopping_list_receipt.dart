import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list_receipt.freezed.dart';
part 'group_shopping_list_receipt.g.dart';

/// Firestore 上のフィールド名定数。クエリの orderBy 等で使用する。
abstract class GroupShoppingListReceiptFirestoreKeys {
  static const createdDateTime = 'createdDateTime';
}

/// [GroupShoppingList] に紐づくレシート（買い物の領収書）を表すエンティティ。
///
/// レシート画像（Firebase Storage）と、金額・メモのメタデータを持つ。プレミアム機能。
/// 1つの買い物リストに複数枚登録できるサブコレクションのドキュメントで、
/// 親ドキュメントの ID（[groupID] / [shoppingListID]）をフィールドとして保持する。
@freezed
abstract class GroupShoppingListReceipt with _$GroupShoppingListReceipt {
  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListReceipt({
    required String id,
    required String groupID,
    required String shoppingListID,
    required String createUserID,

    /// Firebase Storage 上のレシート画像のダウンロードURL。
    required String? imageURL,

    /// レシートの金額（円・整数）。
    required int? amount,

    /// レシートに関するメモ。
    required String? memo,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingListReceipt;

  factory GroupShoppingListReceipt.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListReceiptFromJson(json);

  static GroupShoppingListReceipt fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      GroupShoppingListReceipt.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
    GroupShoppingListReceipt receipt,
    SetOptions? options,
  ) =>
      receipt.toJson();
}
