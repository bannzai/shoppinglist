import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
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
                isLoading.value = true;
                await signInWithApple();
                isLoading.value = false;
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
