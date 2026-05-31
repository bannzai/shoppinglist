import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_category.g.dart';

// --- CategoryAxis Providers ---

@Riverpod(dependencies: [groupDatabase, userDatabase])
Stream<List<GroupCategoryAxis>> groupCategoryAxes(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  final userDatabase = ref.watch(userDatabaseProvider);
  return database
      .categoryAxesReference()
      .where(GroupCategoryAxisFirestoreKeys.userID,
          isEqualTo: userDatabase.userID)
      .orderBy(GroupCategoryAxisFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupCategoryAxisAdd {
  final GroupDatabase database;

  GroupCategoryAxisAdd({required this.database});

  Future<GroupCategoryAxis> call({
    required String groupID,
    required String userID,
    required String name,
    required int order,
  }) async {
    final docRef = database.newCategoryAxisReference();
    final categoryAxis = GroupCategoryAxis(
      id: docRef.id,
      groupID: groupID,
      userID: userID,
      name: name,
      order: order,
    );
    await docRef.set(categoryAxis, SetOptions(merge: true));
    return categoryAxis;
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryAxisAdd groupCategoryAxisAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryAxisAdd(database: database);
}

class GroupCategoryAxisDelete {
  final GroupDatabase database;

  GroupCategoryAxisDelete({required this.database});

  Future<void> call({required String categoryAxisID}) async {
    final docRef =
        database.categoryAxisReference(categoryAxisID: categoryAxisID);
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryAxisDelete groupCategoryAxisDelete(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryAxisDelete(database: database);
}

// --- Category Providers ---

@Riverpod(dependencies: [groupDatabase, userDatabase])
Stream<List<GroupCategory>> groupCategories(Ref ref,
    {required String groupID, required String categoryAxisID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .categoriesReference(categoryAxisID: categoryAxisID)
      .orderBy(GroupCategoryFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupCategoryAdd {
  final GroupDatabase database;

  GroupCategoryAdd({required this.database});

  Future<GroupCategory> call({
    required String groupID,
    required String userID,
    required String categoryAxisID,
    required String name,
    required int order,
  }) async {
    final docRef =
        database.newCategoryReference(categoryAxisID: categoryAxisID);
    final category = GroupCategory(
        id: docRef.id,
        groupID: groupID,
        userID: userID,
        groupCategoryAxisID: categoryAxisID,
        name: name,
        order: order,
        locationOrders: {},
        keywords: [],
        color: null,
        iconName: null);
    await docRef.set(category, SetOptions(merge: true));
    return category;
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryAdd groupCategoryAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryAdd(database: database);
}

class GroupCategoryUpdate {
  final GroupDatabase database;

  GroupCategoryUpdate({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required GroupCategory category,
  }) async {
    final docRef = database.categoryReference(
        categoryAxisID: categoryAxisID, categoryID: categoryID);
    await docRef.set(category, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryUpdate groupCategoryUpdate(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryUpdate(database: database);
}

class GroupCategoryDelete {
  final GroupDatabase database;

  GroupCategoryDelete({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
  }) async {
    final docRef = database.categoryReference(
        categoryAxisID: categoryAxisID, categoryID: categoryID);
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryDelete groupCategoryDelete(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryDelete(database: database);
}

class GroupCategoryBatchUpdate {
  final GroupDatabase database;

  GroupCategoryBatchUpdate({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required List<GroupCategory> categories,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final category in categories) {
      final docRef = database.categoryReference(
          categoryAxisID: categoryAxisID, categoryID: category.id);
      batch.set(docRef, category, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryBatchUpdate groupCategoryBatchUpdate(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryBatchUpdate(database: database);
}
