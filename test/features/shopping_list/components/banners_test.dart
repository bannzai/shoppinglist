import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/ai_processing_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/list_error_card.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/retention_banner.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(
        accent: AccentPreset.shu,
      ),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('RetentionBanner: 30 日メッセージと「詳しく」が表示される', (tester) async {
    await tester.pumpWidget(_wrap(const RetentionBanner()));
    expect(find.text('無料プランは作成から30日でリストが整理されます'), findsOneWidget);
    expect(find.text('詳しく'), findsOneWidget);
  });

  testWidgets('AIProcessingBanner(image): 画像ラベルが表示される', (tester) async {
    await tester.pumpWidget(_wrap(
      const AIProcessingBanner(type: AIProcessingType.image),
    ));
    expect(find.text('画像から候補を抽出中...'), findsOneWidget);
  });

  testWidgets('AIProcessingBanner(url): URL ラベルが表示される', (tester) async {
    await tester.pumpWidget(_wrap(
      const AIProcessingBanner(type: AIProcessingType.url),
    ));
    expect(find.text('URL から候補を抽出中...'), findsOneWidget);
  });

  testWidgets('ListErrorCard: 例外メッセージと「再試行」が表示される', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_wrap(ListErrorCard(
      exception: Exception('boom'),
      onRetry: () => retried++,
    )));
    expect(find.text('リストを読み込めませんでした'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
    await tester.tap(find.text('再試行'));
    expect(retried, 1);
  });
}
