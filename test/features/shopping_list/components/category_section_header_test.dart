import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_section_header.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(accent: AccentPreset.shu),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('CategorySectionHeader: カテゴリ名と done/total を表示', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CategorySectionHeader(
          name: '野菜・果物',
          colorHex: '#1F6B4E',
          doneCount: 1,
          totalCount: 3,
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
        ),
      ),
    );
    expect(find.text('未分類'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
  });
}
