import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list_item.freezed.dart';
part 'group_shopping_list_item.g.dart';

abstract class GroupShoppingListItemFirestoreKeys {
  static const id = 'id';
  static const userID = 'userID';
  static const status = 'status';
  static const order = 'order';
  static const createdDateTime = 'createdDateTime';
  static const updatedDateTime = 'updatedDateTime';
  static const serverCreatedDateTime = 'serverCreatedDateTime';
  static const serverUpdatedDateTime = 'serverUpdatedDateTime';
}

/// [GroupShoppingList] 内の個別の買い物アイテムを表すエンティティ。
///
/// [GroupCategory] によるカテゴリ自動分類の対象となる。
/// チェック状態（[GroupShoppingListItemStatus]）で買い物済みかどうかを管理する。
///
/// ## ユースケース
/// - ユーザーが買い物リストにアイテムを追加する
/// - 買い物中にアイテムをチェックして購入済みにする
@freezed
abstract class GroupShoppingListItem with _$GroupShoppingListItem {
  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListItem({
    required String id,
    required String groupID,
    required String shoppingListID,
    required String userID,
    required String message,
    // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
    // NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
    required int order,
    @Default(GroupShoppingListItemStatus.unchecked)
    GroupShoppingListItemStatus status,
    String? description,
    String? color,
    @NullableTimestampConverter() DateTime? reminderDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingListItem;

  factory GroupShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListItemFromJson(json);

  static GroupShoppingListItem fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupShoppingListItem.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupShoppingListItem item, SetOptions? options) =>
      item.toJson();
}

extension GroupShoppingListItems on List<GroupShoppingListItem> {
  int get nextOrder => (lastOrNull?.order ?? -1) + 1;
}

/// [GroupShoppingListItem] のチェック状態。
enum GroupShoppingListItemStatus {
  @JsonValue('checked')
  checked,
  @JsonValue('unchecked')
  unchecked,
}
