import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_user_profile.g.dart';
part 'group_user_profile.freezed.dart';

@freezed
abstract class GroupUserProfile with _$GroupUserProfile {
  const GroupUserProfile._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupUserProfile({
    required String id,
    required String groupID,
    required String userID,
    String? displayName,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupUserProfile;

  factory GroupUserProfile.fromJson(Map<String, dynamic> json) =>
      _$GroupUserProfileFromJson(json);

  static GroupUserProfile fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupUserProfile.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupUserProfile profile, SetOptions? options) =>
      profile.toJson();

  /// composite ID: group_{groupID}_userProfile_{userID}
  static String documentID({required String groupID, required String userID}) =>
      'group_${groupID}_userProfile_$userID';
}
