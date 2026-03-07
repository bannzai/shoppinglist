import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category_keyword.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list_item_category.g.dart';
part 'group_shopping_list_item_category.freezed.dart';

abstract class GroupShoppingListItemCategoryFirestoreKeys {
  static const order = 'order';
}

@freezed
abstract class GroupShoppingListItemCategory
    with _$GroupShoppingListItemCategory {
  const GroupShoppingListItemCategory._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListItemCategory({
    required String id,
    required String groupID,
    required String groupShoppingListItemCategoryAxisID,
    required String name,
    required int order,
    @Default([]) List<GroupShoppingListItemCategoryKeyword> keywords,
    String? color,
    String? iconName,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingListItemCategory;

  factory GroupShoppingListItemCategory.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListItemCategoryFromJson(json);

  static GroupShoppingListItemCategory fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupShoppingListItemCategory.fromJson(
          snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupShoppingListItemCategory category, SetOptions? options) =>
      category.toJson();
}
