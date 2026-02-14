import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_location.g.dart';
part 'group_shopping_location.freezed.dart';

abstract class GroupShoppingLocationFirestoreKeys {
  static const createdDateTime = 'createdDateTime';
}

@freezed
abstract class GroupShoppingLocation with _$GroupShoppingLocation {
  const GroupShoppingLocation._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingLocation({
    required String id,
    required String name,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingLocation;

  factory GroupShoppingLocation.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingLocationFromJson(json);

  static GroupShoppingLocation fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupShoppingLocation.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupShoppingLocation shoppingLocation, SetOptions? options) =>
      shoppingLocation.toJson();
}
