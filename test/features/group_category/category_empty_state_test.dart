import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/group_category/category_empty_state.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(accent: AccentPreset.shu),
  home: Scaffold(body: child),
);

void main() {
  group('CategoryEmptyState', () {
    testWidgets('onAddCategory 非null のとき追加ボタンを表示する', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(CategoryEmptyState(onAddCategory: () => tapped = true)),
      );

      // ボタンが存在し、タップでコールバックが発火する
      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
      await tester.tap(button);
      expect(tapped, isTrue);
    });

    testWidgets('onAddCategory null のとき追加ボタンを表示しない', (tester) async {
      await tester.pumpWidget(
        _wrap(const CategoryEmptyState(onAddCategory: null)),
      );

      expect(find.byType(CategoryEmptyState), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });
}
