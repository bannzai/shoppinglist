import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/apple.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/components/auth/google.dart';

import 'package:url_launcher/url_launcher.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サインイン'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: SvgPicture.asset(
                    'images/undraw_shopping-app_b80f.svg',
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  const AppSignInWithAppleButton(),
                  const SizedBox(height: 10),
                  const AppSignInWithGoogleButton(),
                  if (kDebugMode) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signInAnonymously();
                        },
                        child: const Text('匿名サインイン（デバッグ用）'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const _Note(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'プライバシーポリシー',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 10,
                  color: colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    analytics.logEvent(name: 'tap_auth_privacy_policy');
                    launchUrl(
                        Uri.parse(
                            'https://bannzai.github.io/shoppinglist/PrivacyPolicy'),
                        mode: LaunchMode.externalApplication);
                  },
              ),
              TextSpan(
                text: 'と',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: '利用規約',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 10,
                  color: colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    analytics.logEvent(name: 'tap_auth_terms_of_service');
                    launchUrl(
                        Uri.parse(
                            'https://bannzai.github.io/shoppinglist/Terms'),
                        mode: LaunchMode.externalApplication);
                  },
              ),
              TextSpan(
                text: 'に同意した上でサインインしてください',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
