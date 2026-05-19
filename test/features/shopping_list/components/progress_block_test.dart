import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_block.dart';
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
  testWidgets('ProgressBlock: 進行中は done/total と「チェック済み」を表示', (tester) async {
    await tester.pumpWidget(_wrap(
      const ProgressBlock(checkedCount: 2, totalCount: 5),
    ));
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('チェック済み'), findsOneWidget);
    expect(find.text('完了!'), findsNothing);
    expect(find.text('✓ おつかれさま'), findsNothing);
  });

  testWidgets('ProgressBlock: 全完了時は「✓ おつかれさま」のみ表示し「チェック済み」は出さない',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ProgressBlock(checkedCount: 4, totalCount: 4),
    ));
    expect(find.text('4/4'), findsOneWidget);
    expect(find.text('チェック済み'), findsNothing);
    expect(find.text('✓ おつかれさま'), findsOneWidget);
  });

  testWidgets('ProgressBlock: totalCount=0 で例外なくレンダリングされる', (tester) async {
    await tester.pumpWidget(_wrap(
      const ProgressBlock(checkedCount: 0, totalCount: 0),
    ));
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('完了!'), findsNothing);
  });
}
