import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

part 'shopping_list.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingList>> shoppingLists(ShoppingListsRef ref,
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

  Future<GroupShoppingList> call(
      {required String createUserID, required String groupID}) async {
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
    );
    await docRef.set(shoppingList);
    return shoppingList;
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListAdd shoppingListAdd(ShoppingListAddRef ref,
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
ShoppingListDelete shoppingListDelete(ShoppingListDeleteRef ref,
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
    await docRef.set(shoppingList);
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListUpdate shoppingListUpdate(ShoppingListUpdateRef ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListUpdate(database: database);
}

class ShoppingListDuplicate {
  final ShoppingListAdd shoppingListAdd;
  final AddTextShoppingListItem addTextShoppingListItem;
  final GroupDatabase database;

  ShoppingListDuplicate(
      {required this.shoppingListAdd,
      required this.addTextShoppingListItem,
      required this.database});

  Future<GroupShoppingList> call(
      {required String createUserID,
      required String groupID,
      required List<GroupShoppingListItem> shoppingListItems}) async {
    final shoppingList =
        await shoppingListAdd(createUserID: createUserID, groupID: groupID);
    for (var item in shoppingListItems) {
      if (item is TextGroupShoppingListItem) {
        await addTextShoppingListItem(
          shoppingListID: shoppingList.id,
          message: item.message,
          order: item.order,
        );
      }
    }

    return shoppingList;
  }
}

@Riverpod(
    dependencies: [shoppingListAdd, addTextShoppingListItem, groupDatabase])
ShoppingListDuplicate shoppingListDuplicate(ShoppingListDuplicateRef ref,
    {required String groupID}) {
  final shoppingListAdd = ref.watch(shoppingListAddProvider(groupID: groupID));
  final addTextShoppingListItem =
      ref.watch(addTextShoppingListItemProvider(groupID: groupID));
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListDuplicate(
      shoppingListAdd: shoppingListAdd,
      addTextShoppingListItem: addTextShoppingListItem,
      database: database);
}
