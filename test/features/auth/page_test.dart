import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/apple.dart';
import 'package:shoppinglist/components/auth/google.dart';
import 'package:shoppinglist/features/auth/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../helpers/localized_test_app.dart';

void main() {
  // issue #548: ストア審査がサインインなしで本体へ入れるよう、ゲスト開始
  // ボタンは kDebugMode ガードなしで常時表示する。ここではボタンが
  // AuthPage のツリーに存在すること（誤って削除・ガードされないこと）を検証する。
  testWidgets('AuthPage にサインインボタンとゲスト開始ボタンが表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: const AuthPage(),
        ),
      ),
    );

    expect(find.byType(AppSignInWithAppleButton), findsOneWidget);
    expect(find.byType(AppSignInWithGoogleButton), findsOneWidget);
    expect(find.byType(GuestStartButton), findsOneWidget);
  });

  // issue #640: iPhone Duo の外側ディスプレイ (466×678pt) では画像 240pt + 文言 + ボタン 3 つ +
  // 同意文が縦に収まらず 45pt overflow した。高さが足りない時は画像が縮んで
  // overflow せず、ボタンと同意文が画面内に残ることを検証する。
  testWidgets('高さの足りない画面でも AuthPage が overflow せずボタンが収まる', (tester) async {
    tester.view.physicalSize = const Size(466, 678);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: const AuthPage(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final guestButtonBottom =
        tester.getBottomLeft(find.byType(GuestStartButton)).dy;
    expect(guestButtonBottom, lessThanOrEqualTo(678));
    expect(
      tester.getSize(find.byType(Image)).height,
      lessThan(240),
      reason: '足りない高さのぶん画像が縮む',
    );
  });
}
