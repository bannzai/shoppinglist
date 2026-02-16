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
  final AddLinkShoppingListItem addLinkShoppingListItem;

  ShoppingListDuplicate({
    required this.shoppingListAdd,
    required this.addTextShoppingListItem,
    required this.addLinkShoppingListItem,
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
      switch (item) {
        case TextGroupShoppingListItem():
          await addTextShoppingListItem(
            shoppingListID: newShoppingList.id,
            message: item.message,
            order: item.order,
            groupShoppingListItemCategoryID:
                item.groupShoppingListItemCategoryID,
            description: item.description,
            color: item.color,
          );
        case LinkGroupShoppingListItem():
          await addLinkShoppingListItem(
            shoppingListID: newShoppingList.id,
            url: item.url,
            metadataTitle: item.metadataTitle,
            metadataDescription: item.metadataDescription,
            metadataImageURL: item.metadataImageURL,
            order: item.order,
            groupShoppingListItemCategoryID:
                item.groupShoppingListItemCategoryID,
            description: item.description,
            color: item.color,
          );
      }
    }

    return newShoppingList;
  }
}

@Riverpod(dependencies: [
  shoppingListAdd,
  addTextShoppingListItem,
  addLinkShoppingListItem,
])
ShoppingListDuplicate shoppingListDuplicate(ShoppingListDuplicateRef ref,
    {required String groupID}) {
  final shoppingListAdd = ref.watch(shoppingListAddProvider(groupID: groupID));
  final addTextShoppingListItem =
      ref.watch(addTextShoppingListItemProvider(groupID: groupID));
  final addLinkShoppingListItem =
      ref.watch(addLinkShoppingListItemProvider(groupID: groupID));
  return ShoppingListDuplicate(
    shoppingListAdd: shoppingListAdd,
    addTextShoppingListItem: addTextShoppingListItem,
    addLinkShoppingListItem: addLinkShoppingListItem,
  );
}
