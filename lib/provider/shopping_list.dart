import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/shopping_list.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

part 'shopping_list.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<ShoppingList>> shoppingLists(ShoppingListsRef ref) {
  final database = ref.watch(groupDatabaseProvider);
  return database
      .shoppingListsReference()
      .orderBy(ShoppingListFirestoreKeys.createdDateTime, descending: true)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class ShoppingListAdd {
  final GroupDatabase database;

  ShoppingListAdd({required this.database});

  Future<ShoppingList> call(
      {required String createUserID, required String groupID}) async {
    final docRef = database.newShoppingListReference();
    final count = await database.countOfShoppingLists();
    final shoppingList = ShoppingList(
      id: docRef.id,
      createUserID: createUserID,
      groupID: groupID,
      name: count == 0
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ($count)',
      status: ShoppingListStatus.active,
      ttlExpiresDateTime: DateTime.now().add(const Duration(days: 30)),
    );
    await docRef.set(shoppingList);
    return shoppingList;
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListAdd shoppingListAdd(ShoppingListAddRef ref) {
  final database = ref.watch(groupDatabaseProvider);
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
ShoppingListDelete shoppingListDelete(ShoppingListDeleteRef ref) {
  final database = ref.watch(groupDatabaseProvider);
  return ShoppingListDelete(database: database);
}

class ShoppingListUpdate {
  final GroupDatabase database;

  ShoppingListUpdate({required this.database});

  Future<void> call(
      {required String shoppingListID,
      required ShoppingList shoppingList}) async {
    final docRef =
        database.shoppingListReference(shoppingListID: shoppingListID);
    await docRef.set(shoppingList);
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListUpdate shoppingListUpdate(ShoppingListUpdateRef ref) {
  final database = ref.watch(groupDatabaseProvider);
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

  Future<ShoppingList> call(
      {required String createUserID,
      required String groupID,
      required List<ShoppingListItem> shoppingListItems}) async {
    final shoppingList =
        await shoppingListAdd(createUserID: createUserID, groupID: groupID);
    for (var item in shoppingListItems) {
      if (item is TextShoppingListItem) {
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
ShoppingListDuplicate shoppingListDuplicate(ShoppingListDuplicateRef ref) {
  final shoppingListAdd = ref.watch(shoppingListAddProvider);
  final addTextShoppingListItem = ref.watch(addTextShoppingListItemProvider);
  final database = ref.watch(groupDatabaseProvider);
  return ShoppingListDuplicate(
      shoppingListAdd: shoppingListAdd,
      addTextShoppingListItem: addTextShoppingListItem,
      database: database);
}
