import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../../../helpers/localized_test_app.dart';

GroupCategory _category({
  required String id,
  required String name,
  required int order,
  required List<String> keywords,
}) => GroupCategory(
  id: id,
  groupID: mockGroupID,
  userID: mockUserID,
  groupCategoryAxisID: mockCategoryAxisID,
  name: name,
  order: order,
  locationOrders: const {},
  keywords: [
    for (final keyword in keywords)
      GroupCategoryKeyword(
        keyword: keyword,
        matchingType: GroupCategoryKeywordMatchingType.exact,
      ),
  ],
  color: null,
  iconName: null,
);

GroupShoppingListItem _item({
  required String id,
  required String message,
  required int order,
}) => GroupShoppingListItem(
  id: id,
  groupID: mockGroupID,
  shoppingListID: mockShoppingListID,
  userID: mockUserID,
  message: message,
  order: order,
  checkedByUserID: null,
  color: null,
  description: null,
  imageURL: null,
  lastEditedByUserID: null,
);

class _SpyMoveItemCategoryKeyword extends MoveItemCategoryKeyword {
  _SpyMoveItemCategoryKeyword()
    : super(database: GroupDatabase(groupID: mockGroupID));

  final List<({String itemMessage, String? destinationCategoryID})> calls = [];

  @override
  Future<void> call({
    required String categoryAxisID,
    required String itemMessage,
    required String? destinationCategoryID,
    required List<GroupCategory> categories,
  }) async {
    calls.add((
      itemMessage: itemMessage,
      destinationCategoryID: destinationCategoryID,
    ));
  }
}

class _SpyBatchUpdate extends ShoppingListItemBatchUpdate {
  _SpyBatchUpdate() : super(database: GroupDatabase(groupID: mockGroupID));

  final List<List<GroupShoppingListItem>> batches = [];

  @override
  Future<void> call({
    required String shoppingListID,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    batches.add(shoppingListItems);
  }
}

void main() {
  // 野菜: にんじん/トマト, 肉: 牛肉
  final categories = [
    _category(id: 'cat-veg', name: '野菜', order: 0, keywords: ['にんじん', 'トマト']),
    _category(id: 'cat-meat', name: '肉', order: 1, keywords: ['牛肉']),
  ];
  final items = [
    _item(id: 'item-carrot', message: 'にんじん', order: 0),
    _item(id: 'item-tomato', message: 'トマト', order: 1),
    _item(id: 'item-beef', message: '牛肉', order: 2),
  ];

  Future<({_SpyMoveItemCategoryKeyword move, _SpyBatchUpdate batch})> pump(
    WidgetTester tester,
  ) async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final spyMove = _SpyMoveItemCategoryKeyword();
    final spyBatch = _SpyBatchUpdate();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...previewProviderOverrides(sharedPreferences: sharedPreferences),
          groupCategoriesProvider(
            groupID: mockGroupID,
            categoryAxisID: mockCategoryAxisID,
          ).overrideWith((ref) => Stream.value(categories)),
          textShoppingListItemsProvider(
            groupID: mockGroupID,
            shoppingListID: mockShoppingListID,
          ).overrideWith((ref) => Stream.value(items)),
          moveItemCategoryKeywordProvider(
            groupID: mockGroupID,
          ).overrideWith((ref) => spyMove),
          shoppingListItemBatchUpdateProvider(
            groupID: mockGroupID,
          ).overrideWith((ref) => spyBatch),
        ],
        child: localizedTestApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: Scaffold(
            body: ShoppingListItems(
              groupID: mockGroupID,
              shoppingListID: mockShoppingListID,
              shoppingLocationID: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (move: spyMove, batch: spyBatch);
  }

  /// 長押し→指定オフセットへドラッグ→離す。
  /// 行の中央は TextField があり長押しがそちらに取られるため、左端(行パディング)を掴む。
  Future<void> longPressDrag(
    WidgetTester tester,
    Finder from,
    double dy,
  ) async {
    final rect = tester.getRect(from);
    final start = Offset(rect.left + 6, rect.center.dy);
    final gesture = await tester.startGesture(start);
    await tester.pump(
      const Duration(milliseconds: 600),
    ); // 長押し成立(>kLongPressTimeout)
    await tester.pump(const Duration(milliseconds: 100));
    // 1 ステップ目は touch slop を超えるため少し大きめに(ドラッグ方向へ)動かして始動する。
    final kick = dy.isNegative ? -24.0 : 24.0;
    await gesture.moveBy(Offset(0, kick));
    await tester.pump(const Duration(milliseconds: 30));
    final remaining = dy - kick;
    const steps = 10;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(0, remaining / steps));
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('ヘッダーとアイテムが 1 つの ReorderableListView に並ぶ', (tester) async {
    await pump(tester);
    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('にんじん'), findsOneWidget);
    expect(find.text('牛肉'), findsOneWidget);
  });

  testWidgets('同一カテゴリ内ドラッグは order のみ更新しカテゴリ移動は呼ばない', (tester) async {
    final spies = await pump(tester);
    // トマト(野菜の2番目)を上へドラッグして にんじん の上へ。野菜カテゴリ内に留まる。
    await longPressDrag(
      tester,
      find.byKey(const ValueKey('item_item-tomato')),
      -60,
    );
    // onReorder が発火し order は永続化される。
    expect(
      spies.batch.batches,
      isNotEmpty,
      reason: '同一カテゴリ内ドラッグで onReorder が発火していない(=ドラッグ機構が起動していない)',
    );
    // 同一カテゴリ内なのでキーワード付け替え(カテゴリ移動)は呼ばれない。
    expect(
      spies.move.calls,
      isEmpty,
      reason: '同一カテゴリ内なのに moveItemCategoryKeyword が呼ばれている',
    );
  });

  testWidgets('にんじんを肉セクションへドラッグすると 肉(cat-meat) へ移動する', (tester) async {
    final spies = await pump(tester);
    await longPressDrag(
      tester,
      find.byKey(const ValueKey('item_item-carrot')),
      400,
    );
    expect(
      spies.move.calls,
      isNotEmpty,
      reason: 'カテゴリ間ドラッグで moveItemCategoryKeyword が呼ばれていない',
    );
    expect(spies.move.calls.last.destinationCategoryID, 'cat-meat');
  });

  testWidgets('カテゴリ間移動後、stream 未更新でも楽観的に 肉 セクションへ表示される', (tester) async {
    // stream(Stream.value)は再 emit しないため、楽観状態が破棄されず維持される。
    // にんじんが 肉 ヘッダーより下＝肉セクション内に来ていれば楽観反映できている。
    await pump(tester);
    await longPressDrag(
      tester,
      find.byKey(const ValueKey('item_item-carrot')),
      400,
    );
    expect(
      tester.getCenter(find.text('にんじん')).dy,
      greaterThan(tester.getCenter(find.text('肉')).dy),
      reason: 'にんじんが 肉 ヘッダーより上にある＝楽観反映されず元の 野菜 セクションのまま',
    );
  });

  testWidgets('同一カテゴリ内移動後、stream 未更新でも楽観的に並びが入れ替わる', (tester) async {
    // トマト(野菜の2番目)を上へドラッグして にんじん の上へ。楽観 order で並びが先に反映される。
    await pump(tester);
    await longPressDrag(
      tester,
      find.byKey(const ValueKey('item_item-tomato')),
      -60,
    );
    expect(
      tester.getCenter(find.text('トマト')).dy,
      lessThan(tester.getCenter(find.text('にんじん')).dy),
      reason: 'トマトが にんじん より下のまま＝楽観 order が反映されていない',
    );
  });
}
