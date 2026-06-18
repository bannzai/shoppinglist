import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_location.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingLocation>> shoppingLocations(
  Ref ref, {
  required String groupID,
}) {
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

  /// [address] は LocationPicker (PRO 限定) の逆ジオコード結果を永続化するためのフィールド。
  /// 場所名のみ登録する無料導線では空文字を渡す。
  Future<GroupShoppingLocation> call({
    required String name,
    required String address,
    required double? latitude,
    required double? longitude,
    required double? geofenceRadiusMeters,
  }) async {
    if ((latitude != null && (latitude < -90 || latitude > 90)) ||
        (longitude != null && (longitude < -180 || longitude > 180))) {
      throw ArgumentError('latitude/longitude is out of range');
    }
    if (geofenceRadiusMeters != null &&
        (geofenceRadiusMeters < 50 || geofenceRadiusMeters > 2000)) {
      throw ArgumentError.value(
        geofenceRadiusMeters,
        'geofenceRadiusMeters',
        '50〜2000mの範囲で指定してください',
      );
    }

    final docRef = database.newShoppingLocationReference();
    final shoppingLocation = GroupShoppingLocation(
      id: docRef.id,
      groupID: database.groupID,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      geofenceRadiusMeters: geofenceRadiusMeters,
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
      shoppingLocationID: shoppingLocationID,
    );
    await docRef.set(shoppingLocation, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingLocationUpdate shoppingLocationUpdate(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingLocationUpdate(database: database);
}

class ShoppingLocationDelete {
  final GroupDatabase database;

  ShoppingLocationDelete({required this.database});

  Future<void> call({required String shoppingLocationID}) async {
    final docRef = database.shoppingLocationReference(
      shoppingLocationID: shoppingLocationID,
    );
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingLocationDelete shoppingLocationDelete(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingLocationDelete(database: database);
}
