import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_review_sheet.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  // showAIReviewSheet を開くためのテスト用ホストを pump する。
  Future<void> pumpSheet(WidgetTester tester, List<String> rawNames) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showAIReviewSheet(
                  context: context,
                  rawNames: rawNames,
                  source: 'test',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('候補が空でもシートを開き「候補がありませんでした」を表示する', (tester) async {
    // 画像から何も読み取れなかった／すべて既存のケース。
    // 無言で終了せずシートを出すことで、ユーザーが結果を確認できる。
    await pumpSheet(tester, const []);

    expect(find.text('候補がありませんでした'), findsOneWidget);
    // 0 件のため追加ボタンは無効、キャンセルで閉じられる。
    expect(find.text('0 件追加'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('候補がある場合はチェックリストでデフォルト全選択表示する', (tester) async {
    await pumpSheet(tester, const ['りんご', 'バナナ']);

    expect(find.text('りんご'), findsOneWidget);
    expect(find.text('バナナ'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    // デフォルト全選択のため "2 件追加"。
    expect(find.text('2 件追加'), findsOneWidget);
  });
}
