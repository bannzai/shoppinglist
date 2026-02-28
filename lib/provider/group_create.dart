import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create.g.dart';

class CreateGroup {
  final UserDatabase userDatabase;

  CreateGroup({required this.userDatabase});

  Future<void> call(
      {required AppUser appUser,
      required String? name,
      required bool setAsDefault}) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // groupIDはここで確定するため、GroupDatabaseはcall内で生成する
      final groupDocRef = FirebaseFirestore.instance.collection('groups').doc();
      final groupDatabase = GroupDatabase(groupID: groupDocRef.id);
      final group = Group(
        id: groupDocRef.id,
        memberUserIDs: [appUser.id],
        name: name,
        ownerUserID: appUser.id,
      );

      batch.set(
        groupDatabase.groupReference(),
        group,
        SetOptions(merge: true),
      );

      // setAsDefault == true → 常にdefaultGroupIDを更新
      // setAsDefault == false → defaultGroupIDがnullの場合のみ自動設定
      final shouldSetDefault = setAsDefault || appUser.defaultGroupID == null;
      if (shouldSetDefault) {
        batch.set(
          userDatabase.userReference(),
          appUser.copyWith(defaultGroupID: groupDocRef.id),
          SetOptions(merge: true),
        );
      }

      // グループ作成者のプロフィールを作成
      final currentUser = FirebaseAuth.instance.currentUser;
      final profile = GroupUserProfile(
        id: GroupUserProfile.documentID(
            groupID: groupDocRef.id, userID: appUser.id),
        groupID: groupDocRef.id,
        userID: appUser.id,
        displayName: currentUser?.displayName,
      );
      batch.set(
        groupDatabase.userProfileReference(userID: appUser.id),
        profile,
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      debugPrint('Failed to create group: $e');
      rethrow;
    }
  }
}

@Riverpod(dependencies: [userDatabase])
CreateGroup createGroup(CreateGroupRef ref) {
  return CreateGroup(userDatabase: ref.watch(userDatabaseProvider));
}
