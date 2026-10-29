import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
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
    // firestore.rules の上限判定が読む値は Functions が書き込みの後に更新するため、直前の
    // 変化に追いついていない間は、上限内の作成も permission-denied になり得る (Issue #683)。
    // プレミアムは購入直後の写しの同期を待ち、無料はリスト削除後の件数の数え直しを待ってから
    // 書き直す。同じ docRef への同じ内容の set なので冪等。
    for (var retryCount = 0; ; retryCount += 1) {
      try {
        await docRef.set(shoppingList, SetOptions(merge: true));
        return shoppingList;
      } on FirebaseException catch (error) {
        if (error.code != 'permission-denied' ||
            retryCount >= _shoppingListAddPermissionDeniedRetryLimit) {
          rethrow;
        }
        if (isPremiumResolver()) {
          await premiumEntitlementSyncer();
        } else {
          await Future<void>.delayed(
            _shoppingListAddPermissionDeniedRetryDelay,
          );
        }
      }
    }
  }
}

/// ShoppingListAdd が permission-denied で書き直す上限回数。
/// updateActiveShoppingListCount の数え直しはトリガーの起動を含めて数秒で終わるため、
/// 1 秒間隔で 3 回待てば追いつく。それでも拒否されるなら本当に上限を超えているとみなす。
const _shoppingListAddPermissionDeniedRetryLimit = 3;

/// 無料ユーザーの作成が permission-denied になった時に、件数の数え直しを待つ間隔。
const _shoppingListAddPermissionDeniedRetryDelay = Duration(seconds: 1);

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
