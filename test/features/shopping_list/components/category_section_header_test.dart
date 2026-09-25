import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_section_header.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

import '../../../helpers/localized_test_app.dart';

/// [child] をアプリのテーマと l10n を持つ画面に載せる。
Widget _wrap(Widget child) => localizedTestApp(
  theme: buildAppTheme(accent: AccentPreset.shu),
  home: Scaffold(body: child),
);

/// CategorySectionHeader の上ボタンの Key。
const _moveUpButton = Key('category_section_move_up_button');

/// CategorySectionHeader の下ボタンの Key。
const _moveDownButton = Key('category_section_move_down_button');

/// 上下ボタンが押せる状態か(onPressed が設定されているか)。
bool _enabled(WidgetTester tester, Key key) =>
    tester.widget<IconButton>(find.byKey(key)).onPressed != null;

void main() {
  testWidgets('CategorySectionHeader: カテゴリ名と done/total を表示', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CategorySectionHeader(
          name: '野菜・果物',
          colorHex: '#1F6B4E',
          doneCount: 1,
          totalCount: 3,
          onMoveUp: null,
          onMoveDown: null,
        ),
      ),
    );
    expect(find.text('野菜・果物'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('CategorySectionHeader: colorHex=null でも例外なく描画される', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CategorySectionHeader(
          name: '未分類',
          colorHex: null,
          doneCount: 0,
          totalCount: 2,
          onMoveUp: null,
          onMoveDown: null,
        ),
      ),
    );
    expect(find.text('未分類'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
  });

  group('CategorySectionHeader: 上下ボタン (Issue #622)', () {
    testWidgets('onMoveUp / onMoveDown が両方 null なら上下ボタンを出さない', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CategorySectionHeader(
            name: '未分類',
            colorHex: null,
            doneCount: 0,
            totalCount: 2,
            onMoveUp: null,
            onMoveDown: null,
          ),
        ),
      );
      expect(find.byKey(_moveUpButton), findsNothing);
      expect(find.byKey(_moveDownButton), findsNothing);
    });

    testWidgets('片方だけ null なら両方出し、null 側だけ無効にする', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CategorySectionHeader(
            name: '野菜',
            colorHex: null,
            doneCount: 0,
            totalCount: 1,
            onMoveUp: null,
            onMoveDown: () {},
          ),
        ),
      );
      expect(_enabled(tester, _moveUpButton), isFalse);
      expect(_enabled(tester, _moveDownButton), isTrue);
    });

    testWidgets('上ボタン・下ボタンのタップでそれぞれの処理が呼ばれる', (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(
        _wrap(
          CategorySectionHeader(
            name: '野菜',
            colorHex: null,
            doneCount: 0,
            totalCount: 1,
            onMoveUp: () => calls.add('up'),
            onMoveDown: () => calls.add('down'),
          ),
        ),
      );
      await tester.tap(find.byKey(_moveUpButton));
      await tester.tap(find.byKey(_moveDownButton));
      expect(calls, ['up', 'down']);
    });
  });
}
