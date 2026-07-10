import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/components/spotlight/spotlight_view.dart';

/// SpotlightView の表示とタップ挙動を検証する。
/// 文言マッチは使わず、専用コンテンツクラス [_TestSpotlightContent] を find.byType で確認する
/// (プロジェクト方針)。
class _TestSpotlightContent extends StatelessWidget {
  const _TestSpotlightContent();

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Padding(padding: EdgeInsets.all(16), child: Text('説明')),
    );
  }
}

Future<void> _pumpSpotlight(
  WidgetTester tester, {
  required VoidCallback onDismiss,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SpotlightView(
          targetRect: const Rect.fromLTWH(100, 100, 40, 40),
          targetPadding: const EdgeInsets.all(8),
          shape: const SpotlightRoundedRect(cornerRadius: 12),
          content: const _TestSpotlightContent(),
          onDismiss: onDismiss,
        ),
      ),
    ),
  );
  // フェードイン完了まで待つ。
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('説明コンテンツが表示される', (tester) async {
    await _pumpSpotlight(tester, onDismiss: () {});
    expect(find.byType(SpotlightView), findsOneWidget);
    expect(find.byType(_TestSpotlightContent), findsOneWidget);
  });

  testWidgets('画面のディム部分をタップすると onDismiss が呼ばれる', (tester) async {
    var dismissed = false;
    await _pumpSpotlight(tester, onDismiss: () => dismissed = true);

    // 対象・バブルから離れたディム部分をタップする。
    await tester.tapAt(const Offset(20, 500));
    await tester.pump();
    expect(dismissed, isTrue);
  });

  testWidgets('説明コンテンツ上のタップでも onDismiss が呼ばれる', (tester) async {
    var dismissed = false;
    await _pumpSpotlight(tester, onDismiss: () => dismissed = true);

    await tester.tap(find.byType(_TestSpotlightContent));
    await tester.pump();
    expect(dismissed, isTrue);
  });
}
