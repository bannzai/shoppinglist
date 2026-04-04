import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

part 'shopping_list.g.dart';

/// 無料ユーザーのリスト作成数上限に達した場合にスローされる例外。
class ShoppingListLimitExceededException implements Exception {
  /// 上限数。
  final int limit;
  const ShoppingListLimitExceededException({required this.limit});

  @override
  String toString() =>
      '無料プランでは1グループあたり$limit個までリストを作成できます。プレミアムにアップグレードすると無制限に作成できます';
}

/// プレミアム判定を返す関数型。
typedef IsPremiumResolver = bool Function();

/// 買い物リスト一覧を取得するプロバイダー。
/// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
/// このフィルタはUX最適化であり、認可は firestore.rules で担保する。
@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingList>> shoppingLists(Ref ref,
    {required String groupID, required bool isPremium}) {
  if (groupID.trim().isEmpty) {
    throw ArgumentError.value(groupID, 'groupID', 'must not be empty');
  }

  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  var query = database
      .shoppingListsReference()
      .orderBy(GroupShoppingListFirestoreKeys.createdDateTime, descending: true);

  if (!isPremium) {
    query = query.where(
      GroupShoppingListFirestoreKeys.createdDateTime,
      isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 30))),
    );
  }

  return query
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class ShoppingListAdd {
  final GroupDatabase database;
  final IsPremiumResolver isPremiumResolver;

  ShoppingListAdd({
    required this.database,
    required this.isPremiumResolver,
  });

  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) async {
    if (!isPremiumResolver()) {
      final activeCount = await database.countOfActiveGroupShoppingLists();
      if (activeCount >= freeGroupActiveShoppingListLimit) {
        throw const ShoppingListLimitExceededException(
          limit: freeGroupActiveShoppingListLimit,
        );
      }
    }

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
      ttlExpiresDateTime: null,
      shoppingLocationID: shoppingLocationID,
      duplicatedFromGroupShoppingListID: duplicatedFromGroupShoppingListID,
    );
    await docRef.set(shoppingList, SetOptions(merge: true));
    return shoppingList;
  }
}

@Riverpod(dependencies: [groupDatabase, firestoreIsPremium])
ShoppingListAdd shoppingListAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListAdd(
    database: database,
    isPremiumResolver: () =>
        ref.read(firestoreIsPremiumProvider).asData?.value ?? false,
  );
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
ShoppingListDelete shoppingListDelete(Ref ref, {required String groupID}) {
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
ShoppingListUpdate shoppingListUpdate(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ShoppingListUpdate(database: database);
}

class ShoppingListDuplicate {
  final ShoppingListAdd shoppingListAdd;
  final AddShoppingListItem addShoppingListItem;

  ShoppingListDuplicate({
    required this.shoppingListAdd,
    required this.addShoppingListItem,
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
      await addShoppingListItem(
        shoppingListID: newShoppingList.id,
        userID: createUserID,
        message: item.message,
        order: item.order,
        description: item.description,
        color: item.color,
      );
    }

    return newShoppingList;
  }
}

@Riverpod(dependencies: [
  shoppingListAdd,
  addShoppingListItem,
])
ShoppingListDuplicate shoppingListDuplicate(Ref ref,
    {required String groupID}) {
  final shoppingListAdd = ref.watch(shoppingListAddProvider(groupID: groupID));
  final addShoppingListItem =
      ref.watch(addShoppingListItemProvider(groupID: groupID));
  return ShoppingListDuplicate(
    shoppingListAdd: shoppingListAdd,
    addShoppingListItem: addShoppingListItem,
  );
}
