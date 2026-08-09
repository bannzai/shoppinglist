import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/apple.dart';
import 'package:shoppinglist/components/auth/google.dart';
import 'package:shoppinglist/features/auth/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  // issue #548: ストア審査がサインインなしで本体へ入れるよう、ゲスト開始
  // ボタンは kDebugMode ガードなしで常時表示する。ここではボタンが
  // AuthPage のツリーに存在すること（誤って削除・ガードされないこと）を検証する。
  testWidgets('AuthPage にサインインボタンとゲスト開始ボタンが表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: const AuthPage(),
        ),
      ),
    );

    expect(find.byType(AppSignInWithAppleButton), findsOneWidget);
    expect(find.byType(AppSignInWithGoogleButton), findsOneWidget);
    expect(find.byType(GuestStartButton), findsOneWidget);
  });
}
