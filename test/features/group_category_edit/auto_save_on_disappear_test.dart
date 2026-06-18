import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/features/group_category_edit/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testUserID = 'test-user-001';
const _testCategoryID = 'cat-001';

GroupCategory _testCategory({String name = '食品'}) => GroupCategory(
  id: _testCategoryID,
  groupID: _testGroupID,
  userID: _testUserID,
  groupCategoryAxisID: _testCategoryAxisID,
  name: name,
  order: 0,
  locationOrders: const {},
  keywords: const [],
  color: null,
  iconName: null,
);

/// 自動保存(disappear)で呼ばれた更新引数を記録するスパイ。
class _SpyCategoryUpdate extends GroupCategoryUpdate {
  _SpyCategoryUpdate() : super(database: GroupDatabase(groupID: _testGroupID));

  int callCount = 0;
  GroupCategory? lastCategory;

  @override
  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required GroupCategory category,
  }) async {
    callCount += 1;
    lastCategory = category;
  }
}

List<Override> _overrides(_SpyCategoryUpdate spy, {String name = '食品'}) => [
  groupCategoriesProvider(
    groupID: _testGroupID,
    categoryAxisID: _testCategoryAxisID,
  ).overrideWith((ref) => Stream.value([_testCategory(name: name)])),
  groupCategoryUpdateProvider(groupID: _testGroupID).overrideWith((ref) => spy),
];

/// ホーム画面のボタンから編集画面を push する。AppBar の戻るボタンを出すことで
/// `tester.pageBack()` による pop(画面離脱)を検証できるようにする。
Future<void> _pumpAndOpenEditPage(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (_) => const GroupCategoryEditPage(
                                  groupID: _testGroupID,
                                  categoryAxisID: _testCategoryAxisID,
                                  categoryID: _testCategoryID,
                                ),
                          ),
                        ),
                    child: const Text('open'),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('カテゴリ編集 画面離脱時の自動保存', () {
    testWidgets('名前を変更して戻る(pop)と自動保存される', (tester) async {
      final spy = _SpyCategoryUpdate();
      await _pumpAndOpenEditPage(tester, overrides: _overrides(spy));

      // 編集画面に遷移できている
      expect(find.text('カテゴリ名'), findsOneWidget);

      // 「完了」を押さずに名前を入力 → 戻る
      await tester.enterText(find.byType(TextField), 'やさい');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(spy.callCount, 1);
      expect(spy.lastCategory?.name, 'やさい');
    });

    testWidgets('名前を変更せず戻ると保存されない', (tester) async {
      final spy = _SpyCategoryUpdate();
      await _pumpAndOpenEditPage(tester, overrides: _overrides(spy));

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(spy.callCount, 0);
    });

    testWidgets('名前を変更してアプリがバックグラウンドへ移ると自動保存される', (tester) async {
      final spy = _SpyCategoryUpdate();
      await _pumpAndOpenEditPage(tester, overrides: _overrides(spy));

      await tester.enterText(find.byType(TextField), 'やさい');

      // AppLifecycleListener の遷移規則(paused の直前は hidden のみ許可)に沿って
      // inactive → hidden → paused を順に送る
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      expect(spy.callCount, 1);
      expect(spy.lastCategory?.name, 'やさい');
    });
  });
}
