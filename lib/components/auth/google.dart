import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                if (isLoading.value) return;
                analytics.logEvent(name: 'tap_sign_in_google');
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'images/google_icon.svg',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Googleでサインイン',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
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
