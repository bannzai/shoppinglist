import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_category.g.dart';

// --- CategoryAxis Providers ---

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupCategoryAxis>> groupCategoryAxes(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  final currentUserID = ref.watch(currentUserIDProvider);
  // ログアウト・ユーザー切替直後のティアダウン中に古い uid で group 配下を
  // クエリすると permission-denied や別ユーザーのデータ参照になり得るため、
  // uid が無い間は Firestore を触らず空リストを流す。
  if (currentUserID == null) {
    return Stream.value(const <GroupCategoryAxis>[]);
  }
  return database
      .categoryAxesReference()
      .where(GroupCategoryAxisFirestoreKeys.userID, isEqualTo: currentUserID)
      .orderBy(GroupCategoryAxisFirestoreKeys.order)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

/// 同じグループに所属するメンバーが取り込み元として選べるカテゴリ軸。
///
/// 通常表示用の [groupCategoryAxes] は本人の軸だけを返す一方、この Provider は
/// グループ内共有の取り込み画面に限って全メンバーの軸を返す。書き込み権限は
/// 引き続き所有者本人に限定し、取り込み時は自分のカテゴリとしてコピーする。
List<GroupCategoryAxis> filterShareableGroupCategoryAxes({
  required List<GroupCategoryAxis> groupCategoryAxes,
  required List<String> memberUserIDs,
}) {
  final memberUserIDSet = memberUserIDs.toSet();
  return groupCategoryAxes
      .where((axis) => memberUserIDSet.contains(axis.userID))
      .toList();
}

@Riverpod(dependencies: [groupDatabase, group])
Stream<List<GroupCategoryAxis>> shareableGroupCategoryAxes(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return ref
      .watch(groupProvider(groupID: groupID))
      .when(
        data:
            (group) => _watchShareableGroupCategoryAxes(
              database: database,
              memberUserIDs: group.memberUserIDs,
            ),
        error: Stream.error,
        loading: Stream.empty,
      );
}

/// Rules が各クエリの読み取り対象を現在のメンバー所有に限定できるよう、所有者ごとに
/// クエリして結果を結合する。これによりメンバー数が whereIn の上限を超えても動く。
Stream<List<GroupCategoryAxis>> _watchShareableGroupCategoryAxes({
  required GroupDatabase database,
  required List<String> memberUserIDs,
}) {
  final uniqueMemberUserIDs = memberUserIDs.toSet();
  if (uniqueMemberUserIDs.isEmpty) {
    return Stream.value(const <GroupCategoryAxis>[]);
  }

  final latestAxesByUserID = <String, List<GroupCategoryAxis>>{};
  final subscriptions =
      <StreamSubscription<QuerySnapshot<GroupCategoryAxis>>>[];
  late final StreamController<List<GroupCategoryAxis>> controller;

  void emitCombinedAxes() {
    if (latestAxesByUserID.length != uniqueMemberUserIDs.length) {
      return;
    }
    final axes =
        latestAxesByUserID.values.expand((axes) => axes).toList()
          ..sort((left, right) {
            final orderComparison = left.order.compareTo(right.order);
            return orderComparison != 0
                ? orderComparison
                : left.id.compareTo(right.id);
          });
    controller.add(axes);
  }

  controller = StreamController<List<GroupCategoryAxis>>(
    onListen: () {
      for (final memberUserID in uniqueMemberUserIDs) {
        subscriptions.add(
          database
              .categoryAxesReference()
              .where(
                GroupCategoryAxisFirestoreKeys.userID,
                isEqualTo: memberUserID,
              )
              .orderBy(GroupCategoryAxisFirestoreKeys.order)
              .snapshots()
              .listen((snapshot) {
                latestAxesByUserID[memberUserID] =
                    snapshot.docs.map((doc) => doc.data()).toList();
                emitCombinedAxes();
              }, onError: controller.addError),
        );
      }
    },
    onCancel: () async {
      await Future.wait(
        subscriptions.map((subscription) => subscription.cancel()),
      );
    },
  );
  return controller.stream;
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

@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupCategory>> groupCategories(
  Ref ref, {
  required String groupID,
  required String categoryAxisID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  final currentUserID = ref.watch(currentUserIDProvider);
  // ログアウト・ユーザー切替直後のティアダウン中に古い uid でクエリしないよう、
  // uid が無い間は Firestore を触らず空リストを流す。
  if (currentUserID == null) {
    return Stream.value(const <GroupCategory>[]);
  }
  return database
      .categoriesReference(categoryAxisID: categoryAxisID)
      .where(GroupCategoryFirestoreKeys.userID, isEqualTo: currentUserID)
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
    final batch = firestore.batch();
    batch.set(docRef, category, SetOptions(merge: true));
    _incrementCategoryRevision(
      batch: batch,
      database: database,
      categoryAxisID: categoryAxisID,
    );
    await batch.commit();
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
    final batch = firestore.batch();
    batch.set(docRef, category, SetOptions(merge: true));
    _incrementCategoryRevision(
      batch: batch,
      database: database,
      categoryAxisID: categoryAxisID,
    );
    await batch.commit();
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
    final batch = firestore.batch();
    batch.delete(docRef);
    _incrementCategoryRevision(
      batch: batch,
      database: database,
      categoryAxisID: categoryAxisID,
    );
    await batch.commit();
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
    if (categories.length > 499) {
      throw StateError('カテゴリ更新の書き込み件数が上限の500件を超えています');
    }
    final batch = firestore.batch();

    for (final category in categories) {
      final docRef = database.categoryReference(
        categoryAxisID: categoryAxisID,
        categoryID: category.id,
      );
      batch.set(docRef, category, SetOptions(merge: true));
    }

    if (categories.isNotEmpty) {
      _incrementCategoryRevision(
        batch: batch,
        database: database,
        categoryAxisID: categoryAxisID,
      );
    }

    await batch.commit();
  }
}

void _incrementCategoryRevision({
  required WriteBatch batch,
  required GroupDatabase database,
  required String categoryAxisID,
}) {
  // カテゴリ本体と同じ原子的書き込みで世代を進め、取り込み処理が事前読取後の
  // 競合を検出できるようにする。
  batch.update(database.categoryAxisReference(categoryAxisID: categoryAxisID), {
    GroupCategoryAxisFirestoreKeys.categoryRevision: FieldValue.increment(1),
  });
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryBatchUpdate groupCategoryBatchUpdate(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryBatchUpdate(database: database);
}

String _categoryImportHash(List<String> components) => sha256
    .convert(utf8.encode(jsonEncode(components)))
    .toString()
    .substring(0, 32);

/// 取り込み元の軸に対応するカテゴリIDの接頭辞。
///
/// 元ユーザーと元軸が同じなら毎回同じ値になるため、再取り込み時に以前のコピーを
/// 特定できる。表示名は変更され得るためIDの材料には含めない。
String importedGroupCategoryDocumentIDPrefix({
  required String sourceUserID,
  required String sourceGroupCategoryAxisID,
}) =>
    'imported_${_categoryImportHash([sourceUserID, sourceGroupCategoryAxisID])}_';

/// 取り込んだカテゴリの決定的なDocument ID。
///
/// 同じカテゴリを再度取り込むと同じ文書を更新し、元カテゴリの表示名変更でも
/// 別文書を作らない。
String importedGroupCategoryDocumentID({
  required String sourceUserID,
  required String sourceGroupCategoryAxisID,
  required String sourceGroupCategoryID,
}) =>
    '${importedGroupCategoryDocumentIDPrefix(sourceUserID: sourceUserID, sourceGroupCategoryAxisID: sourceGroupCategoryAxisID)}${_categoryImportHash([sourceGroupCategoryID])}';

/// 取込先にカテゴリ軸がまだ無い場合に作成する軸の決定的なDocument ID。
String importedGroupCategoryAxisDocumentID({
  required String destinationUserID,
  required String sourceUserID,
  required String sourceGroupCategoryAxisID,
}) =>
    'imported_${_categoryImportHash([destinationUserID, sourceUserID, sourceGroupCategoryAxisID])}';

/// 初回は取込先にあるカテゴリの後ろへ配置し、再取り込みでは既存ブロックの
/// 開始位置と元の相対順序を維持する。
List<GroupCategory> buildImportedGroupCategories({
  required String groupID,
  required String destinationUserID,
  required String destinationGroupCategoryAxisID,
  required GroupCategoryAxis sourceGroupCategoryAxis,
  required List<GroupCategory> sourceCategories,
  required List<GroupCategory> destinationCategories,
  required DateTime updatedDateTime,
}) {
  final importedDocumentIDPrefix = importedGroupCategoryDocumentIDPrefix(
    sourceUserID: sourceGroupCategoryAxis.userID,
    sourceGroupCategoryAxisID: sourceGroupCategoryAxis.id,
  );
  final importedDestinationCategories =
      destinationCategories
          .where((category) => category.id.startsWith(importedDocumentIDPrefix))
          .toList();
  final otherDestinationCategories =
      destinationCategories
          .where(
            (category) => !category.id.startsWith(importedDocumentIDPrefix),
          )
          .toList();
  final sourceDefaultOrderRanks = _categoryRanksByOrder(
    categories: sourceCategories,
    orderOf: (category) => category.order,
  );
  final defaultOrderStart =
      importedDestinationCategories.isNotEmpty
          ? importedDestinationCategories
              .map((category) => category.order)
              .reduce((minimum, order) => order < minimum ? order : minimum)
          : otherDestinationCategories.fold<int>(
                -1,
                (maximum, category) =>
                    category.order > maximum ? category.order : maximum,
              ) +
              1;
  final shoppingLocationIDs = <String>{
    for (final category in sourceCategories) ...category.locationOrders.keys,
    for (final category in destinationCategories)
      ...category.locationOrders.keys,
  };
  final sourceLocationOrderRanks = {
    for (final shoppingLocationID in shoppingLocationIDs)
      shoppingLocationID: _categoryRanksByOrder(
        categories: sourceCategories,
        orderOf:
            (category) =>
                category.locationOrders[shoppingLocationID] ?? category.order,
      ),
  };
  final locationOrderStarts = {
    for (final shoppingLocationID in shoppingLocationIDs)
      shoppingLocationID:
          importedDestinationCategories.isNotEmpty
              ? importedDestinationCategories
                  .map(
                    (category) =>
                        category.locationOrders[shoppingLocationID] ??
                        category.order,
                  )
                  .reduce((minimum, order) => order < minimum ? order : minimum)
              : otherDestinationCategories.fold<int>(-1, (maximum, category) {
                    final order =
                        category.locationOrders[shoppingLocationID] ??
                        category.order;
                    return order > maximum ? order : maximum;
                  }) +
                  1,
  };
  final destinationCategoriesByID = {
    for (final category in destinationCategories) category.id: category,
  };

  return sourceCategories.map((sourceCategory) {
    final importedDocumentID = importedGroupCategoryDocumentID(
      sourceUserID: sourceGroupCategoryAxis.userID,
      sourceGroupCategoryAxisID: sourceGroupCategoryAxis.id,
      sourceGroupCategoryID: sourceCategory.id,
    );
    final existingCategory = destinationCategoriesByID[importedDocumentID];
    return sourceCategory.copyWith(
      id: importedDocumentID,
      groupID: groupID,
      userID: destinationUserID,
      groupCategoryAxisID: destinationGroupCategoryAxisID,
      // 他メンバーの書いた正規表現を取込先の build 内で同期的に照合すると、
      // 壊滅的なバックトラック (ReDoS) で取込先の買い物リストが固まり得るため持ち込まない。
      keywords:
          sourceCategory.keywords
              .where(
                (keyword) =>
                    keyword.matchingType !=
                    GroupCategoryKeywordMatchingType.regex,
              )
              .toList(),
      order: defaultOrderStart + sourceDefaultOrderRanks[sourceCategory.id]!,
      locationOrders: {
        for (final shoppingLocationID in shoppingLocationIDs)
          shoppingLocationID:
              locationOrderStarts[shoppingLocationID]! +
              sourceLocationOrderRanks[shoppingLocationID]![sourceCategory.id]!,
      },
      createdDateTime: existingCategory?.createdDateTime,
      updatedDateTime: updatedDateTime,
      serverCreatedDateTime: existingCategory?.serverCreatedDateTime,
      serverUpdatedDateTime: null,
    );
  }).toList();
}

Map<String, int> _categoryRanksByOrder({
  required List<GroupCategory> categories,
  required int Function(GroupCategory category) orderOf,
}) {
  final sortedCategories = [...categories]..sort((left, right) {
    final orderComparison = orderOf(left).compareTo(orderOf(right));
    return orderComparison != 0 ? orderComparison : left.id.compareTo(right.id);
  });
  return {
    for (final (index, category) in sortedCategories.indexed)
      category.id: index,
  };
}

/// 再取り込みで対象ブロックの幅が変わる場合に、対象位置以降を連続配置し直す。
///
/// 初回取り込みでは対象ブロックが取込先末尾に追加されるため移動対象は無い。
List<GroupCategory> buildShiftedDestinationCategoriesForImport({
  required GroupCategoryAxis sourceGroupCategoryAxis,
  required List<GroupCategory> destinationCategories,
  required List<GroupCategory> importedCategories,
  required DateTime updatedDateTime,
}) {
  final importedDocumentIDPrefix = importedGroupCategoryDocumentIDPrefix(
    sourceUserID: sourceGroupCategoryAxis.userID,
    sourceGroupCategoryAxisID: sourceGroupCategoryAxis.id,
  );
  final previousImportedCategories =
      destinationCategories
          .where((category) => category.id.startsWith(importedDocumentIDPrefix))
          .toList();
  if (previousImportedCategories.isEmpty) {
    return const [];
  }
  final otherDestinationCategories = destinationCategories.where(
    (category) => !category.id.startsWith(importedDocumentIDPrefix),
  );
  final previousDefaultOrderMinimum = previousImportedCategories
      .map((category) => category.order)
      .reduce((minimum, order) => order < minimum ? order : minimum);
  final defaultOrderRanks = _categoryRanksByOrder(
    categories:
        otherDestinationCategories
            .where((category) => category.order >= previousDefaultOrderMinimum)
            .toList(),
    orderOf: (category) => category.order,
  );
  final shoppingLocationIDs = <String>{
    for (final category in destinationCategories)
      ...category.locationOrders.keys,
    for (final category in importedCategories) ...category.locationOrders.keys,
  };
  final previousLocationOrderMinimums = {
    for (final shoppingLocationID in shoppingLocationIDs)
      shoppingLocationID: _minimumLocationOrder(
        categories: previousImportedCategories,
        shoppingLocationID: shoppingLocationID,
      ),
  };
  final locationOrderRanks = {
    for (final shoppingLocationID in shoppingLocationIDs)
      shoppingLocationID: _categoryRanksByOrder(
        categories:
            otherDestinationCategories.where((category) {
              final order =
                  category.locationOrders[shoppingLocationID] ?? category.order;
              return order >=
                  previousLocationOrderMinimums[shoppingLocationID]!;
            }).toList(),
        orderOf:
            (category) =>
                category.locationOrders[shoppingLocationID] ?? category.order,
      ),
  };

  return [
    for (final category in otherDestinationCategories)
      if (_repositionDestinationCategoryAfterImportedBlock(
            category: category,
            previousDefaultOrderMinimum: previousDefaultOrderMinimum,
            importedCategoryCount: importedCategories.length,
            defaultOrderRanks: defaultOrderRanks,
            previousLocationOrderMinimums: previousLocationOrderMinimums,
            locationOrderRanks: locationOrderRanks,
            updatedDateTime: updatedDateTime,
          )
          case final shiftedCategory?)
        shiftedCategory,
  ];
}

GroupCategory? _repositionDestinationCategoryAfterImportedBlock({
  required GroupCategory category,
  required int previousDefaultOrderMinimum,
  required int importedCategoryCount,
  required Map<String, int> defaultOrderRanks,
  required Map<String, int> previousLocationOrderMinimums,
  required Map<String, Map<String, int>> locationOrderRanks,
  required DateTime updatedDateTime,
}) {
  final shiftedOrder =
      category.order >= previousDefaultOrderMinimum
          ? previousDefaultOrderMinimum +
              importedCategoryCount +
              defaultOrderRanks[category.id]!
          : category.order;
  final shiftedLocationOrders = {...category.locationOrders};
  for (final shoppingLocationID in previousLocationOrderMinimums.keys) {
    final currentLocationOrder =
        category.locationOrders[shoppingLocationID] ?? category.order;
    final shiftedLocationOrder =
        currentLocationOrder >=
                previousLocationOrderMinimums[shoppingLocationID]!
            ? previousLocationOrderMinimums[shoppingLocationID]! +
                importedCategoryCount +
                locationOrderRanks[shoppingLocationID]![category.id]!
            : currentLocationOrder;
    if (category.locationOrders.containsKey(shoppingLocationID) ||
        shiftedLocationOrder != shiftedOrder) {
      shiftedLocationOrders[shoppingLocationID] = shiftedLocationOrder;
    }
  }
  if (shiftedOrder == category.order &&
      _intMapsEqual(shiftedLocationOrders, category.locationOrders)) {
    return null;
  }
  return category.copyWith(
    order: shiftedOrder,
    locationOrders: shiftedLocationOrders,
    updatedDateTime: updatedDateTime,
    serverUpdatedDateTime: null,
  );
}

bool _intMapsEqual(Map<String, int> left, Map<String, int> right) {
  if (left.length != right.length) {
    return false;
  }
  return left.entries.every((entry) => right[entry.key] == entry.value);
}

int _minimumLocationOrder({
  required List<GroupCategory> categories,
  required String shoppingLocationID,
}) =>
    categories.isEmpty
        ? 0
        : categories
            .map(
              (category) =>
                  category.locationOrders[shoppingLocationID] ?? category.order,
            )
            .reduce((minimum, order) => order < minimum ? order : minimum);

/// 同じグループの別メンバーが持つカテゴリ設定を、自分のカテゴリ設定へ取り込む。
///
/// 個人所有モデルを維持するため元文書は直接編集せず、取込先ユーザー所有の文書を
/// 作成する。元ユーザー・元軸・元カテゴリIDから決定したDocument IDを使うため、
/// 再実行は新規作成ではなく同じ文書の更新になり冪等である。元側で削除された
/// カテゴリは、同じ決定的ID接頭辞を持つ取込済み文書から削除して同期する。
class GroupCategoryImportFromMember {
  final GroupDatabase database;

  GroupCategoryImportFromMember({required this.database});

  Future<int> call({
    required String destinationUserID,
    required GroupCategoryAxis sourceGroupCategoryAxis,
    required GroupCategoryAxis? destinationGroupCategoryAxis,
  }) async {
    if (sourceGroupCategoryAxis.groupID != database.groupID) {
      throw ArgumentError.value(
        sourceGroupCategoryAxis.groupID,
        'sourceGroupCategoryAxis.groupID',
      );
    }
    if (sourceGroupCategoryAxis.userID == destinationUserID) {
      throw ArgumentError('自分のカテゴリ設定は取り込み元に指定できません');
    }
    if (destinationGroupCategoryAxis != null &&
        (destinationGroupCategoryAxis.groupID != database.groupID ||
            destinationGroupCategoryAxis.userID != destinationUserID)) {
      throw ArgumentError('取込先には自分が所有するカテゴリ軸を指定してください');
    }

    final sourceCategories =
        (await database
                .categoriesReference(categoryAxisID: sourceGroupCategoryAxis.id)
                .where(
                  GroupCategoryFirestoreKeys.userID,
                  isEqualTo: sourceGroupCategoryAxis.userID,
                )
                .orderBy(GroupCategoryFirestoreKeys.order)
                .get())
            .docs
            .map((doc) => doc.data())
            .toList();

    final destinationAxis =
        destinationGroupCategoryAxis ??
        _buildImportedAxis(
          destinationUserID: destinationUserID,
          sourceGroupCategoryAxis: sourceGroupCategoryAxis,
        );
    final destinationReference = database.categoriesReference(
      categoryAxisID: destinationAxis.id,
    );
    final int? expectedCategoryRevision;
    final List<GroupCategory> destinationCategories;
    if (destinationGroupCategoryAxis == null) {
      expectedCategoryRevision = null;
      destinationCategories = const [];
    } else {
      final destinationAxisSnapshot =
          await database
              .categoryAxisReference(categoryAxisID: destinationAxis.id)
              .get();
      final currentDestinationAxis = destinationAxisSnapshot.data();
      if (currentDestinationAxis == null ||
          currentDestinationAxis.userID != destinationUserID) {
        throw StateError('取込先のカテゴリ軸が見つかりません');
      }
      expectedCategoryRevision = currentDestinationAxis.categoryRevision;
      destinationCategories =
          (await destinationReference
                  .where(
                    GroupCategoryFirestoreKeys.userID,
                    isEqualTo: destinationUserID,
                  )
                  .get())
              .docs
              .map((doc) => doc.data())
              .toList();
    }
    final importedDocumentIDPrefix = importedGroupCategoryDocumentIDPrefix(
      sourceUserID: sourceGroupCategoryAxis.userID,
      sourceGroupCategoryAxisID: sourceGroupCategoryAxis.id,
    );
    final updatedDateTime = DateTime.now();
    final importedCategories = buildImportedGroupCategories(
      groupID: database.groupID,
      destinationUserID: destinationUserID,
      destinationGroupCategoryAxisID: destinationAxis.id,
      sourceGroupCategoryAxis: sourceGroupCategoryAxis,
      sourceCategories: sourceCategories,
      destinationCategories: destinationCategories,
      updatedDateTime: updatedDateTime,
    );
    final shiftedDestinationCategories =
        buildShiftedDestinationCategoriesForImport(
          sourceGroupCategoryAxis: sourceGroupCategoryAxis,
          destinationCategories: destinationCategories,
          importedCategories: importedCategories,
          updatedDateTime: updatedDateTime,
        );
    final importedDocumentIDs =
        importedCategories.map((category) => category.id).toSet();

    final staleImportedCategories =
        destinationCategories
            .where(
              (category) =>
                  category.id.startsWith(importedDocumentIDPrefix) &&
                  !importedDocumentIDs.contains(category.id),
            )
            .toList();
    final categoryOperationCount =
        importedCategories.length +
        shiftedDestinationCategories.length +
        staleImportedCategories.length;
    // 軸の作成または更新世代の加算も同じ原子的書き込みに含めるため、カテゴリ操作に
    // 使える上限は499件。超える場合は何も書き込まず停止する。
    if (categoryOperationCount > 499) {
      throw StateError('カテゴリ取り込みの書き込み件数が上限の500件を超えています');
    }

    if (expectedCategoryRevision == null) {
      final batch = firestore.batch();
      batch.set(
        database.categoryAxisReference(categoryAxisID: destinationAxis.id),
        destinationAxis.copyWith(categoryRevision: 1),
        SetOptions(
          mergeFields: const [
            'id',
            'groupID',
            'userID',
            'name',
            'order',
            'categoryRevision',
            'updatedDateTime',
            'serverUpdatedDateTime',
          ],
        ),
      );
      _writeImportedCategories(
        writer: _BatchCategoryImportWriter(batch: batch),
        database: database,
        destinationGroupCategoryAxisID: destinationAxis.id,
        importedCategories: importedCategories,
        shiftedDestinationCategories: shiftedDestinationCategories,
        staleImportedCategories: staleImportedCategories,
      );
      await batch.commit();
    } else {
      final destinationAxisReference = database.categoryAxisReference(
        categoryAxisID: destinationAxis.id,
      );
      await firestore.runTransaction((transaction) async {
        final currentDestinationAxis =
            (await transaction.get(destinationAxisReference)).data();
        if (currentDestinationAxis == null ||
            currentDestinationAxis.userID != destinationUserID) {
          throw StateError('取込先のカテゴリ軸が見つかりません');
        }
        if (currentDestinationAxis.categoryRevision !=
            expectedCategoryRevision) {
          throw StateError('カテゴリ設定が別の端末で変更されました。もう一度取り込んでください');
        }
        _writeImportedCategories(
          writer: _TransactionCategoryImportWriter(transaction: transaction),
          database: database,
          destinationGroupCategoryAxisID: destinationAxis.id,
          importedCategories: importedCategories,
          shiftedDestinationCategories: shiftedDestinationCategories,
          staleImportedCategories: staleImportedCategories,
        );
        transaction.update(destinationAxisReference, {
          GroupCategoryAxisFirestoreKeys.categoryRevision: FieldValue.increment(
            1,
          ),
        });
      });
    }
    return importedCategories.length;
  }

  GroupCategoryAxis _buildImportedAxis({
    required String destinationUserID,
    required GroupCategoryAxis sourceGroupCategoryAxis,
  }) {
    final destinationAxisID = importedGroupCategoryAxisDocumentID(
      destinationUserID: destinationUserID,
      sourceUserID: sourceGroupCategoryAxis.userID,
      sourceGroupCategoryAxisID: sourceGroupCategoryAxis.id,
    );
    return GroupCategoryAxis(
      id: destinationAxisID,
      groupID: database.groupID,
      userID: destinationUserID,
      name: sourceGroupCategoryAxis.name,
      order: 0,
      updatedDateTime: DateTime.now(),
      serverUpdatedDateTime: null,
    );
  }
}

abstract interface class _CategoryImportWriter {
  void set(DocumentReference<GroupCategory> reference, GroupCategory category);

  void delete(DocumentReference<GroupCategory> reference);
}

class _BatchCategoryImportWriter implements _CategoryImportWriter {
  final WriteBatch batch;

  _BatchCategoryImportWriter({required this.batch});

  @override
  void set(
    DocumentReference<GroupCategory> reference,
    GroupCategory category,
  ) => batch.set(reference, category, SetOptions(merge: true));

  @override
  void delete(DocumentReference<GroupCategory> reference) =>
      batch.delete(reference);
}

class _TransactionCategoryImportWriter implements _CategoryImportWriter {
  final Transaction transaction;

  _TransactionCategoryImportWriter({required this.transaction});

  @override
  void set(
    DocumentReference<GroupCategory> reference,
    GroupCategory category,
  ) => transaction.set(reference, category, SetOptions(merge: true));

  @override
  void delete(DocumentReference<GroupCategory> reference) =>
      transaction.delete(reference);
}

void _writeImportedCategories({
  required _CategoryImportWriter writer,
  required GroupDatabase database,
  required String destinationGroupCategoryAxisID,
  required List<GroupCategory> importedCategories,
  required List<GroupCategory> shiftedDestinationCategories,
  required List<GroupCategory> staleImportedCategories,
}) {
  for (final category in [
    ...importedCategories,
    ...shiftedDestinationCategories,
  ]) {
    writer.set(
      database.categoryReference(
        categoryAxisID: destinationGroupCategoryAxisID,
        categoryID: category.id,
      ),
      category,
    );
  }
  for (final category in staleImportedCategories) {
    writer.delete(
      database.categoryReference(
        categoryAxisID: destinationGroupCategoryAxisID,
        categoryID: category.id,
      ),
    );
  }
}

@Riverpod(dependencies: [groupDatabase])
GroupCategoryImportFromMember groupCategoryImportFromMember(
  Ref ref, {
  required String groupID,
}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return GroupCategoryImportFromMember(database: database);
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
    final axisRef = database.categoryAxisReference(
      categoryAxisID: categoryAxisID,
    );
    await firestore.runTransaction((transaction) async {
      await transaction.get(axisRef);
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
      transaction.update(axisRef, {
        GroupCategoryAxisFirestoreKeys.categoryRevision: FieldValue.increment(
          1,
        ),
      });
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
                .where(GroupCategoryFirestoreKeys.userID, isEqualTo: userID)
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
      final batch = firestore.batch();
      batch.set(docRef, category, SetOptions(merge: true));
      _incrementCategoryRevision(
        batch: batch,
        database: database,
        categoryAxisID: axisID,
      );
      await batch.commit();
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
      final axisRef = database.categoryAxisReference(categoryAxisID: axisID);
      // 同時編集でキーワードが消えないよう read-modify-write を transaction で行う
      // （firestore-transaction.md: group 配下の同時書き込み対策）。
      await firestore.runTransaction((transaction) async {
        await transaction.get(axisRef);
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
        transaction.update(axisRef, {
          GroupCategoryAxisFirestoreKeys.categoryRevision: FieldValue.increment(
            1,
          ),
        });
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
/// カテゴリをまたぐ D&D・アイテム詳細でのカテゴリ選択で「別カテゴリへ移す」永続化に使う。
/// アイテムはカテゴリIDを持たず message とキーワードのマッチで分類されるため、同名(message)の
/// アイテムは同じカテゴリへ分類される(キーワードは message 単位)。手動の partial/regex は変更
/// しない(削除対象は exact のみ)が、分類エンジン [findMatchingCategoryID] が exact を partial/regex
/// より優先するため、別カテゴリに partial/regex マッチがあっても移動先へ確実に分類される。
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
      final axisRef = database.categoryAxisReference(
        categoryAxisID: categoryAxisID,
      );
      await transaction.get(axisRef);
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

      var hasChanges = false;
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
        hasChanges = true;
      }
      if (hasChanges) {
        transaction.update(axisRef, {
          GroupCategoryAxisFirestoreKeys.categoryRevision: FieldValue.increment(
            1,
          ),
        });
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
