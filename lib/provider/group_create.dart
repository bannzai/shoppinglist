import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create.g.dart';

class CreateGroup {
  final UserDatabase userDatabase;

  CreateGroup({required this.userDatabase});

  Future<void> call({required AppUser appUser}) async {
    final batch = FirebaseFirestore.instance.batch();

    // groupIDはここで確定するため、GroupDatabaseはcall内で生成する
    final groupDocRef = FirebaseFirestore.instance.collection('groups').doc();
    final groupDatabase = GroupDatabase(groupID: groupDocRef.id);
    final group = Group(id: groupDocRef.id, memberUserIDs: [appUser.id]);

    batch.set(
      groupDatabase.groupReference(),
      group,
      SetOptions(merge: true),
    );
    batch.set(
      userDatabase.userReference(),
      appUser.copyWith(defaultGroupID: groupDocRef.id),
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}

@Riverpod(dependencies: [userDatabase])
CreateGroup createGroup(CreateGroupRef ref) {
  return CreateGroup(userDatabase: ref.watch(userDatabaseProvider));
}
