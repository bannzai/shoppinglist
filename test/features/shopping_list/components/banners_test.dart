import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/ai_processing_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/all_done_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/list_error_card.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/retention_banner.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
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
  testWidgets('AllDoneBanner: 祝福テキストが表示される', (tester) async {
    await tester.pumpWidget(_wrap(const AllDoneBanner()));
    expect(find.text('全部チェック完了!'), findsOneWidget);
    expect(find.text('🌿'), findsOneWidget);
  });

  testWidgets('RetentionBanner: 30 日メッセージと「詳しく」が表示される', (tester) async {
    await tester.pumpWidget(_wrap(const RetentionBanner()));
    expect(find.text('無料プランは作成から30日でリストが整理されます'), findsOneWidget);
    expect(find.text('詳しく'), findsOneWidget);
  });

  testWidgets('AIProcessingBanner(image): 画像ラベルとサブテキストが表示される',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const AIProcessingBanner(type: AIProcessingType.image),
    ));
    expect(find.text('写真からアイテムを生成中'), findsOneWidget);
    expect(find.text('レシート 1 枚 ・ 候補を抽出しています…'), findsOneWidget);
  });

  testWidgets('AIProcessingBanner(url): URL ラベルとサブテキストが表示される',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const AIProcessingBanner(type: AIProcessingType.url),
    ));
    expect(find.text('URL からアイテムを生成中'), findsOneWidget);
    expect(find.text('ページを解析しています…'), findsOneWidget);
  });

  testWidgets('ListErrorCard: 固定文言と「再試行」が表示される', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_wrap(ListErrorCard(
      exception: Exception('boom'),
      onRetry: () => retried++,
    )));
    expect(find.text('リストを読み込めませんでした'), findsOneWidget);
    expect(
      find.textContaining('通信状態を確認してください。'),
      findsOneWidget,
    );
    await tester.tap(find.text('再試行'));
    expect(retried, 1);
  });

  testWidgets('ListErrorCard: onContactSupport を渡すと「サポートに連絡」が出る',
      (tester) async {
    var contacted = 0;
    await tester.pumpWidget(_wrap(ListErrorCard(
      exception: null,
      onRetry: () {},
      onContactSupport: () => contacted++,
    )));
    expect(find.text('サポートに連絡'), findsOneWidget);
    await tester.tap(find.text('サポートに連絡'));
    expect(contacted, 1);
  });
}
