import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/features/group_category_edit/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../helpers/localized_test_app.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testCategoryID = 'cat-001';

const _testCategory = GroupCategory(
  id: _testCategoryID,
  groupID: _testGroupID,
  userID: 'test-user-001',
  groupCategoryAxisID: _testCategoryAxisID,
  name: '食品',
  order: 0,
  locationOrders: {},
  keywords: [],
  color: null,
  iconName: null,
);

/// キーワード追加で保存されたカテゴリを記録するスパイ。
class _SpyCategoryUpdate extends GroupCategoryUpdate {
  _SpyCategoryUpdate() : super(database: GroupDatabase(groupID: _testGroupID));

  final savedCategories = <GroupCategory>[];

  @override
  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required GroupCategory category,
  }) async {
    savedCategories.add(category);
  }
}

/// 編集画面を表示し、キーワード追加ダイアログで正規表現を選んで [keyword] を入力し「追加」を押す。
Future<void> _submitRegexKeyword(
  WidgetTester tester, {
  required _SpyCategoryUpdate spy,
  required String keyword,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupCategoriesProvider(
          groupID: _testGroupID,
          categoryAxisID: _testCategoryAxisID,
        ).overrideWith((ref) => Stream.value([_testCategory])),
        groupCategoryUpdateProvider(
          groupID: _testGroupID,
        ).overrideWith((ref) => spy),
      ],
      child: localizedTestApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const GroupCategoryEditPage(
          groupID: _testGroupID,
          categoryAxisID: _testCategoryAxisID,
          categoryID: _testCategoryID,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    ),
    keyword,
  );
  // SegmentedButton の並びは 部分一致 / 完全一致 / 正規表現。
  await tester.tap(
    find
        .descendant(
          of: find.byType(SegmentedButton<GroupCategoryKeywordMatchingType>),
          matching: find.byType(TextButton),
        )
        .at(2),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('追加'));
  await tester.pumpAndSettle();
}

void main() {
  group('キーワード追加ダイアログの正規表現の検証', () {
    testWidgets('入れ子の量指定子を含む正規表現は保存せずダイアログにエラーを出す', (tester) async {
      final spy = _SpyCategoryUpdate();
      await _submitRegexKeyword(tester, spy: spy, keyword: r'^(a+)+$');

      expect(spy.savedCategories, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byType(AlertDialog),
                matching: find.byType(TextField),
              ),
            )
            .decoration
            ?.errorText,
        isNotNull,
      );
    });

    testWidgets('入れ子にならない正規表現は正規表現のキーワードとして保存する', (tester) async {
      final spy = _SpyCategoryUpdate();
      await _submitRegexKeyword(tester, spy: spy, keyword: r'^(牛|豚)肉$');

      expect(find.byType(AlertDialog), findsNothing);
      expect(spy.savedCategories.single.keywords, const [
        GroupCategoryKeyword(
          keyword: r'^(牛|豚)肉$',
          matchingType: GroupCategoryKeywordMatchingType.regex,
        ),
      ]);
    });
  });
}
