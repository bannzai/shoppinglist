import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/inquiry_category.dart';
import 'package:shoppinglist/features/inquiry/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../helpers/localized_test_app.dart';

/// InquiryPage を app テーマ + ProviderScope でラップして pump する。
Future<void> _pumpInquiryPage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: localizedTestApp(
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

  testWidgets('必須項目が未入力のとき送信ボタンは無効(onPressed=null)', (tester) async {
    await _pumpInquiryPage(tester);

    expect(tester.widget<AppPill>(find.byType(AppPill)).onPressed, isNull);
  });

  testWidgets('メール・内容・種類が揃うと送信ボタンが有効になる', (tester) async {
    await _pumpInquiryPage(tester);

    // メール(先頭の TextField)と内容(末尾の TextField)を入力する。
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'テスト内容');
    // カテゴリ選択(Wrap 内の先頭チップ)をタップする。
    await tester.tap(
      find
          .descendant(
            of: find.byType(Wrap),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pump();

    expect(tester.widget<AppPill>(find.byType(AppPill)).onPressed, isNotNull);
  });
}
