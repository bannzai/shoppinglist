import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple Sign-Inで認証し、Firebase UserCredentialを返す。
/// nonce: rawNonceをSHA-256ハッシュしてAppleに渡し、rawNonceをFirebaseに渡すことでリプレイ攻撃を防ぐ。
Future<UserCredential> signInWithApple() async {
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

  return await FirebaseAuth.instance.signInWithCredential(
    AppleAuthProvider.credentialWithIDToken(
      idToken,
      rawNonce,
      AppleFullPersonName(
        givenName: appleCredential.givenName,
        familyName: appleCredential.familyName,
      ),
    ),
  );
}

class AppSignInWithAppleButton extends HookConsumerWidget {
  const AppSignInWithAppleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SignInWithAppleButton(
              onPressed: () async {
                if (isLoading.value) return;
                analytics.logEvent(name: 'tap_sign_in_apple');
                isLoading.value = true;
                try {
                  await signInWithApple();
                } on SignInWithAppleAuthorizationException catch (e) {
                  if (e.code == AuthorizationErrorCode.canceled) {
                    return;
                  }
                  rethrow;
                } finally {
                  isLoading.value = false;
                }
              },
            ),
          ),
          if (isLoading.value)
            const Center(
              child: Loading(),
            ),
        ],
      ),
    );
  }
}
