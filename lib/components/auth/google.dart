import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
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
  const AppSignInWithGoogleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          SizedBox(
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
                analytics.logEvent(
                    name: 'tap_sign_in_google', parameters: null);
                isLoading.value = true;
                try {
                  await signInWithGoogle();
                } on GoogleSignInException catch (e) {
                  if (e.code == GoogleSignInExceptionCode.canceled) {
                    return;
                  }
                  rethrow;
                } finally {
                  isLoading.value = false;
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
          if (isLoading.value)
            const Center(
              child: Loading(),
            ),
        ],
      ),
    );
  }
}
