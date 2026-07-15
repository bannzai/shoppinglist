import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testUserID = 'test-user-001';
const _testShoppingListID = 'test-list-001';

GroupCategory _category({
  required String id,
  required String name,
  required int order,
  List<GroupCategoryKeyword> keywords = const [],
}) => GroupCategory(
  id: id,
  groupID: _testGroupID,
  userID: _testUserID,
  groupCategoryAxisID: _testCategoryAxisID,
  name: name,
  order: order,
  locationOrders: const {},
  keywords: keywords,
  color: null,
  iconName: null,
);

GroupCategoryKeyword _partial(String keyword) => GroupCategoryKeyword(
  keyword: keyword,
  matchingType: GroupCategoryKeywordMatchingType.partial,
);

GroupShoppingListItem _item({required String message}) => GroupShoppingListItem(
  id: 'item-001',
  groupID: _testGroupID,
  shoppingListID: _testShoppingListID,
  userID: _testUserID,
  message: message,
  order: 0,
  description: null,
  color: null,
  imageURL: null,
  checkedByUserID: null,
  lastEditedByUserID: null,
);

/// アイテム詳細シートを模した host。実シートと同じく findMatchingCategoryID で
/// 所属カテゴリを計算して表示し、ボタンから選択モードの GroupCategoryPage を push する。
class _DetailHost extends ConsumerWidget {
  final GroupShoppingListItem item;
  const _DetailHost({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref
            .watch(
              groupCategoriesProvider(
                groupID: _testGroupID,
                categoryAxisID: _testCategoryAxisID,
              ),
            )
            .valueOrNull ??
        const <GroupCategory>[];
    final matched = categories.firstWhereOrNull(
      (category) =>
          category.id ==
          findMatchingCategoryID(item: item, categories: categories),
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('matched: ${matched?.name ?? '未分類'}'),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GroupCategoryPage(
                            groupID: _testGroupID,
                            selectionForItem: item,
                          ),
                    ),
                  ),
              child: const Text('カテゴリを選択'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 実際の Firestore を伴わずに「移動先へ exact キーワードを付け替え、stream を再 emit する」
/// 振る舞いを再現するフェイク。MoveItemCategoryKeyword と同じ付け替えロジックを使い、
/// 結果を controller に流すことで、書き込み後に groupCategoriesProvider が更新される実挙動を再現する。
class _FakeMoveItemCategoryKeyword extends MoveItemCategoryKeyword {
  _FakeMoveItemCategoryKeyword({
    required this.controller,
    required this.current,
  }) : super(database: GroupDatabase(groupID: _testGroupID));

  final StreamController<List<GroupCategory>> controller;
  List<GroupCategory> current;

  @override
  Future<void> call({
    required String categoryAxisID,
    required String itemMessage,
    required String? destinationCategoryID,
    required List<GroupCategory> categories,
  }) async {
    current = [
      for (final category in current)
        category.copyWith(
          keywords:
              keywordsAfterItemMove(
                category: category,
                itemMessage: itemMessage,
                destinationCategoryID: destinationCategoryID,
              ) ??
              category.keywords,
        ),
    ];
    controller.add(current);
    // 書き込み完了より後に stream emit が届く実挙動に寄せて、microtask 1 つ分ずらす。
    await Future<void>.delayed(Duration.zero);
  }
}

List<Override> _overrides({
  required StreamController<List<GroupCategory>> controller,
  required _FakeMoveItemCategoryKeyword fake,
}) => [
  customerInfoProvider.overrideWith(
    (ref) => const Stream<CustomerInfo>.empty(),
  ),
  currentUserIDProvider.overrideWithValue(_testUserID),
  groupCategoryAxesProvider(groupID: _testGroupID).overrideWith(
    (ref) => Stream.value(const [
      GroupCategoryAxis(
        id: _testCategoryAxisID,
        groupID: _testGroupID,
        userID: _testUserID,
        name: '売り場',
        order: 0,
      ),
    ]),
  ),
  groupCategoriesProvider(
    groupID: _testGroupID,
    categoryAxisID: _testCategoryAxisID,
  ).overrideWith((ref) => controller.stream),
  shoppingLocationsProvider(
    groupID: _testGroupID,
  ).overrideWith((ref) => Stream.value(const [])),
  moveItemCategoryKeywordProvider(
    groupID: _testGroupID,
  ).overrideWith((ref) => fake),
];

void main() {
  group('カテゴリ選択フロー（詳細→選択→pop→紐付け表示）', () {
    testWidgets('未分類アイテムを選択すると pop してカテゴリが紐づく', (tester) async {
      final controller = StreamController<List<GroupCategory>>.broadcast();
      addTearDown(controller.close);
      final initial = [
        _category(id: 'cat-001', name: '食品', order: 0),
        _category(id: 'cat-002', name: '飲料', order: 1),
      ];
      final fake = _FakeMoveItemCategoryKeyword(
        controller: controller,
        current: initial,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(controller: controller, fake: fake),
          child: MaterialApp(
            theme: buildAppTheme(accent: AccentPreset.shu),
            home: _DetailHost(item: _item(message: 'juice')),
          ),
        ),
      );
      controller.add(initial);
      await tester.pumpAndSettle();

      expect(find.text('matched: 未分類'), findsOneWidget);

      // 詳細から選択モードへ
      await tester.tap(find.text('カテゴリを選択'));
      await tester.pumpAndSettle();
      expect(find.text('飲料'), findsOneWidget);

      // 「飲料」を選択
      await tester.tap(find.text('飲料'));
      await tester.pumpAndSettle();

      // 選択画面が pop して詳細 host に戻っている
      expect(find.byType(GroupCategoryPage), findsNothing);
      // カテゴリが「飲料」に紐づいて表示される
      expect(find.text('matched: 飲料'), findsOneWidget);
    });

    testWidgets('別カテゴリに部分一致があってもアイテムは選択したカテゴリに紐づく', (tester) async {
      final controller = StreamController<List<GroupCategory>>.broadcast();
      addTearDown(controller.close);
      // 「食品」が部分一致 "ジュース" を持つため、初期状態で "オレンジジュース" は食品に分類される。
      final initial = [
        _category(
          id: 'cat-001',
          name: '食品',
          order: 0,
          keywords: [_partial('ジュース')],
        ),
        _category(id: 'cat-002', name: 'デザート', order: 1),
      ];
      final fake = _FakeMoveItemCategoryKeyword(
        controller: controller,
        current: initial,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(controller: controller, fake: fake),
          child: MaterialApp(
            theme: buildAppTheme(accent: AccentPreset.shu),
            home: _DetailHost(item: _item(message: 'オレンジジュース')),
          ),
        ),
      );
      controller.add(initial);
      await tester.pumpAndSettle();

      // 初期は部分一致で「食品」
      expect(find.text('matched: 食品'), findsOneWidget);

      await tester.tap(find.text('カテゴリを選択'));
      await tester.pumpAndSettle();
      expect(find.text('デザート'), findsOneWidget);

      // 「デザート」を選択 → exact キーワード "オレンジジュース" がデザートに付く
      await tester.tap(find.text('デザート'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupCategoryPage), findsNothing);
      // 選択した「デザート」に紐づくことを期待する（完全一致は部分一致より優先）。
      expect(find.text('matched: デザート'), findsOneWidget);
    });
  });
}
