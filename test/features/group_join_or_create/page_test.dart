import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_join_or_create/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../helpers/localized_test_app.dart';

const _appUser = AppUser(id: 'test-user-001');

Widget _wrap() => ProviderScope(
  overrides: [
    // GroupInvitationAcceptPage が build 時に defaultGroupUpdateProvider を
    // watch するため、依存先の userDatabaseProvider（Firebase 必須）を差し替える
    userDatabaseProvider.overrideWith(
      (ref) => UserDatabase(userID: _appUser.id),
    ),
  ],
  child: localizedTestApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
    home: const GroupJoinOrCreatePage(appUser: _appUser),
  ),
);

void main() {
  testWidgets('「自分のリストを作る」で createGroup フローが実行される', (tester) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(
      find.byKey(const ValueKey('group_join_or_create_create_button')),
    );
    await tester.pump(); // ボタン押下→async 開始
    await tester.pumpAndSettle();

    // widget test では Firebase 未初期化のため functions.createGroup が
    // [core/no-app] で失敗する。ボタンが createGroup フローに接続され、
    // 失敗時にエラーメッセージが表示されることを検証する。
    expect(
      find.byKey(const ValueKey('group_join_or_create_error_message')),
      findsOneWidget,
    );
  });

  testWidgets('「招待コードで参加」で GroupInvitationAcceptPage へ遷移する', (tester) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(
      find.byKey(const ValueKey('group_join_or_create_join_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GroupInvitationAcceptPage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('group_join_or_create_error_message')),
      findsNothing,
    );
  });
}
