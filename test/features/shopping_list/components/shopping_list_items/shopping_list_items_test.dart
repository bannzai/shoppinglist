import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_button.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_section_header.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
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

/// セクション並び替えテスト用のグループID・軸ID。previewProviderOverrides が override 済みの
/// mockGroupID（mockCategories は keywords 空）と重複 override しないよう専用IDにする。
const _sectionReorderGroupID = 'section-reorder-group';
const _sectionReorderAxisID = 'section-reorder-axis';

/// セクション並び替えテスト用に、指定キーワード(完全一致)を持つカテゴリを生成する。
GroupCategory _categoryWithKeywords({
  required String id,
  required String name,
  required int order,
  required List<String> keywords,
}) =>
    GroupCategory(
      id: id,
      groupID: _sectionReorderGroupID,
      userID: mockUserID,
      groupCategoryAxisID: _sectionReorderAxisID,
      name: name,
      order: order,
      locationOrders: {},
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

/// セクション並び替えテスト用の確定済みアイテムを生成する。
GroupShoppingListItem _sectionItem({
  required String id,
  required String message,
  required int order,
}) =>
    GroupShoppingListItem(
      id: id,
      groupID: _sectionReorderGroupID,
      shoppingListID: mockShoppingListID,
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

/// セクション並び替えの永続化呼び出しを記録するフェイク。
class _RecordingCategoryBatchUpdate extends GroupCategoryBatchUpdate {
  _RecordingCategoryBatchUpdate()
      : super(database: GroupDatabase(groupID: _sectionReorderGroupID));

  /// 最後に call へ渡された並び替え後のカテゴリリスト。未呼び出しなら null。
  List<GroupCategory>? lastCategories;

  /// 最後に call へ渡された軸ID。未呼び出しなら null。
  String? lastCategoryAxisID;

  @override
  Future<void> call({
    required String categoryAxisID,
    required List<GroupCategory> categories,
  }) async {
    lastCategoryAxisID = categoryAxisID;
    lastCategories = categories;
  }
}

/// 行編集の確定保存(フォーカス喪失保存)を記録するフェイク。
class _RecordingUpdateShoppingListItem extends UpdateShoppingListItem {
  _RecordingUpdateShoppingListItem()
      : super(database: GroupDatabase(groupID: _sectionReorderGroupID));

  /// 最後に保存されたアイテム。未呼び出しなら null。
  GroupShoppingListItem? lastItem;

  @override
  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String editedByUserID,
  }) async {
    lastItem = item;
  }
}

/// セクション並び替えテスト用の ShoppingListItems を pump する。
/// 食品(牛乳・卵・食パン)・日用品(洗剤)の2カテゴリ + 未分類(ガムテープ)の3セクション構成。
/// 食品を3件にして、ヘッダードラッグ proxy のプレビュー上限(先頭2件)を検証できるようにする。
Future<
    ({
      _RecordingCategoryBatchUpdate categoryBatch,
      _RecordingUpdateShoppingListItem itemUpdate,
    })> _pumpSectionReorder(WidgetTester tester) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final recorder = _RecordingCategoryBatchUpdate();
  final itemUpdateRecorder = _RecordingUpdateShoppingListItem();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...previewProviderOverrides(sharedPreferences: sharedPreferences),
        groupCategoryAxesProvider(groupID: _sectionReorderGroupID)
            .overrideWith((ref) => Stream.value([
                  const GroupCategoryAxis(
                    id: _sectionReorderAxisID,
                    groupID: _sectionReorderGroupID,
                    userID: mockUserID,
                    name: '売り場',
                    order: 0,
                  ),
                ])),
        groupCategoriesProvider(
          groupID: _sectionReorderGroupID,
          categoryAxisID: _sectionReorderAxisID,
        ).overrideWith((ref) => Stream.value([
              _categoryWithKeywords(
                  id: 'cat-food',
                  name: '食品',
                  order: 0,
                  keywords: ['牛乳', '卵', '食パン']),
              _categoryWithKeywords(
                  id: 'cat-daily', name: '日用品', order: 1, keywords: ['洗剤']),
            ])),
        textShoppingListItemsProvider(
          groupID: _sectionReorderGroupID,
          shoppingListID: mockShoppingListID,
        ).overrideWith((ref) => Stream.value([
              _sectionItem(id: 'item-milk', message: '牛乳', order: 0),
              _sectionItem(id: 'item-egg', message: '卵', order: 1),
              _sectionItem(id: 'item-bread', message: '食パン', order: 2),
              _sectionItem(id: 'item-soap', message: '洗剤', order: 3),
              _sectionItem(id: 'item-tape', message: 'ガムテープ', order: 4),
            ])),
        groupCategoryBatchUpdateProvider(groupID: _sectionReorderGroupID)
            .overrideWith((ref) => recorder),
        updateShoppingListItemProvider(groupID: _sectionReorderGroupID)
            .overrideWith((ref) => itemUpdateRecorder),
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: ShoppingListItems(
            groupID: _sectionReorderGroupID,
            shoppingListID: mockShoppingListID,
            shoppingLocationID: null,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (categoryBatch: recorder, itemUpdate: itemUpdateRecorder);
}

/// セクションヘッダーを長押ししてから offset 分ドラッグして離す。
Future<void> _longPressDragHeader(
  WidgetTester tester, {
  required Finder header,
  required Offset offset,
}) async {
  final gesture = await tester.startGesture(tester.getCenter(header));
  // ReorderableDelayedDragStartListener の長押し判定を満たすまで待つ。
  await tester.pump(kLongPressTimeout + kPressTimeout);
  // 一度に動かすとドラッグ更新が発火しないことがあるため分割して動かす。
  for (var i = 0; i < 5; i++) {
    await gesture.moveBy(offset / 5);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
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

    testWidgets('カテゴリ分類表示の ReorderableListView が onDrag で閉じる', (tester) async {
      await _pump(tester);
      expect(
        tester
            .widget<ReorderableListView>(find.byType(ReorderableListView))
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

  group('ShoppingListItems: セクション並び替え (Issue #386)', () {
    testWidgets('カテゴリ2つ + 未分類の3セクションが表示される', (tester) async {
      await _pumpSectionReorder(tester);
      expect(find.byType(CategorySectionHeader), findsNWidgets(3));
    });

    testWidgets('カテゴリセクションのヘッダーのみドラッグリスナーが付く（未分類は対象外）', (tester) async {
      await _pumpSectionReorder(tester);
      expect(
        find.ancestor(
          of: find.byType(CategorySectionHeader),
          matching: find.byType(ReorderableDelayedDragStartListener),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('ヘッダーの長押しドラッグでセクションが並び替わり order が振り直される', (tester) async {
      final recorders = await _pumpSectionReorder(tester);

      // 先頭セクション(食品)のヘッダーを、2番目のセクション(日用品)の下端より下までドラッグする。
      final foodHeader = find.byType(CategorySectionHeader).first;
      final dailySectionBottom = tester.getBottomLeft(find.text('洗剤')).dy + 40;
      await _longPressDragHeader(
        tester,
        header: foodHeader,
        offset: Offset(0, dailySectionBottom - tester.getCenter(foodHeader).dy),
      );

      expect(recorders.categoryBatch.lastCategoryAxisID, _sectionReorderAxisID);
      expect(
        recorders.categoryBatch.lastCategories!
            .map((category) => category.name)
            .toList(),
        ['日用品', '食品'],
      );
      expect(
        recorders.categoryBatch.lastCategories!
            .map((category) => category.order)
            .toList(),
        [0, 1],
      );
    });

    testWidgets('行の編集中にヘッダードラッグを開始しても未確定テキストが保存される', (tester) async {
      final recorders = await _pumpSectionReorder(tester);
      // 牛乳の行を編集して Enter 未確定のままにする。
      await tester.enterText(find.widgetWithText(TextField, '牛乳'), '低脂肪牛乳');
      await tester.pump();

      // 食品ヘッダーの長押しドラッグを開始して少し動かして離す。
      final foodHeader = find.byType(CategorySectionHeader).first;
      final gesture = await tester.startGesture(tester.getCenter(foodHeader));
      await tester.pump(kLongPressTimeout + kPressTimeout);
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      // 畳み(行の unmount)より先に unfocus でフォーカス喪失保存が走り、編集内容が失われない。
      expect(recorders.itemUpdate.lastItem?.message, '低脂肪牛乳');
    });

    testWidgets('ヘッダードラッグ中はセクションを畳み、proxy に先頭2件だけが出る', (tester) async {
      await _pumpSectionReorder(tester);
      // pump 直後は 食品3件 + 洗剤 + ガムテープ の5行。
      expect(find.byType(TextShoppingListItemWidget), findsNWidgets(5));

      final foodHeader = find.byType(CategorySectionHeader).first;
      final gesture = await tester.startGesture(tester.getCenter(foodHeader));
      await tester.pump(kLongPressTimeout + kPressTimeout);
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 100));

      // リスト側の食品セクションは畳まれ、proxy のプレビューに先頭2件(牛乳・卵)だけが出る。
      // 行は 洗剤 + ガムテープ(リスト) + 牛乳 + 卵(proxy プレビュー) の4つになる。
      expect(find.byType(TextShoppingListItemWidget), findsNWidgets(4));
      expect(find.text('牛乳'), findsOneWidget);
      expect(find.text('卵'), findsOneWidget);
      expect(find.text('食パン'), findsNothing,
          reason: '3件目はプレビュー上限(2件)の対象外で、リスト側は畳まれているため表示されない');

      await gesture.up();
      await tester.pumpAndSettle();
      // ドロップ後は畳みが解除され、全アイテムが再表示される。
      expect(find.byType(TextShoppingListItemWidget), findsNWidgets(5));
      expect(find.text('食パン'), findsOneWidget);
    });

    testWidgets('ドロップ直後、stream 未更新でも楽観的にセクション順が入れ替わる', (tester) async {
      // stream(Stream.value)は再 emit しないため、楽観の表示順が破棄されず維持される。
      // 牛乳(食品)が洗剤(日用品)より下に来ていれば楽観反映できている。
      await _pumpSectionReorder(tester);
      final foodHeader = find.byType(CategorySectionHeader).first;
      final dailySectionBottom = tester.getBottomLeft(find.text('洗剤')).dy + 40;
      await _longPressDragHeader(
        tester,
        header: foodHeader,
        offset: Offset(0, dailySectionBottom - tester.getCenter(foodHeader).dy),
      );
      expect(
        tester.getCenter(find.text('牛乳')).dy,
        greaterThan(tester.getCenter(find.text('洗剤')).dy),
        reason: '牛乳(食品)が洗剤(日用品)より上のまま＝楽観のセクション順が反映されていない',
      );
    });
  });
}
