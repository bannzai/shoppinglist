import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_groups.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<Group>> userGroups(UserGroupsRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return FirebaseFirestore.instance
      .collection('/groups')
      .where('memberUserIDs', arrayContains: database.userID)
      .withConverter(
        fromFirestore: Group.fromFirestore,
        toFirestore: Group.toFirestore,
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
