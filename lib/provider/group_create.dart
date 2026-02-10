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
    final groupRef = FirebaseFirestore.instance.collection('groups').doc();
    final group = Group(id: groupRef.id, memberUserIDs: [appUser.id]);
    await groupRef
        .withConverter(
          fromFirestore: (snapshot, _) =>
              Group.fromJson(snapshot.data()!..['id'] = snapshot.id),
          toFirestore: (group, _) => group.toJson(),
        )
        .set(group);
    await userDatabase.userReference().set(
          appUser.copyWith(defaultGroupID: groupRef.id),
          SetOptions(merge: true),
        );
  }
}

@Riverpod(dependencies: [userDatabase])
CreateGroup createGroup(CreateGroupRef ref) {
  return CreateGroup(userDatabase: ref.watch(userDatabaseProvider));
}
