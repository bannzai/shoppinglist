import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/features/notification_permission/pre_permission_dialog.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// ダイアログの pop 結果を [results] に記録するテストハーネス。
/// 本番の呼び出し元 (maybeRequestNotificationPermission) と同じ
/// `showGeneralDialog<bool>` 経由で NotificationPrePermissionDialog を表示する。
Widget _harness({required List<bool?> results}) => MaterialApp(
  theme: buildAppTheme(accent: AccentPreset.shu),
  home: Scaffold(
    body: Builder(
      builder:
          (context) => Center(
            child: ElevatedButton(
              key: const ValueKey('open_dialog_button'),
              onPressed: () async {
                results.add(
                  await showGeneralDialog<bool>(
                    context: context,
                    barrierLabel: 'プッシュ通知の許可',
                    barrierDismissible: true,
                    barrierColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 160),
                    pageBuilder:
                        (_, _, _) => const NotificationPrePermissionDialog(),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
    ),
  ),
);

Future<void> _openDialog(WidgetTester tester, List<bool?> results) async {
  await tester.pumpWidget(_harness(results: results));
  await tester.tap(find.byKey(const ValueKey('open_dialog_button')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('プリパーミッションダイアログに「あとで」「通知を許可」の2ボタンが表示される', (tester) async {
    final results = <bool?>[];
    await _openDialog(tester, results);

    expect(find.byType(NotificationPrePermissionDialog), findsOneWidget);
    expect(find.byType(AppPill), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('notification_pre_permission_later')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('notification_pre_permission_allow')),
      findsOneWidget,
    );
  });

  testWidgets('「通知を許可」タップで true を返して閉じる', (tester) async {
    final results = <bool?>[];
    await _openDialog(tester, results);

    await tester.tap(
      find.byKey(const ValueKey('notification_pre_permission_allow')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NotificationPrePermissionDialog), findsNothing);
    expect(results, [true]);
  });

  testWidgets('「あとで」タップで false を返して閉じる', (tester) async {
    final results = <bool?>[];
    await _openDialog(tester, results);

    await tester.tap(
      find.byKey(const ValueKey('notification_pre_permission_later')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NotificationPrePermissionDialog), findsNothing);
    expect(results, [false]);
  });

  testWidgets('背景タップで null を返して閉じる (OSダイアログを消費しない)', (tester) async {
    final results = <bool?>[];
    await _openDialog(tester, results);

    // AppDialogShell の背景 overlay (card 外) をタップして dismiss する。
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationPrePermissionDialog), findsNothing);
    expect(results, [null]);
  });
}
