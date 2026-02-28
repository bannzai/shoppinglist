import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

part 'shopping_list.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingList>> shoppingLists(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .shoppingListsReference()
      .orderBy(GroupShoppingListFirestoreKeys.createdDateTime, descending: true)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class ShoppingListAdd {
  final GroupDatabase database;

  ShoppingListAdd({required this.database});

  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) async {
    final docRef = database.newGroupShoppingListReference();
    final count = await database.countOfGroupShoppingLists();
    final shoppingList = GroupShoppingList(
      id: docRef.id,
      createUserID: createUserID,
      groupID: groupID,
      name: count == 0
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ($count)',
      status: GroupShoppingListStatus.active,
      ttlExpiresDateTime: DateTime.now().add(const Duration(days: 30)),
      shoppingLocationID: shoppingLocationID,
      duplicatedFromGroupShoppingListID: duplicatedFromGroupShoppingListID,
    );
    await docRef.set(shoppingList, SetOptions(merge: true));
    return shoppingList;
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListAdd shoppingListAdd(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListAdd(database: database);
}

class ShoppingListDelete {
  final GroupDatabase database;

  ShoppingListDelete({required this.database});

  Future<void> call({required String shoppingListID}) async {
    final docRef =
        database.shoppingListReference(shoppingListID: shoppingListID);
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListDelete shoppingListDelete(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListDelete(database: database);
}

class ShoppingListUpdate {
  final GroupDatabase database;

  ShoppingListUpdate({required this.database});

  Future<void> call(
      {required String shoppingListID,
      required GroupShoppingList shoppingList}) async {
    final docRef =
        database.shoppingListReference(shoppingListID: shoppingListID);
    await docRef.set(shoppingList, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListUpdate shoppingListUpdate(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListUpdate(database: database);
}

class ShoppingListDuplicate {
  final ShoppingListAdd shoppingListAdd;
  final AddTextShoppingListItem addTextShoppingListItem;

  ShoppingListDuplicate({
    required this.shoppingListAdd,
    required this.addTextShoppingListItem,
  });

  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required GroupShoppingList sourceShoppingList,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    final newShoppingList = await shoppingListAdd(
      createUserID: createUserID,
      groupID: groupID,
      shoppingLocationID: sourceShoppingList.shoppingLocationID,
      duplicatedFromGroupShoppingListID: sourceShoppingList.id,
    );

    for (final item in shoppingListItems) {
      await addTextShoppingListItem(
        shoppingListID: newShoppingList.id,
        message: item.message,
        order: item.order,
        groupShoppingListItemCategoryID: item.groupShoppingListItemCategoryID,
        description: item.description,
        color: item.color,
      );
    }

    return newShoppingList;
  }
}

@Riverpod(dependencies: [
  shoppingListAdd,
  addTextShoppingListItem,
])
ShoppingListDuplicate shoppingListDuplicate(Ref ref,
    {required String groupID}) {
  final shoppingListAdd = ref.watch(shoppingListAddProvider(groupID: groupID));
  final addTextShoppingListItem =
      ref.watch(addTextShoppingListItemProvider(groupID: groupID));
  return ShoppingListDuplicate(
    shoppingListAdd: shoppingListAdd,
    addTextShoppingListItem: addTextShoppingListItem,
  );
}
