import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list.g.dart';
part 'group_shopping_list.freezed.dart';

/// 無料ユーザーのグループあたりアクティブリスト数上限。
const int freeGroupActiveShoppingListLimit = 5;

abstract class GroupShoppingListFirestoreKeys {
  static const createdDateTime = 'createdDateTime';
  static const status = 'status';
}

/// [Group] 内の買い物リストを表すエンティティ。
///
/// 複数の [GroupShoppingListItem] を含み、任意で [GroupShoppingLocation]（買い物場所）を
/// 紐づけることができる。過去のリストを複製して新しいリストを作成する機能もある。
///
/// ## ユースケース
/// - ユーザーが新しい買い物リストを作成し、アイテムを追加する
/// - 買い物完了後にステータスを [GroupShoppingListStatus.done] に変更する
/// - 過去のリストを複製して新しいリストを作成する
@freezed
abstract class GroupShoppingList with _$GroupShoppingList {
  const GroupShoppingList._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingList({
    required String id,
    required String createUserID,
    required String groupID,
    @Default('') String name,
    @Default(GroupShoppingListStatus.active) GroupShoppingListStatus status,

    /// このリストでのアイテム追加・チェック切替時にグループ全員へ通知 SnackBar を
    /// 表示するか。`design_handoff_shoppinglist/preview/screens-list-settings.jsx`
    /// 準拠でリスト単位の設定として持つ。
    /// グローバル通知設定 (SharedPreferences) と AND 条件で評価する。
    /// 既存ドキュメントにはこのフィールドが存在しないため default で `false` を返す。
    @Default(false) bool autoNotifyEnabled,
    String? shoppingLocationID,
    String? duplicatedFromGroupShoppingListID,
    @TimestampConverter() required DateTime? ttlExpiresDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingList;

  factory GroupShoppingList.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListFromJson(json);

  static GroupShoppingList fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupShoppingList.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupShoppingList shoppingList, SetOptions? options) =>
      shoppingList.toJson();
}

/// [GroupShoppingList] のステータス。
enum GroupShoppingListStatus {
  @JsonValue('active')
  active,
  @JsonValue('done')
  done,
  @JsonValue('archived')
  archived,
}
