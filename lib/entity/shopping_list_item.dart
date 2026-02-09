import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'shopping_list_item.freezed.dart';
part 'shopping_list_item.g.dart';

abstract class ShoppingListItemFirestoreKeys {
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
sealed class ShoppingListItem with _$ShoppingListItem {
  @FreezedUnionValue('text')
  @JsonSerializable(explicitToJson: true)
  const factory ShoppingListItem.text({
    required String id,
    required String shoppingListID,
    required String message,
    // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
    // NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
    required int order,
    @Default(ShoppingListItemStatus.unchecked) ShoppingListItemStatus status,
    String? description,
    String? color,
    String? categoryID,
    @NullableTimestampConverter() DateTime? reminderDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = TextShoppingListItem;

  @FreezedUnionValue('link')
  @JsonSerializable(explicitToJson: true)
  const factory ShoppingListItem.link({
    required String id,
    required String shoppingListID,
    required String url,
    // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
    // NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
    required int order,
    String? metadataTitle,
    String? metadataDescription,
    String? metadataImageURL,
    @Default(ShoppingListItemStatus.unchecked) ShoppingListItemStatus status,
    String? description,
    String? color,
    String? categoryID,
    @NullableTimestampConverter() DateTime? reminderDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = LinkShoppingListItem;

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListItemFromJson(json);
}

extension ShoppingListItems on List<ShoppingListItem> {
  int get nextOrder => (lastOrNull?.order ?? -1) + 1;
}

enum ShoppingListItemStatus {
  @JsonValue('checked')
  checked,
  @JsonValue('unchecked')
  unchecked,
}
