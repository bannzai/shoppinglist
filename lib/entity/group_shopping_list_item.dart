import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list_item.freezed.dart';
part 'group_shopping_list_item.g.dart';

abstract class GroupShoppingListItemFirestoreKeys {
  static const id = 'id';
  static const type = 'type';
  static const status = 'status';
  static const order = 'order';
  static const createdDateTime = 'createdDateTime';
  static const updatedDateTime = 'updatedDateTime';
  static const serverCreatedDateTime = 'serverCreatedDateTime';
  static const serverUpdatedDateTime = 'serverUpdatedDateTime';
}

@Freezed(unionKey: 'type')
sealed class GroupShoppingListItem with _$GroupShoppingListItem {
  @FreezedUnionValue('text')
  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListItem.text({
    required String id,
    required String groupID,
    required String shoppingListID,
    required String message,
    // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
    // NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
    required int order,
    @Default(GroupShoppingListItemStatus.unchecked)
    GroupShoppingListItemStatus status,
    String? description,
    String? color,
    String? groupShoppingListItemCategoryID,
    @NullableTimestampConverter() DateTime? reminderDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = TextGroupShoppingListItem;

  factory GroupShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListItemFromJson(json);

  static GroupShoppingListItem fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupShoppingListItem.fromJson(snapshot.data()!..['id'] = snapshot.id);

  // NOTE: freezedはコンストラクタが1つだけの場合、unionKey('type')をtoJsonに含めない。
  // Firestoreクエリが .where('type', isEqualTo: 'text') でフィルタしているため、手動で追加する。
  static Map<String, dynamic> toFirestore(
          GroupShoppingListItem item, SetOptions? options) =>
      item.toJson()..['type'] = 'text';
}

extension GroupShoppingListItems on List<GroupShoppingListItem> {
  int get nextOrder => (lastOrNull?.order ?? -1) + 1;
}

enum GroupShoppingListItemStatus {
  @JsonValue('checked')
  checked,
  @JsonValue('unchecked')
  unchecked,
}
