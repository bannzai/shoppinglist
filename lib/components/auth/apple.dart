import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<UserCredential> signInWithApple() async {
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );

  final idToken = appleCredential.identityToken;
  if (idToken == null) {
    throw Exception('No identity token');
  }

  final rawNonce = generateNonce();
  final credential = AppleAuthProvider.credentialWithIDToken(
    idToken,
    rawNonce,
    AppleFullPersonName(
      givenName: appleCredential.givenName,
      familyName: appleCredential.familyName,
    ),
  );
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class AppSignInWithAppleButton extends HookConsumerWidget {
  const AppSignInWithAppleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SignInWithAppleButton(
      onPressed: () => signInWithApple(),
    );
  }
}
