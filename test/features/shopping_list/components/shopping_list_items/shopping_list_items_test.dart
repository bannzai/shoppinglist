import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool sortByCategory,
  bool showChecked = true,
}) async {
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
            sortByCategory: sortByCategory,
            showChecked: showChecked,
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
          showChecked: true,
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
            sortByCategory: true,
            showChecked: true,
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
      await _pump(tester, sortByCategory: false);
      expect(
        tester
            .widget<ReorderableList>(find.byType(ReorderableList))
            .keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );
    });

    testWidgets('カテゴリ分類表示の ListView が onDrag で閉じる', (tester) async {
      await _pump(tester, sortByCategory: true);
      expect(
        tester
            .widget<ListView>(find.byType(ListView).first)
            .keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );
    });
  });

  group('ShoppingListItems: 自動カテゴリ分けボタン', () {
    // mockCategories はキーワードが空なので、全アイテムが「未分類」になる。
    testWidgets('カテゴリ表示時、未分類アイテムがあればボタンが出る', (tester) async {
      await _pump(tester, sortByCategory: true);
      expect(find.textContaining('自動でカテゴリ分け'), findsOneWidget);
    });

    testWidgets('カテゴリ表示OFF（フラット・軸あり）ではボタンが出ない', (tester) async {
      await _pump(tester, sortByCategory: false);
      expect(find.textContaining('自動でカテゴリ分け'), findsNothing);
    });

    testWidgets('入力中の空行のみのときはボタンが出ない', (tester) async {
      await _pumpWithItems(tester, items: [
        _item(id: 'input-row-001', message: '', order: 0),
      ]);
      expect(find.textContaining('自動でカテゴリ分け'), findsNothing);
    });

    testWidgets('入力中の空行は件数カウントから除外される', (tester) async {
      await _pumpWithItems(tester, items: [
        _item(id: 'confirmed-001', message: '牛乳', order: 0),
        _item(id: 'input-row-001', message: '', order: 1),
      ]);
      expect(find.text('自動でカテゴリ分け（1件）'), findsOneWidget);
    });
  });

  group('ShoppingListItems: チェック済みフィルター', () {
    // mockShoppingListItems は 牛乳(unchecked)/卵(checked)/食パン(unchecked)。
    testWidgets('showChecked: true ではチェック済みアイテムも表示される', (tester) async {
      await _pump(tester, sortByCategory: false, showChecked: true);
      expect(find.text('牛乳'), findsOneWidget);
      expect(find.text('卵'), findsOneWidget);
      expect(find.text('食パン'), findsOneWidget);
    });

    testWidgets('showChecked: false ではチェック済みアイテムが一覧から消える', (tester) async {
      await _pump(tester, sortByCategory: false, showChecked: false);
      expect(find.text('牛乳'), findsOneWidget);
      expect(find.text('卵'), findsNothing);
      expect(find.text('食パン'), findsOneWidget);
    });
  });
}
