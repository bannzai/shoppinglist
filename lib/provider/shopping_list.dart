import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

part 'shopping_list.g.dart';

/// 1時間ごとに自身を無効化して現在時刻を更新するプロバイダー。
/// 無料ユーザーの30日間表示制限でアプリ長時間起動時のDateTime.now()の古さを防ぐ。
@riverpod
DateTime hourlyTrigger(Ref ref) {
  final timer = Timer.periodic(const Duration(hours: 1), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  return DateTime.now();
}

/// 無料ユーザーのリスト作成数上限に達した場合にスローされる例外。
class ShoppingListLimitExceededException implements Exception {
  /// 上限数。
  final int limit;
  const ShoppingListLimitExceededException({required this.limit});

  /// ログ・デバッグ用の文言。UI 表示には
  /// `context.l10n.shoppingListLimitExceeded(limit)` を使う。
  @override
  String toString() =>
      '無料プランでは1グループあたり$limit個までリストを作成できます。プレミアムにアップグレードすると無制限に作成できます';
}

/// プレミアム判定を返す関数型。
typedef IsPremiumResolver = bool Function();

/// 買い物リストの名前を生成する。
///
/// 同じ日付に作成済みのリストが無ければ `yyyy-MM-dd`、既にあれば名前の重複を
/// 避けるため `yyyy-MM-dd (N)` を返す（[sameDateCount] が連番 N）。
/// [sameDateCount] は「同じ日付に作成済みの買い物リスト数」であり、日付が変われば
/// 0 に戻るため、日付をまたいで連番が増え続けることはない（Issue #388）。
String groupShoppingListName({
  required DateTime createdDate,
  required int sameDateCount,
}) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(createdDate);
  return sameDateCount == 0 ? formattedDate : '$formattedDate ($sameDateCount)';
}

/// 買い物リスト一覧を取得するプロバイダー。
/// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
/// このフィルタはUX最適化であり、認可は firestore.rules で担保する。
@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingList>> shoppingLists(
  Ref ref, {
  required String groupID,
  required bool isPremium,
}) {
  if (groupID.trim().isEmpty) {
    throw ArgumentError.value(groupID, 'groupID', 'must not be empty');
  }

  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  var query = database.shoppingListsReference().orderBy(
    GroupShoppingListFirestoreKeys.createdDateTime,
    descending: true,
  );

  if (!isPremium) {
    query = query.where(
      GroupShoppingListFirestoreKeys.createdDateTime,
      isGreaterThanOrEqualTo: Timestamp.fromDate(
        ref.watch(hourlyTriggerProvider).subtract(const Duration(days: 30)),
      ),
    );
  }

  return query.snapshots().map(
    (event) => event.docs.map((doc) => doc.data()).toList(),
  );
}

class ShoppingListAdd {
  final GroupDatabase database;
  final IsPremiumResolver isPremiumResolver;

  /// firestore.rules が上限判定に読むプレミアム状態の写しを RevenueCat から更新する。
  final Future<void> Function() premiumEntitlementSyncer;

  ShoppingListAdd({
    required this.database,
    required this.isPremiumResolver,
    required this.premiumEntitlementSyncer,
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
    final createdDate = DateTime.now();
    final sameDateCount = await database.countOfGroupShoppingListsCreatedOn(
      date: createdDate,
    );
    final shoppingList = GroupShoppingList(
      id: docRef.id,
      createUserID: createUserID,
      groupID: groupID,
      name: groupShoppingListName(
        createdDate: createdDate,
        sameDateCount: sameDateCount,
      ),
      status: GroupShoppingListStatus.active,
      ttlExpiresDateTime: null,
      shoppingLocationID: shoppingLocationID,
      duplicatedFromGroupShoppingListID: duplicatedFromGroupShoppingListID,
    );
    try {
      await docRef.set(shoppingList, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      // 購入直後は、firestore.rules が読むプレミアム状態の写しの同期が終わっておらず、
      // 上限に達したグループでの作成が permission-denied になり得る (Issue #683)。
      // 写しを同期してから 1 回だけ書き直す。同じ docRef への同じ内容の set なので冪等。
      if (error.code != 'permission-denied' || !isPremiumResolver()) {
        rethrow;
      }
      await premiumEntitlementSyncer();
      await docRef.set(shoppingList, SetOptions(merge: true));
    }
    return shoppingList;
  }
}

@Riverpod(dependencies: [groupDatabase])
ShoppingListAdd shoppingListAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  // プレミアム判定の SSOT は RevenueCat (ADR 0026)。Custom Claims 由来の
  // firestoreIsPremium は設定経路が無く常に false でプレミアム会員でも
  // リスト作成上限に達していた (Issue #523)。未解決(ロード中)は無料側に倒す。
  final isPremium =
      ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
  return ShoppingListAdd(
    database: database,
    isPremiumResolver: () => isPremium,
    // tear-off にすると provider の生成時に FirebaseFunctions を初期化するため、呼ぶ時まで遅らせる。
    premiumEntitlementSyncer: () => functions.syncPremiumEntitlement(),
  );
}

class ShoppingListUpdate {
  final GroupDatabase database;

  ShoppingListUpdate({required this.database});

  Future<void> call({
    required String shoppingListID,
    required GroupShoppingList shoppingList,
  }) async {
    final docRef = database.shoppingListReference(
      shoppingListID: shoppingListID,
    );
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

@Riverpod(dependencies: [shoppingListAdd, addShoppingListItem])
ShoppingListDuplicate shoppingListDuplicate(
  Ref ref, {
  required String groupID,
}) {
  final shoppingListAdd = ref.watch(shoppingListAddProvider(groupID: groupID));
  final addShoppingListItem = ref.watch(
    addShoppingListItemProvider(groupID: groupID),
  );
  return ShoppingListDuplicate(
    shoppingListAdd: shoppingListAdd,
    addShoppingListItem: addShoppingListItem,
  );
}
