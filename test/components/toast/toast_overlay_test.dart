import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// グローバル関数 `showGlobalToast` が参照する `appProviderContainer` と、
/// 同じコンテナを `UncontrolledProviderScope` に渡した `ToastOverlay` を組み合わせ、
/// 表示・自動消滅・置き換え・即 dismiss を検証する。
void main() {
  /// テスト用コンテナを生成して `appProviderContainer` に差し込み、
  /// `ToastOverlay` を Stack 直下に置いた MaterialApp を pump する。
  Future<ProviderContainer> pumpOverlay(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    appProviderContainer = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(
              brightness: Brightness.light, accent: AccentPreset.shu),
          home: const Scaffold(body: Stack(children: [ToastOverlay()])),
        ),
      ),
    );
    return container;
  }

  testWidgets('showGlobalToast: 表示され、duration 経過で自動的に消える', (tester) async {
    await pumpOverlay(tester);
    expect(find.text('保存しました'), findsNothing);

    showGlobalToast('保存しました', title: '完了');
    await tester.pump(); // state 反映
    await tester.pump(const Duration(milliseconds: 250)); // 表示アニメーション
    expect(find.text('保存しました'), findsOneWidget);
    expect(find.text('完了'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5)); // 自動消滅タイマー発火
    await tester.pump(const Duration(milliseconds: 250)); // 消えるアニメーション
    expect(find.text('保存しました'), findsNothing);
  });

  testWidgets('show 連続: 最新メッセージで即置き換わる', (tester) async {
    await pumpOverlay(tester);

    showGlobalToast('古いメッセージ', title: null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('古いメッセージ'), findsOneWidget);

    showGlobalToast('新しいメッセージ', title: null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('新しいメッセージ'), findsOneWidget);
    expect(find.text('古いメッセージ'), findsNothing);

    // 後始末: 保留中のタイマーを発火させる
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('dismissGlobalToast: 即座に消える', (tester) async {
    await pumpOverlay(tester);

    showGlobalToast('メッセージ', title: null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('メッセージ'), findsOneWidget);

    dismissGlobalToast();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('メッセージ'), findsNothing);
  });
}
