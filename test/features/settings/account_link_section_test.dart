import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/features/settings/components/account_link_section.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// AccountLinkSection の表示分岐（issue #548）を検証するための User フェイク。
/// リンクフロー自体は起動しないため、表示に使う isAnonymous / providerData
/// だけを実装する。
class _FakeUser extends Fake implements User {
  _FakeUser({required bool isAnonymous, required List<UserInfo> providerData})
    : _isAnonymous = isAnonymous,
      _providerData = providerData;

  final bool _isAnonymous;
  final List<UserInfo> _providerData;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  List<UserInfo> get providerData => _providerData;
}

/// providerId だけを持つ UserInfo フェイク。
class _FakeUserInfo extends Fake implements UserInfo {
  _FakeUserInfo({required String providerId}) : _providerId = providerId;

  final String _providerId;

  @override
  String get providerId => _providerId;
}

/// firebaseUserChangesProvider を [user] で固定し、テーマ付きで
/// AccountLinkSection を表示するヘルパー。
Widget _wrap({required User user}) => ProviderScope(
  overrides: [
    firebaseUserChangesProvider.overrideWith((ref) => Stream.value(user)),
  ],
  child: MaterialApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
    home: const Scaffold(
      body: SingleChildScrollView(child: AccountLinkSection()),
    ),
  ),
);

void main() {
  testWidgets('ゲスト（匿名）には説明行と Apple / Google のリンク導線を表示する', (tester) async {
    await tester.pumpWidget(
      _wrap(user: _FakeUser(isAnonymous: true, providerData: const [])),
    );
    // Stream.value の発火を反映する。
    await tester.pump();

    expect(find.byType(GuestAccountDescriptionCell), findsOneWidget);
    expect(find.byType(AppleAccountLinkCell), findsOneWidget);
    expect(find.byType(GoogleAccountLinkCell), findsOneWidget);
    expect(find.byType(LinkedAccountCell), findsNothing);
  });

  testWidgets('Apple リンク済みユーザーには Apple をサインイン済み表示し、Google のリンク導線を残す', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        user: _FakeUser(
          isAnonymous: false,
          providerData: [
            _FakeUserInfo(providerId: AppleAuthProvider.PROVIDER_ID),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GuestAccountDescriptionCell), findsNothing);
    expect(find.byType(LinkedAccountCell), findsOneWidget);
    expect(find.byType(AppleAccountLinkCell), findsNothing);
    expect(find.byType(GoogleAccountLinkCell), findsOneWidget);
  });

  testWidgets('Apple / Google 両方リンク済みならリンク導線を表示しない', (tester) async {
    await tester.pumpWidget(
      _wrap(
        user: _FakeUser(
          isAnonymous: false,
          providerData: [
            _FakeUserInfo(providerId: AppleAuthProvider.PROVIDER_ID),
            _FakeUserInfo(providerId: GoogleAuthProvider.PROVIDER_ID),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LinkedAccountCell), findsNWidgets(2));
    expect(find.byType(AppleAccountLinkCell), findsNothing);
    expect(find.byType(GoogleAccountLinkCell), findsNothing);
  });
}
