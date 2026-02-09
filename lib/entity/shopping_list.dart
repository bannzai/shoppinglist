import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'shopping_list.g.dart';
part 'shopping_list.freezed.dart';

abstract class ShoppingListFirestoreKeys {
  static const createdDateTime = 'createdDateTime';
}

@freezed
abstract class ShoppingList with _$ShoppingList {
  const ShoppingList._();

  @JsonSerializable(explicitToJson: true)
  const factory ShoppingList({
    required String id,
    required String createUserID,
    required String groupID,
    @Default('') String name,
    @Default(ShoppingListStatus.active) ShoppingListStatus status,
    String? shoppingLocationID,
    String? duplicatedFromID,
    @TimestampConverter() required DateTime? ttlExpiresDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _ShoppingList;

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);
}

enum ShoppingListStatus {
  @JsonValue('active')
  active,
  @JsonValue('done')
  done,
  @JsonValue('archived')
  archived,
}
