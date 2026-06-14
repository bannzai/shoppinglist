import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/inquiry_category.dart';
import 'package:shoppinglist/features/inquiry/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// InquiryPage を app テーマ + ProviderScope でラップして pump する。
Future<void> _pumpInquiryPage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const InquiryPage(),
      ),
    ),
  );
}

void main() {
  testWidgets('入力欄(メール・内容)と送信ボタンを持つ', (tester) async {
    await _pumpInquiryPage(tester);

    // メールアドレスと内容の 2 つの TextField を持つ。
    expect(find.byType(TextField), findsNWidgets(2));
    // 送信ボタン(AppPill)を 1 つ持つ。
    expect(find.byType(AppPill), findsOneWidget);
  });

  testWidgets('カテゴリの選択肢が種類分だけ表示される', (tester) async {
    await _pumpInquiryPage(tester);

    // カテゴリ選択は単一の Wrap で構成され、子要素数が種類数と一致する。
    expect(
      tester.widget<Wrap>(find.byType(Wrap)).children.length,
      InquiryCategory.values.length,
    );
  });

  testWidgets('未入力で送信してもバリデーションで画面に留まる', (tester) async {
    await _pumpInquiryPage(tester);

    await tester.tap(find.byType(AppPill));
    await tester.pump();

    // 送信(Functions 呼び出し)へ進まず、画面に留まる(Navigator.pop されない)。
    expect(find.byType(InquiryPage), findsOneWidget);
  });
}
