import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

Future<UserCredential> signInWithGoogle() async {
  final googleSignIn = GoogleSignIn.instance;

  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

  // Obtain the idToken from authentication
  final String? idToken = googleUser.authentication.idToken;

  // Obtain the accessToken from authorization
  final authorization = await googleUser.authorizationClient
      .authorizationForScopes(['email', 'profile']);
  final String? accessToken = authorization?.accessToken;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: accessToken,
    idToken: idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class AppSignInWithGoogleButton extends HookConsumerWidget {
  /// サインイン処理の開始/終了を呼び出し元へ通知する。
  /// 処理中は呼び出し元（AuthPage）が画面全体を LaunchLoading に切り替えるため、
  /// ボタン自身は処理中インジケータを描画しない。
  final void Function(bool isLoading) onLoadingChanged;

  const AppSignInWithGoogleButton({super.key, required this.onLoadingChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: neutral.surface2,
            foregroundColor: neutral.ink,
            side: BorderSide(color: neutral.divider, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () async {
            if (isLoading.value) return;
            analytics.logEvent(name: 'tap_sign_in_google', parameters: null);
            isLoading.value = true;
            onLoadingChanged(true);
            try {
              await signInWithGoogle();
              // 成功時はローディングを解除しない。認証状態の変化を AuthResolver が検知し、
              // 連鎖の LaunchLoading（同一 key）へ途切れず引き継ぐ。ここで解除すると
              // AuthPage が一瞬戻ってちらつくため、失敗・キャンセル時のみ解除する。
            } on GoogleSignInException catch (e) {
              isLoading.value = false;
              onLoadingChanged(false);
              if (e.code == GoogleSignInExceptionCode.canceled) {
                return;
              }
              rethrow;
            } catch (_) {
              isLoading.value = false;
              onLoadingChanged(false);
              rethrow;
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'images/google_icon.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Google でサインイン',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: neutral.ink,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
