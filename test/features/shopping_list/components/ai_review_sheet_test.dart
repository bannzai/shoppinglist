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
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed:
                        () => showAIReviewSheet(
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
    // 各候補は編集可能な TextField で表示する。
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(find.byType(TextField), findsNWidgets(2));
    // デフォルト全選択のため "2 件追加"。
    expect(find.text('2 件追加'), findsOneWidget);
  });

  testWidgets('キーボード表示中はシート全体がキーボードの上に退避する', (tester) async {
    // Issue #487: 候補名の TextField 編集でキーボードが出ると、下部の候補行と
    // フッターのボタンがキーボードに隠れて操作できなかった。
    // キーボードは view の viewInsets (物理ピクセル) で疑似的に再現する。
    await pumpSheet(tester, const ['りんご', 'バナナ']);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();

    final keyboardTop =
        (tester.view.physicalSize.height - 300) / tester.view.devicePixelRatio;
    expect(
      tester.getBottomLeft(find.text('2 件追加')).dy,
      lessThanOrEqualTo(keyboardTop),
      reason: 'フッターの追加ボタンがキーボードに隠れず操作できること',
    );
  });

  testWidgets('TextField で候補名を編集すると編集後の名前で確定する', (tester) async {
    // 戻り値を捕捉するため、showAIReviewSheet の結果を保持するホストを pump する。
    List<AIShoppingListCandidate>? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await showAIReviewSheet(
                        context: context,
                        rawNames: const ['りんご'],
                        source: 'test',
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 抽出名を別の表記に書き換える。
    await tester.enterText(find.byType(TextField), 'あおりんご');
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 件追加'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.length, 1);
    expect(result!.first.name, 'あおりんご');
    expect(result!.first.selected, isTrue);
  });
}
