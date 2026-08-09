import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple Sign-Inのネイティブフローを実行し、Firebase認証用のcredentialを返す。
/// サインイン（signInWithApple）とリンク（linkWithApple）で共用する。
/// nonce: rawNonceをSHA-256ハッシュしてAppleに渡し、rawNonceをFirebaseに渡すことでリプレイ攻撃を防ぐ。
Future<OAuthCredential> requestAppleAuthCredential() async {
  final rawNonce = generateNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = appleCredential.identityToken;
  if (idToken == null) {
    throw Exception('No identity token');
  }

  return AppleAuthProvider.credentialWithIDToken(
    idToken,
    rawNonce,
    AppleFullPersonName(
      givenName: appleCredential.givenName,
      familyName: appleCredential.familyName,
    ),
  );
}

/// Apple Sign-Inで認証し、Firebase UserCredentialを返す。
Future<UserCredential> signInWithApple() async {
  return await FirebaseAuth.instance.signInWithCredential(
    await requestAppleAuthCredential(),
  );
}

/// 現在のユーザー（主にゲスト=匿名ユーザー）へAppleアカウントをリンクする。
/// UIDが維持されるため、それまでに作ったリスト・グループは引き継がれる（issue #548）。
Future<UserCredential> linkWithApple({required User user}) async {
  return await user.linkWithCredential(await requestAppleAuthCredential());
}

class AppSignInWithAppleButton extends HookConsumerWidget {
  /// サインイン処理の開始/終了を呼び出し元へ通知する。
  /// 処理中は呼び出し元（AuthPage）が画面全体を LaunchLoading に切り替えるため、
  /// ボタン自身は処理中インジケータを描画しない。
  final void Function(bool isLoading) onLoadingChanged;

  const AppSignInWithAppleButton({super.key, required this.onLoadingChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.center,
        child: SignInWithAppleButton(
          height: 52,
          borderRadius: BorderRadius.circular(14),
          onPressed: () async {
            if (isLoading.value) {
              return;
            }
            analytics.logEvent(name: 'tap_sign_in_apple', parameters: null);
            isLoading.value = true;
            onLoadingChanged(true);
            try {
              await signInWithApple();
              // 成功時はローディングを解除しない（google.dart と同じ理由）。
            } on SignInWithAppleAuthorizationException catch (e) {
              isLoading.value = false;
              onLoadingChanged(false);
              if (e.code == AuthorizationErrorCode.canceled) {
                return;
              }
              rethrow;
            } catch (_) {
              isLoading.value = false;
              onLoadingChanged(false);
              rethrow;
            }
          },
        ),
      ),
    );
  }
}
