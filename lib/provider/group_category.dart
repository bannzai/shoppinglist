import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_category.g.dart';

// --- CategoryAxis Providers ---

@Riverpod(dependencies: [groupDatabase, userDatabase])
Stream<List<GroupCategoryAxis>> groupCategoryAxes(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  final userDatabase = ref.watch(userDatabaseProvider);
  return database
      .categoryAxesReference()
      .where(
        GroupCategoryAxisFirestoreKeys.userID,
        isEqualTo: userDatabase.userID,
      )
      .orderBy(GroupCategoryAxisFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupCategoryAxisAdd {
  final GroupDatabase database;

  GroupCategoryAxisAdd({required this.database});

  Future<GroupCategoryAxis> call({
    required String groupID,
    required String userID,
    required String name,
    required int order,
  }) async {
    final docRef = database.newCategoryAxisReference();
    final categoryAxis = GroupCategoryAxis(
      id: docRef.id,
      groupID: groupID,
      userID: userID,
      name: name,
      order: order,
    );
    await docRef.set(categoryAxis, SetOptions(merge: true));
    return categoryAxis;
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryAxisAdd groupCategoryAxisAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryAxisAdd(database: database);
}

class GroupCategoryAxisDelete {
  final GroupDatabase database;

  GroupCategoryAxisDelete({required this.database});

  Future<void> call({required String categoryAxisID}) async {
    final docRef = database.categoryAxisReference(
      categoryAxisID: categoryAxisID,
    );
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryAxisDelete groupCategoryAxisDelete(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryAxisDelete(database: database);
}

// --- Category Providers ---

@Riverpod(dependencies: [groupDatabase, userDatabase])
Stream<List<GroupCategory>> groupCategories(
  Ref ref, {
  required String groupID,
  required String categoryAxisID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database
      .categoriesReference(categoryAxisID: categoryAxisID)
      .orderBy(GroupCategoryFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class GroupCategoryAdd {
  final GroupDatabase database;

  GroupCategoryAdd({required this.database});

  Future<GroupCategory> call({
    required String groupID,
    required String userID,
    required String categoryAxisID,
    required String name,
    required int order,
  }) async {
    final docRef = database.newCategoryReference(
      categoryAxisID: categoryAxisID,
    );
    final category = GroupCategory(
      id: docRef.id,
      groupID: groupID,
      userID: userID,
      groupCategoryAxisID: categoryAxisID,
      name: name,
      order: order,
      locationOrders: {},
      keywords: [],
      color: null,
      iconName: null,
    );
    await docRef.set(category, SetOptions(merge: true));
    return category;
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryAdd groupCategoryAdd(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryAdd(database: database);
}

class GroupCategoryUpdate {
  final GroupDatabase database;

  GroupCategoryUpdate({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required GroupCategory category,
  }) async {
    final docRef = database.categoryReference(
      categoryAxisID: categoryAxisID,
      categoryID: categoryID,
    );
    await docRef.set(category, SetOptions(merge: true));
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryUpdate groupCategoryUpdate(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryUpdate(database: database);
}

class GroupCategoryDelete {
  final GroupDatabase database;

  GroupCategoryDelete({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
  }) async {
    final docRef = database.categoryReference(
      categoryAxisID: categoryAxisID,
      categoryID: categoryID,
    );
    await docRef.delete();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryDelete groupCategoryDelete(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryDelete(database: database);
}

class GroupCategoryBatchUpdate {
  final GroupDatabase database;

  GroupCategoryBatchUpdate({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required List<GroupCategory> categories,
  }) async {
    final batch = firestore.batch();

    for (final category in categories) {
      final docRef = database.categoryReference(
        categoryAxisID: categoryAxisID,
        categoryID: category.id,
      );
      batch.set(docRef, category, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryBatchUpdate groupCategoryBatchUpdate(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryBatchUpdate(database: database);
}

/// 指定カテゴリに完全一致キーワードを1件追記する。
///
/// アイテムにカテゴリIDを持たせず、カテゴリのキーワードとのマッチングで分類する
/// 設計のため、未分類アイテムを既存カテゴリへ割り当てる操作は「アイテム名を
/// そのカテゴリの完全一致キーワードとして追記する」ことで実現する。
/// 同時編集でキーワードが消えないよう read-modify-write を transaction で行う
/// （firestore-transaction.md）。既に同じキーワードが存在する場合は何もしない（冪等）。
class GroupCategoryKeywordAdd {
  final GroupDatabase database;

  GroupCategoryKeywordAdd({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required String keyword,
  }) async {
    final docRef = database.categoryReference(
      categoryAxisID: categoryAxisID,
      categoryID: categoryID,
    );
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final current = snapshot.data();
      if (current == null) {
        return;
      }
      final alreadyExists = current.keywords.any(
        (existing) => existing.keyword == keyword,
      );
      if (alreadyExists) {
        return;
      }
      transaction.set(
        docRef,
        current.copyWith(
          keywords: [
            ...current.keywords,
            GroupCategoryKeyword(
              keyword: keyword,
              matchingType: GroupCategoryKeywordMatchingType.exact,
            ),
          ],
        ),
        SetOptions(merge: true),
      );
    });
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryKeywordAdd groupCategoryKeywordAdd(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryKeywordAdd(database: database);
}

/// AIカテゴリ分けの確定結果（アイテム名→カテゴリ名）を Firestore に反映する。
///
/// アイテムにカテゴリIDは持たせず、カテゴリのキーワードとのマッチングで分類する
/// 設計のため、各アイテム名を該当カテゴリの完全一致キーワードとして追記する。
/// - 軸（[GroupCategoryAxis]）が無ければ「デフォルト」軸を作成する
/// - assignments の categoryName に一致する既存カテゴリが無ければ作成する
/// - 各アイテム名を該当カテゴリの完全一致キーワードとして追記する（重複は無視）
class AICategorizeApply {
  final GroupDatabase database;

  AICategorizeApply({required this.database});

  Future<void> call({
    required String groupID,
    required String userID,
    required String? categoryAxisID,
    required List<({String itemName, String categoryName})> assignments,
  }) async {
    if (assignments.isEmpty) {
      return;
    }

    // 1. 軸を確定（無ければ「デフォルト」軸を作成）
    final String axisID;
    if (categoryAxisID != null) {
      axisID = categoryAxisID;
    } else {
      final axisRef = database.newCategoryAxisReference();
      await axisRef.set(
        GroupCategoryAxis(
          id: axisRef.id,
          groupID: groupID,
          userID: userID,
          name: 'デフォルト',
          order: 0,
        ),
        SetOptions(merge: true),
      );
      axisID = axisRef.id;
    }

    // 2. 既存カテゴリを取得し、名前→カテゴリ の対応を作る
    final existing =
        (await database
                .categoriesReference(categoryAxisID: axisID)
                .orderBy(GroupCategoryFirestoreKeys.order)
                .get())
            .docs
            .map((doc) => doc.data())
            .toList();
    final categoryByName = {
      for (final category in existing) category.name: category,
    };
    var nextOrder =
        existing.fold<int>(
          -1,
          (max, category) => category.order > max ? category.order : max,
        ) +
        1;

    // 3. assignments に登場するカテゴリ名のうち未作成のものを作成
    for (final categoryName in assignments.map((a) => a.categoryName).toSet()) {
      if (categoryByName.containsKey(categoryName)) {
        continue;
      }
      final docRef = database.newCategoryReference(categoryAxisID: axisID);
      final category = GroupCategory(
        id: docRef.id,
        groupID: groupID,
        userID: userID,
        groupCategoryAxisID: axisID,
        name: categoryName,
        order: nextOrder++,
        locationOrders: {},
        keywords: [],
        color: null,
        iconName: null,
      );
      await docRef.set(category, SetOptions(merge: true));
      categoryByName[categoryName] = category;
    }

    // 4. カテゴリ名ごとに、割り当てられたアイテム名を完全一致キーワードとして追記
    final itemNamesByCategoryName = <String, List<String>>{};
    for (final assignment in assignments) {
      itemNamesByCategoryName
          .putIfAbsent(assignment.categoryName, () => [])
          .add(assignment.itemName);
    }
    for (final entry in itemNamesByCategoryName.entries) {
      final docRef = database.categoryReference(
        categoryAxisID: axisID,
        categoryID: categoryByName[entry.key]!.id,
      );
      // 同時編集でキーワードが消えないよう read-modify-write を transaction で行う
      // （firestore-transaction.md: group 配下の同時書き込み対策）。
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final current = snapshot.data();
        if (current == null) {
          return;
        }
        final existingKeywords =
            current.keywords.map((keyword) => keyword.keyword).toSet();
        final addedKeywords = entry.value
            .where((itemName) => !existingKeywords.contains(itemName))
            .map(
              (itemName) => GroupCategoryKeyword(
                keyword: itemName,
                matchingType: GroupCategoryKeywordMatchingType.exact,
              ),
            );
        transaction.set(
          docRef,
          current.copyWith(keywords: [...current.keywords, ...addedKeywords]),
          SetOptions(merge: true),
        );
      });
    }
  }
}

@Riverpod(dependencies: [groupDatabase])
AICategorizeApply aiCategorizeApply(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return AICategorizeApply(database: database);
}

/// アイテム移動に伴う、1 カテゴリのキーワード付け替え結果を返す純粋関数。
///
/// [category] が移動先([destinationCategoryID])なら [itemMessage] を完全一致(exact)キーワード
/// として追加する(既に同じ exact があれば変更なし)。移動先以外なら [itemMessage] の exact
/// キーワードを削除する(手動の partial/regex は触らない)。変更が生じない場合は null を返す。
List<GroupCategoryKeyword>? keywordsAfterItemMove({
  required GroupCategory category,
  required String itemMessage,
  required String? destinationCategoryID,
}) {
  final keywords = [...category.keywords];
  if (category.id == destinationCategoryID) {
    final alreadyHasExact = keywords.any(
      (keyword) =>
          keyword.keyword == itemMessage &&
          keyword.matchingType == GroupCategoryKeywordMatchingType.exact,
    );
    if (alreadyHasExact) {
      return null;
    }
    keywords.add(
      GroupCategoryKeyword(
        keyword: itemMessage,
        matchingType: GroupCategoryKeywordMatchingType.exact,
      ),
    );
    return keywords;
  }
  final lengthBeforeRemove = keywords.length;
  keywords.removeWhere(
    (keyword) =>
        keyword.keyword == itemMessage &&
        keyword.matchingType == GroupCategoryKeywordMatchingType.exact,
  );
  return keywords.length == lengthBeforeRemove ? null : keywords;
}

/// アイテム(message)の所属カテゴリを、完全一致(exact)キーワードの付け替えで変更する。
///
/// カテゴリをまたぐ D&D で「別カテゴリへ移す」永続化に使う。アイテムはカテゴリIDを持たず
/// message とキーワードのマッチで分類されるため、同名(message)のアイテムは同じカテゴリへ
/// 分類される(キーワードは message 単位)。手動の partial/regex は変更しない(削除対象は exact
/// のみ)ため、partial/regex で別カテゴリにマッチしているアイテムは移動が効かない場合がある
/// (分類エンジン findMatchingCategoryID を変えない方針による既知の限界)。
class MoveItemCategoryKeyword {
  final GroupDatabase database;

  MoveItemCategoryKeyword({required this.database});

  Future<void> call({
    required String categoryAxisID,
    required String itemMessage,
    required String? destinationCategoryID,
    required List<GroupCategory> categories,
  }) async {
    // group 配下の同時書き込みでキーワードが失われないよう transaction で read-modify-write する
    // (firestore-transaction.md)。
    await firestore.runTransaction((transaction) async {
      // transaction の制約により read を全て先に行う。
      final currentByCategoryID = <String, GroupCategory>{};
      for (final category in categories) {
        final snapshot = await transaction.get(
          database.categoryReference(
            categoryAxisID: categoryAxisID,
            categoryID: category.id,
          ),
        );
        final current = snapshot.data();
        if (current != null) {
          currentByCategoryID[category.id] = current;
        }
      }

      for (final entry in currentByCategoryID.entries) {
        final updatedKeywords = keywordsAfterItemMove(
          category: entry.value,
          itemMessage: itemMessage,
          destinationCategoryID: destinationCategoryID,
        );
        if (updatedKeywords == null) {
          continue; // 変更なし → 書き込まない(冪等)
        }
        transaction.set(
          database.categoryReference(
            categoryAxisID: categoryAxisID,
            categoryID: entry.key,
          ),
          entry.value.copyWith(keywords: updatedKeywords),
          SetOptions(merge: true),
        );
      }
    });
  }
}

@Riverpod(dependencies: [groupDatabase])
MoveItemCategoryKeyword moveItemCategoryKeyword(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return MoveItemCategoryKeyword(database: database);
}
