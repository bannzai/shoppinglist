import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_pill.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(
        brightness: Brightness.light,
        accent: AccentPreset.shu,
      ),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('ProgressPill: done/total を表示する', (tester) async {
    await tester.pumpWidget(_wrap(
      const ProgressPill(checkedCount: 2, totalCount: 5),
    ));
    expect(find.text('2/5'), findsOneWidget);
  });

  testWidgets('ProgressPill: 全完了時も done/total のみ表示し祝福文言は出さない', (tester) async {
    await tester.pumpWidget(_wrap(
      const ProgressPill(checkedCount: 4, totalCount: 4),
    ));
    expect(find.text('4/4'), findsOneWidget);
    expect(find.text('✓ おつかれさま'), findsNothing);
    expect(find.text('全部チェック完了!'), findsNothing);
  });
}
