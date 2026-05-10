import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/apple.dart';
import 'package:shoppinglist/components/auth/google.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:url_launcher/url_launcher.dart';

/// 認証画面。OnboardingPage 完了後 / 未認証時に表示される。
/// `design_handoff_shopping_list/source/screens-onboarding.jsx#AuthPage` 相当。
class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return Scaffold(
      backgroundColor: neutral.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SvgPicture.asset(
                  'images/undraw_shopping-app_b80f.svg',
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '買い物リストへようこそ',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'サインインして、家族・パートナーと\nリストを共有しましょう。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: neutral.ink2,
                      height: 1.7,
                    ),
              ),
              const Spacer(),
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
              const SizedBox(height: 16),
              const _Note(),
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
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    final linkStyle = TextStyle(
      fontSize: 11,
      color: tokens.accent,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationThickness: 1,
      decorationColor: tokens.accent,
    );
    final muted = TextStyle(
      fontSize: 11,
      color: neutral.ink3,
      height: 1.5,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'プライバシーポリシー',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                analytics.logEvent(name: 'tap_auth_privacy_policy');
                launchUrl(
                  Uri.parse(
                      'https://bannzai.github.io/shoppinglist/PrivacyPolicy'),
                  mode: LaunchMode.externalApplication,
                );
              },
          ),
          TextSpan(text: 'と', style: muted),
          TextSpan(
            text: '利用規約',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                analytics.logEvent(name: 'tap_auth_terms_of_service');
                launchUrl(
                  Uri.parse('https://bannzai.github.io/shoppinglist/Terms'),
                  mode: LaunchMode.externalApplication,
                );
              },
          ),
          TextSpan(text: 'に同意した上でサインインしてください', style: muted),
        ],
      ),
    );
  }
}
