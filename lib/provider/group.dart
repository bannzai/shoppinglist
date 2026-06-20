import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'group.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<Group> group(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database.groupReference().snapshots().map((event) => event.data()!);
}

class GroupNameUpdate {
  final GroupDatabase database;

  GroupNameUpdate({required this.database});

  Future<void> call({required String name}) async {
    final docRef = database.groupReference();
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final currentGroup = snapshot.data()!;
      transaction.set(
        docRef,
        currentGroup.copyWith(name: name),
        SetOptions(merge: true),
      );
    });
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupNameUpdate groupNameUpdate(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupNameUpdate(database: database);
}
