import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'app_user_private.g.dart';
part 'app_user_private.freezed.dart';

@freezed
abstract class AppUserPrivate with _$AppUserPrivate {
  const AppUserPrivate._();

  @JsonSerializable(explicitToJson: true)
  const factory AppUserPrivate({
    required String id,
    required String userID,
    String? email,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _AppUserPrivate;

  factory AppUserPrivate.fromJson(Map<String, dynamic> json) =>
      _$AppUserPrivateFromJson(json);

  static AppUserPrivate fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      AppUserPrivate.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          AppUserPrivate private, SetOptions? options) =>
      private.toJson();

  /// composite ID: user_{userID}_private_{userID}
  static String documentID({required String userID}) =>
      'user_${userID}_private_$userID';
}
