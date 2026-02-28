import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_location.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingLocation>> shoppingLocations(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .shoppingLocationsReference()
      .orderBy(GroupShoppingLocationFirestoreKeys.createdDateTime)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class ShoppingLocationAdd {
  final GroupDatabase database;

  ShoppingLocationAdd({required this.database});

  Future<GroupShoppingLocation> call({required String name}) async {
    final docRef = database.newShoppingLocationReference();
    final shoppingLocation = GroupShoppingLocation(
      id: docRef.id,
      groupID: database.groupID,
      name: name,
    );
    await docRef.set(shoppingLocation, SetOptions(merge: true));
    return shoppingLocation;
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingLocationAdd shoppingLocationAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingLocationAdd(database: database);
}

class ShoppingLocationUpdate {
  final GroupDatabase database;

  ShoppingLocationUpdate({required this.database});

  Future<void> call({
    required String shoppingLocationID,
    required GroupShoppingLocation shoppingLocation,
  }) async {
    final docRef = database.shoppingLocationReference(
        shoppingLocationID: shoppingLocationID);
    await docRef.set(shoppingLocation, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingLocationUpdate shoppingLocationUpdate(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingLocationUpdate(database: database);
}

class ShoppingLocationDelete {
  final GroupDatabase database;

  ShoppingLocationDelete({required this.database});

  Future<void> call({required String shoppingLocationID}) async {
    final docRef = database.shoppingLocationReference(
        shoppingLocationID: shoppingLocationID);
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingLocationDelete shoppingLocationDelete(Ref ref,
    {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingLocationDelete(database: database);
}
