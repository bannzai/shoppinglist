import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list.g.dart';
part 'group_shopping_list.freezed.dart';

abstract class GroupShoppingListFirestoreKeys {
  static const createdDateTime = 'createdDateTime';
}

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
    String? shoppingLocationID,
    String? duplicatedFromID,
    @TimestampConverter() required DateTime? ttlExpiresDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingList;

  factory GroupShoppingList.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListFromJson(json);
}

enum GroupShoppingListStatus {
  @JsonValue('active')
  active,
  @JsonValue('done')
  done,
  @JsonValue('archived')
  archived,
}
