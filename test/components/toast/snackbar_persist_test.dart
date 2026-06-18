import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// SnackBar の自動消去に関する回帰テスト。
/// action(SnackBarAction) 付き SnackBar は `persist` のデフォルトが `action != null` = true となり、
/// duration 経過後も自動消去されない（Flutter scaffold.dart の Timer が persist=true で return）。
/// アプリ全体でこの挙動を `persist: false` の明示で打ち消しているため、その前提を担保する。
void main() {
  const message = '位置情報リマインダーはプレミアム機能です';

  Future<void> pumpButton(WidgetTester tester, {required bool? persist}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(message),
                          persist: persist,
                          action: SnackBarAction(
                            label: 'アップグレード',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    child: const Text('show'),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  testWidgets('A: action付きSnackBar(persist未指定=デフォルトtrue)は10秒待っても消えない', (
    tester,
  ) async {
    await pumpButton(
      tester,
      persist: null,
    ); // 未指定 → action!=null で persist=true
    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // 入場アニメ
    expect(find.text(message), findsOneWidget);

    // 既定 duration(4秒) を大きく超えて待つ
    await tester.pump(const Duration(seconds: 10));
    expect(
      find.text(message),
      findsOneWidget,
      reason: 'persist=true により自動消去されない（バグ再現）',
    );

    // 後始末: 残った SnackBar を片付ける
    tester.element(find.byType(Scaffold));
  });

  testWidgets('B: persist:false を付けると duration 後に自動消去される', (tester) async {
    await pumpButton(tester, persist: false);
    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(message), findsOneWidget);

    // 4秒 timeout + 退場アニメ
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text(message),
      findsNothing,
      reason: 'persist:false で自動消去される（修正の実証）',
    );
  });
}
