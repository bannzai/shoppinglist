import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_category.g.dart';
part 'group_category.freezed.dart';

abstract class GroupCategoryFirestoreKeys {
  static const order = 'order';
}

@freezed
abstract class GroupCategory with _$GroupCategory {
  const GroupCategory._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupCategory({
    required String id,
    required String groupID,
    required String userID,
    @JsonKey(name: 'groupShoppingListItemCategoryAxisID')
    required String groupCategoryAxisID,
    required String name,
    required int order,
    @Default([]) List<GroupCategoryKeyword> keywords,
    String? color,
    String? iconName,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupCategory;

  factory GroupCategory.fromJson(Map<String, dynamic> json) =>
      _$GroupCategoryFromJson(json);

  static GroupCategory fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupCategory.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupCategory category, SetOptions? options) =>
      category.toJson();
}
