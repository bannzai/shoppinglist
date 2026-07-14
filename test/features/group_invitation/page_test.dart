import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// acceptGroupInvitation の Firebase Functions 呼び出しを差し替えるフェイク。
/// 常に失敗し、エラーメッセージ表示状態を再現する。
class _FailingAcceptGroupInvitation extends AcceptGroupInvitation {
  _FailingAcceptGroupInvitation()
    : super(userDatabase: UserDatabase(userID: 'test-user-001'));

  @override
  Future<String> call({required String invitationCode}) async {
    throw Exception('有効な招待が見つかりません');
  }
}

/// ソフトウェアキーボード表示中の viewport 縮小を MediaQuery.viewInsets で再現する。
/// Scaffold の resizeToAvoidBottomInset がこの値を読んで body の高さを縮める。
/// 300 は iPhone 系ソフトウェアキーボードの実測高さ (約 300〜340 logical px) の下限相当。
const _keyboardInsets = EdgeInsets.only(bottom: 300);

Widget _wrap() => ProviderScope(
  overrides: [
    acceptGroupInvitationProvider.overrideWithValue(
      _FailingAcceptGroupInvitation(),
    ),
  ],
  child: MaterialApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
    home: Builder(
      builder:
          (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(viewInsets: _keyboardInsets),
            child: const GroupInvitationAcceptPage(),
          ),
    ),
  ),
);

void main() {
  testWidgets('キーボード表示中に招待コードを入力しても RenderFlex overflow が発生しない (#506)', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.enterText(find.byType(TextField), 'ABCD3456');
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('キーボード表示中にエラーメッセージが表示されても RenderFlex overflow が発生しない (#506)', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.enterText(find.byType(TextField), 'ABCD3456');
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const ValueKey('group_invitation_accept_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('group_invitation_accept_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('group_invitation_error_message')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('キーボード表示中でもスクロールでキャンセルボタンに到達できる', (tester) async {
    await tester.pumpWidget(_wrap());

    await tester.enterText(find.byType(TextField), 'ABCD3456');
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const ValueKey('group_invitation_cancel_button')),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('group_invitation_cancel_button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
