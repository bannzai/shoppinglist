import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_item.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListItem>> textShoppingListItems(
    TextShoppingListItemsRef ref,
    {required String groupID,
    required String shoppingListID,
    required bool showChecked}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  var query = database
      .shoppingListItemsReference(shoppingListID: shoppingListID)
      .where(GroupShoppingListItemFirestoreKeys.type, isEqualTo: 'text');
  if (!showChecked) {
    query = query.where(GroupShoppingListItemFirestoreKeys.status,
        isEqualTo: GroupShoppingListItemStatus.unchecked.name);
  }
  return query
      .orderBy(GroupShoppingListItemFirestoreKeys.order, descending: false)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListItem>> linkShoppingListItems(
    LinkShoppingListItemsRef ref,
    {required String groupID,
    required String shoppingListID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .shoppingListItemsReference(shoppingListID: shoppingListID)
      .where(GroupShoppingListItemFirestoreKeys.type, isEqualTo: 'link')
      .orderBy(GroupShoppingListItemFirestoreKeys.order, descending: false)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class AddTextShoppingListItem {
  final GroupDatabase database;

  AddTextShoppingListItem({required this.database});

  Future<TextGroupShoppingListItem> call({
    required String shoppingListID,
    required String message,
    required int order,
    required String? groupShoppingListItemCategoryID,
    required String? description,
    required String? color,
  }) async {
    final docRef = database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc();
    final textItem = TextGroupShoppingListItem(
        id: docRef.id,
        shoppingListID: shoppingListID,
        message: message,
        order: order,
        groupShoppingListItemCategoryID: groupShoppingListItemCategoryID,
        description: description,
        color: color);
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .add(textItem);
    return textItem;
  }
}

@Riverpod(dependencies: [groupDatabase])
AddTextShoppingListItem addTextShoppingListItem(AddTextShoppingListItemRef ref,
    {required String groupID}) {
  return AddTextShoppingListItem(
      database: ref.watch(groupDatabaseProvider(groupID: groupID)));
}

class AddLinkShoppingListItem {
  final GroupDatabase database;

  AddLinkShoppingListItem({required this.database});

  Future<LinkGroupShoppingListItem> call({
    required String shoppingListID,
    required String url,
    required String? metadataTitle,
    required String? metadataDescription,
    required String? metadataImageURL,
    required int order,
    required String? groupShoppingListItemCategoryID,
    required String? description,
    required String? color,
  }) async {
    final docRef = database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .doc();
    final linkItem = LinkGroupShoppingListItem(
      id: docRef.id,
      shoppingListID: shoppingListID,
      url: url,
      metadataTitle: metadataTitle,
      metadataDescription: metadataDescription,
      metadataImageURL: metadataImageURL,
      order: order,
      groupShoppingListItemCategoryID: groupShoppingListItemCategoryID,
      description: description,
      color: color,
    );
    await database
        .shoppingListItemsReference(shoppingListID: shoppingListID)
        .add(linkItem);
    return linkItem;
  }
}

@Riverpod(dependencies: [groupDatabase])
AddLinkShoppingListItem addLinkShoppingListItem(AddLinkShoppingListItemRef ref,
    {required String groupID}) {
  return AddLinkShoppingListItem(
      database: ref.watch(groupDatabaseProvider(groupID: groupID)));
}

class ShoppingListItemBatchUpdate {
  final GroupDatabase database;

  ShoppingListItemBatchUpdate({required this.database});

  Future<void> call({
    required String shoppingListID,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in shoppingListItems) {
      final docRef = database
          .shoppingListItemsReference(shoppingListID: shoppingListID)
          .doc(item.id);
      batch.set(docRef, item, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListItemBatchUpdate shoppingListItemBatchUpdate(
    ShoppingListItemBatchUpdateRef ref,
    {required String groupID}) {
  return ShoppingListItemBatchUpdate(
      database: ref.watch(groupDatabaseProvider(groupID: groupID)));
}
