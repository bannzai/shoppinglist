import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_button.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// カテゴリ軸なしテスト用のグループID。previewProviderOverrides が override 済みの
/// mockGroupID（軸あり）と重複 override しないよう専用IDにする。
const _noCategoryAxisGroupID = 'no-category-axis-group';

/// カテゴリ軸あり（previewProviderOverrides のデフォルト）で ShoppingListItems を pump する。
Future<void> _pump(WidgetTester tester) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: previewProviderOverrides(sharedPreferences: sharedPreferences),
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
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
}

/// カテゴリ軸なしのグループで ShoppingListItems を pump する（フラット表示になる）。
Future<void> _pumpFlat(WidgetTester tester) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...previewProviderOverrides(sharedPreferences: sharedPreferences),
        groupCategoryAxesProvider(groupID: _noCategoryAxisGroupID)
            .overrideWith((ref) => Stream.value(const <GroupCategoryAxis>[])),
        textShoppingListItemsProvider(
          groupID: _noCategoryAxisGroupID,
          shoppingListID: mockShoppingListID,
        ).overrideWith((ref) => Stream.value(mockShoppingListItems())),
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: ShoppingListItems(
            groupID: _noCategoryAxisGroupID,
            shoppingListID: mockShoppingListID,
            shoppingLocationID: null,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 空行除外テスト用のリストID。previewProviderOverrides が override 済みの
/// mockShoppingListID と重複 override しないよう専用IDにする。
const _customShoppingListID = 'input-row-test-shopping-list';

/// テスト用の最小構成アイテムを生成する。
GroupShoppingListItem _item({
  required String id,
  required String message,
  required int order,
}) =>
    GroupShoppingListItem(
      id: id,
      groupID: mockGroupID,
      shoppingListID: _customShoppingListID,
      userID: mockUserID,
      message: message,
      order: order,
      status: GroupShoppingListItemStatus.unchecked,
      checkedByUserID: null,
      color: null,
      description: null,
      imageURL: null,
      lastEditedByUserID: null,
    );

/// 任意のアイテムリストでカテゴリ表示の ShoppingListItems を pump する。
Future<void> _pumpWithItems(
  WidgetTester tester, {
  required List<GroupShoppingListItem> items,
}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...previewProviderOverrides(sharedPreferences: sharedPreferences),
        textShoppingListItemsProvider(
          groupID: mockGroupID,
          shoppingListID: _customShoppingListID,
        ).overrideWith((ref) => Stream.value(items)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: ShoppingListItems(
            groupID: mockGroupID,
            shoppingListID: _customShoppingListID,
            shoppingLocationID: null,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ShoppingListItems: スクロールでキーボードを閉じる', () {
    testWidgets('フラット表示の ReorderableList が onDrag で閉じる', (tester) async {
      await _pumpFlat(tester);
      expect(
        tester
            .widget<ReorderableList>(find.byType(ReorderableList))
            .keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );
    });

    testWidgets('カテゴリ分類表示の CustomScrollView が onDrag で閉じる', (tester) async {
      await _pump(tester);
      expect(
        tester
            .widget<CustomScrollView>(find.byType(CustomScrollView).first)
            .keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );
    });
  });

  group('ShoppingListItems: 自動カテゴリ分けボタン', () {
    // mockCategories はキーワードが空なので、全アイテムが「未分類」になる。
    testWidgets('カテゴリ軸ありで未分類アイテムがあればボタンが出る', (tester) async {
      await _pump(tester);
      expect(find.byType(AICategorizeButton), findsOneWidget);
    });

    testWidgets('カテゴリ軸なし（フラット表示）でもボタンが出る（AIが軸から作成）', (tester) async {
      await _pumpFlat(tester);
      expect(find.byType(AICategorizeButton), findsOneWidget);
    });

    testWidgets('入力中の空行のみのときはボタンが出ない', (tester) async {
      await _pumpWithItems(tester, items: [
        _item(id: 'input-row-001', message: '', order: 0),
      ]);
      expect(find.byType(AICategorizeButton), findsNothing);
    });

    testWidgets('入力中の空行と空白のみのアイテムは件数カウントから除外される', (tester) async {
      await _pumpWithItems(tester, items: [
        _item(id: 'confirmed-001', message: '牛乳', order: 0),
        _item(id: 'input-row-001', message: '', order: 1),
        _item(id: 'whitespace-001', message: '   ', order: 2),
      ]);
      final button =
          tester.widget<AICategorizeButton>(find.byType(AICategorizeButton));
      expect(button.uncategorizedItems.length, 1);
    });
  });

  group('ShoppingListItems: チェック済みアイテムの表示', () {
    // mockShoppingListItems は 牛乳(unchecked)/卵(checked)/食パン(unchecked)。
    // チェック済み表示の切り替えは Issue #373 で廃止し、常に全件表示する。
    testWidgets('チェック済みアイテムも常に表示される', (tester) async {
      await _pumpFlat(tester);
      expect(find.text('牛乳'), findsOneWidget);
      expect(find.text('卵'), findsOneWidget);
      expect(find.text('食パン'), findsOneWidget);
    });
  });
}
