import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_join_or_create/page.dart';
import 'package:shoppinglist/provider/group_create.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// createGroup の Firebase Functions 呼び出しを差し替えるフェイク。
/// call の引数を記録し、実際のネットワークは行わない。
class _FakeCreateGroup extends CreateGroup {
  bool called = false;
  bool? lastSetAsDefault;
  String? lastIconName;

  @override
  Future<String> call({
    required AppUser appUser,
    required String? name,
    required bool setAsDefault,
    required String iconName,
  }) async {
    called = true;
    lastSetAsDefault = setAsDefault;
    lastIconName = iconName;
    return 'fake_group_id';
  }
}

const _appUser = AppUser(id: 'test-user-001');

Widget _wrap(_FakeCreateGroup fake) => ProviderScope(
  overrides: [createGroupProvider.overrideWithValue(fake)],
  child: MaterialApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
    home: const GroupJoinOrCreatePage(appUser: _appUser),
  ),
);

void main() {
  testWidgets('「自分のリストを作る」で createGroup を setAsDefault:true で呼ぶ', (
    tester,
  ) async {
    final fake = _FakeCreateGroup();
    await tester.pumpWidget(_wrap(fake));

    await tester.tap(
      find.byKey(const ValueKey('group_join_or_create_create_button')),
    );
    await tester.pump(); // ボタン押下→async 開始
    await tester.pumpAndSettle();

    expect(fake.called, isTrue);
    expect(fake.lastSetAsDefault, isTrue);
    expect(fake.lastIconName, 'home');
  });

  testWidgets('「招待コードで参加」で GroupInvitationAcceptPage へ遷移する', (tester) async {
    final fake = _FakeCreateGroup();
    await tester.pumpWidget(_wrap(fake));

    await tester.tap(
      find.byKey(const ValueKey('group_join_or_create_join_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GroupInvitationAcceptPage), findsOneWidget);
    expect(fake.called, isFalse);
  });
}
