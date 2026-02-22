import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category_axis.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_shopping_list_item_category.g.dart';

// --- CategoryAxis Providers ---

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListItemCategoryAxis>>
    groupShoppingListItemCategoryAxes(GroupShoppingListItemCategoryAxesRef ref,
        {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .categoryAxesReference()
      .orderBy(GroupShoppingListItemCategoryAxisFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupShoppingListItemCategoryAxisAdd {
  final GroupDatabase database;

  GroupShoppingListItemCategoryAxisAdd({required this.database});

  Future<GroupShoppingListItemCategoryAxis> call({
    required String groupID,
    required String name,
    required int order,
  }) async {
    final docRef = database.newCategoryAxisReference();
    final categoryAxis = GroupShoppingListItemCategoryAxis(
      id: docRef.id,
      groupID: groupID,
      name: name,
      order: order,
    );
    await docRef.set(categoryAxis, SetOptions(merge: true));
    return categoryAxis;
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupShoppingListItemCategoryAxisAdd groupShoppingListItemCategoryAxisAdd(
    GroupShoppingListItemCategoryAxisAddRef ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupShoppingListItemCategoryAxisAdd(database: database);
}

class GroupShoppingListItemCategoryAxisDelete {
  final GroupDatabase database;

  GroupShoppingListItemCategoryAxisDelete({required this.database});

  Future<void> call({required String categoryAxisID}) async {
    final docRef =
        database.categoryAxisReference(categoryAxisID: categoryAxisID);
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupShoppingListItemCategoryAxisDelete groupShoppingListItemCategoryAxisDelete(
    GroupShoppingListItemCategoryAxisDeleteRef ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupShoppingListItemCategoryAxisDelete(database: database);
}

// --- Category Providers ---

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListItemCategory>> groupShoppingListItemCategories(
    GroupShoppingListItemCategoriesRef ref,
    {required String groupID,
    required String categoryAxisID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .categoriesReference(categoryAxisID: categoryAxisID)
      .orderBy(GroupShoppingListItemCategoryFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupShoppingListItemCategoryAdd {
  final GroupDatabase database;

  GroupShoppingListItemCategoryAdd({required this.database});

  Future<GroupShoppingListItemCategory> call({
    required String groupID,
    required String categoryAxisID,
    required String name,
    required int order,
  }) async {
    final docRef =
        database.newCategoryReference(categoryAxisID: categoryAxisID);
    final category = GroupShoppingListItemCategory(
      id: docRef.id,
      groupID: groupID,
      groupShoppingListItemCategoryAxisID: categoryAxisID,
      name: name,
      order: order,
    );
    await docRef.set(category, SetOptions(merge: true));
    return category;
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupShoppingListItemCategoryAdd groupShoppingListItemCategoryAdd(
    GroupShoppingListItemCategoryAddRef ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupShoppingListItemCategoryAdd(database: database);
}

class GroupShoppingListItemCategoryUpdate {
  final GroupDatabase database;

  GroupShoppingListItemCategoryUpdate({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required GroupShoppingListItemCategory category,
  }) async {
    final docRef = database.categoryReference(
        categoryAxisID: categoryAxisID, categoryID: categoryID);
    await docRef.set(category, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupShoppingListItemCategoryUpdate groupShoppingListItemCategoryUpdate(
    GroupShoppingListItemCategoryUpdateRef ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupShoppingListItemCategoryUpdate(database: database);
}

class GroupShoppingListItemCategoryDelete {
  final GroupDatabase database;

  GroupShoppingListItemCategoryDelete({required this.database});

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
GroupShoppingListItemCategoryDelete groupShoppingListItemCategoryDelete(
    GroupShoppingListItemCategoryDeleteRef ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupShoppingListItemCategoryDelete(database: database);
}

class GroupShoppingListItemCategoryBatchUpdate {
  final GroupDatabase database;

  GroupShoppingListItemCategoryBatchUpdate({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required List<GroupShoppingListItemCategory> categories,
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
GroupShoppingListItemCategoryBatchUpdate
    groupShoppingListItemCategoryBatchUpdate(
        GroupShoppingListItemCategoryBatchUpdateRef ref,
        {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupShoppingListItemCategoryBatchUpdate(database: database);
}
