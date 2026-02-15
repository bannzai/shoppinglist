import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list_item_category_axis.g.dart';
part 'group_shopping_list_item_category_axis.freezed.dart';

abstract class GroupShoppingListItemCategoryAxisFirestoreKeys {
  static const order = 'order';
}

@freezed
abstract class GroupShoppingListItemCategoryAxis
    with _$GroupShoppingListItemCategoryAxis {
  const GroupShoppingListItemCategoryAxis._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListItemCategoryAxis({
    required String id,
    required String groupID,
    required String name,
    required int order,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingListItemCategoryAxis;

  factory GroupShoppingListItemCategoryAxis.fromJson(
          Map<String, dynamic> json) =>
      _$GroupShoppingListItemCategoryAxisFromJson(json);

  static GroupShoppingListItemCategoryAxis fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupShoppingListItemCategoryAxis.fromJson(
          snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupShoppingListItemCategoryAxis categoryAxis,
          SetOptions? options) =>
      categoryAxis.toJson();
}
