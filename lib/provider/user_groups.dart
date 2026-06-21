import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_groups.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<Group>> userGroups(Ref ref) {
  final database = ref.watch(userDatabaseProvider);
  return firestore
      .collection('/groups')
      .where('memberUserIDs', arrayContains: database.userID)
      .withConverter(
        fromFirestore: Group.fromFirestore,
        toFirestore: Group.toFirestore,
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
