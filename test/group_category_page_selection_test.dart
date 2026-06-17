import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testUserID = 'test-user-001';
const _testShoppingListID = 'test-list-001';

List<GroupCategory> _testCategories() => const [
      GroupCategory(
        id: 'cat-001',
        groupID: _testGroupID,
        userID: _testUserID,
        groupCategoryAxisID: _testCategoryAxisID,
        name: '食品',
        order: 0,
        locationOrders: {},
        keywords: [],
        color: null,
        iconName: null,
      ),
      GroupCategory(
        id: 'cat-002',
        groupID: _testGroupID,
        userID: _testUserID,
        groupCategoryAxisID: _testCategoryAxisID,
        name: '飲料',
        order: 1,
        locationOrders: {},
        keywords: [],
        color: null,
        iconName: null,
      ),
    ];

GroupShoppingListItem _testItem({required String message}) =>
    GroupShoppingListItem(
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

/// カテゴリ画面表示に必要な最小限の provider overrides。
List<Override> _baseOverrides() => [
      customerInfoProvider
          .overrideWith((ref) => const Stream<CustomerInfo>.empty()),
      userDatabaseProvider
          .overrideWith((ref) => UserDatabase(userID: _testUserID)),
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
      ).overrideWith((ref) => Stream.value(_testCategories())),
      shoppingLocationsProvider(groupID: _testGroupID)
          .overrideWith((ref) => Stream.value(const [])),
    ];

/// 選択モードで呼ばれたカテゴリ付け替えの引数を記録するスパイ。
class _SpyMoveItemCategoryKeyword extends MoveItemCategoryKeyword {
  _SpyMoveItemCategoryKeyword()
      : super(database: GroupDatabase(groupID: _testGroupID));

  int callCount = 0;
  String? calledDestinationCategoryID;
  String? calledItemMessage;

  @override
  Future<void> call({
    required String categoryAxisID,
    required String itemMessage,
    required String? destinationCategoryID,
    required List<GroupCategory> categories,
  }) async {
    callCount += 1;
    calledDestinationCategoryID = destinationCategoryID;
    calledItemMessage = itemMessage;
  }
}

void main() {
  group('GroupCategoryPage カテゴリ選択モード', () {
    testWidgets('選択モードではタイトルが「カテゴリを選択」になり、行タップでカテゴリ付け替えが呼ばれる', (tester) async {
      final spy = _SpyMoveItemCategoryKeyword();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._baseOverrides(),
            moveItemCategoryKeywordProvider(groupID: _testGroupID)
                .overrideWith((ref) => spy),
          ],
          child: MaterialApp(
            theme: buildAppTheme(accent: AccentPreset.shu),
            home: GroupCategoryPage(
              groupID: _testGroupID,
              selectionForItem: _testItem(message: 'juice'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 選択モードのタイトル
      expect(find.text('カテゴリを選択'), findsOneWidget);

      // 「飲料」(cat-002) 行をタップ
      await tester.tap(find.text('飲料'));
      await tester.pumpAndSettle();

      expect(spy.callCount, 1);
      expect(spy.calledDestinationCategoryID, 'cat-002');
      expect(spy.calledItemMessage, 'juice');
    });

    testWidgets('通常モードではタイトルが「カテゴリ」で、行タップしてもカテゴリ付け替えは呼ばれない', (tester) async {
      final spy = _SpyMoveItemCategoryKeyword();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._baseOverrides(),
            moveItemCategoryKeywordProvider(groupID: _testGroupID)
                .overrideWith((ref) => spy),
          ],
          child: MaterialApp(
            theme: buildAppTheme(accent: AccentPreset.shu),
            home: const GroupCategoryPage(groupID: _testGroupID),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 通常モードのタイトル
      expect(find.text('カテゴリ'), findsOneWidget);
      expect(find.text('カテゴリを選択'), findsNothing);

      // 行をタップしても onTap は無効（カテゴリ付け替えは呼ばれない）
      await tester.tap(find.text('飲料'));
      await tester.pumpAndSettle();

      expect(spy.callCount, 0);
    });
  });
}
