import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_category_axis.g.dart';
part 'group_category_axis.freezed.dart';

abstract class GroupCategoryAxisFirestoreKeys {
  static const userID = 'userID';
  static const order = 'order';
}

@freezed
abstract class GroupCategoryAxis
    with _$GroupCategoryAxis {
  const GroupCategoryAxis._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupCategoryAxis({
    required String id,
    required String groupID,
    required String userID,
    required String name,
    required int order,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupCategoryAxis;

  factory GroupCategoryAxis.fromJson(
          Map<String, dynamic> json) =>
      _$GroupCategoryAxisFromJson(json);

  static GroupCategoryAxis fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupCategoryAxis.fromJson(
          snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupCategoryAxis categoryAxis,
          SetOptions? options) =>
      categoryAxis.toJson();
}
