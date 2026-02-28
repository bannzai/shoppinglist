import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'group_user_profile.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupUserProfile>> groupUserProfiles(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .userProfilesReference()
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupUserProfileUpdate {
  final GroupDatabase database;

  GroupUserProfileUpdate({required this.database});

  Future<void> call({
    required String userID,
    required String? displayName,
  }) async {
    final docRef = database.userProfileReference(userID: userID);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({
        'displayName': displayName,
        'updatedDateTime': FieldValue.serverTimestamp(),
        'serverUpdatedDateTime': FieldValue.serverTimestamp(),
      });
    } else {
      final profile = GroupUserProfile(
        id: GroupUserProfile.documentID(
            groupID: database.groupID, userID: userID),
        groupID: database.groupID,
        userID: userID,
        displayName: displayName,
      );
      await docRef.set(profile, SetOptions(merge: true));
    }
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupUserProfileUpdate groupUserProfileUpdate(Ref ref,
    {required String groupID}) {
  final database = ref.read(groupDatabaseProvider(groupID: groupID));
  return GroupUserProfileUpdate(database: database);
}
