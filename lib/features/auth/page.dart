import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/apple.dart';
import 'package:shoppinglist/components/auth/google.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:url_launcher/url_launcher.dart';

/// 認証画面。OnboardingPage 完了後 / 未認証時に表示される。
/// `design_handoff_shopping_list/source/screens-onboarding.jsx#AuthPage` 相当。
class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSigningIn = useState(false);
    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.surface,
      // サインイン処理中は前面に LaunchLoading を重ねる。早期 return ではなく Stack で
      // 重ねることで、実行中のサインインボタンが unmount されず、キャンセル/失敗時に
      // 破棄済み hook へ書き込んで処理が固まるのを防ぎつつ処理中表示を出せる。
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: Image.asset(
                      'images/auth/auth_art.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '家族の買い物を、\nひとつのリストへ',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'サインインすると端末をまたいでリストが同期します。'
                    '広告もメールマガジンもありません。',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: neutral.ink2,
                          height: 1.7,
                        ),
                  ),
                  const Spacer(),
                  AppSignInWithAppleButton(
                    onLoadingChanged: (value) => isSigningIn.value = value,
                  ),
                  const SizedBox(height: 10),
                  AppSignInWithGoogleButton(
                    onLoadingChanged: (value) => isSigningIn.value = value,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          isSigningIn.value = true;
                          try {
                            await FirebaseAuth.instance.signInAnonymously();
                          } catch (_) {
                            isSigningIn.value = false;
                            rethrow;
                          }
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
          if (isSigningIn.value) Positioned.fill(child: LaunchLoading.shared()),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    final linkStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tokens.accent,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationThickness: 1,
          decorationColor: tokens.accent,
        );
    final muted = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: neutral.ink3,
          height: 1.5,
        );

    // 利用規約・プライバシーポリシーへのリンクを含む同意文。
    // 多言語化時はこの 1 文（テンプレート）と各リンクのラベルだけを翻訳対象にすると、
    // 語順が変わってもリンク位置が文ごとに追従する（en 例: 'By continuing, you agree to the {terms} and {privacy}.'）。
    const template = '続けることで {terms} と {privacy} に同意したものとみなされます。';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: _spansFromTemplate(
          template: template,
          textStyle: muted,
          placeholders: {
            'terms': _linkSpan(
              text: '利用規約',
              style: linkStyle,
              analyticsEventName: 'tap_auth_terms_of_service',
              url: 'https://bannzai.github.io/shoppinglist/Terms',
            ),
            'privacy': _linkSpan(
              text: 'プライバシーポリシー',
              style: linkStyle,
              analyticsEventName: 'tap_auth_privacy_policy',
              url: 'https://bannzai.github.io/shoppinglist/PrivacyPolicy',
            ),
          },
        ),
      ),
    );
  }
}

/// プレースホルダ `{name}` を含む 1 文を、name→span の対応に従って InlineSpan 列へ展開する。
/// 文を 1 翻訳単位に保てるため、多言語化で語順が変わってもリンク位置が文ごとに追従する。
List<InlineSpan> _spansFromTemplate({
  required String template,
  required TextStyle? textStyle,
  required Map<String, InlineSpan> placeholders,
}) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'\{(\w+)\}');
  var cursor = 0;
  for (final match in pattern.allMatches(template)) {
    if (match.start > cursor) {
      spans.add(
        TextSpan(
            text: template.substring(cursor, match.start), style: textStyle),
      );
    }
    spans.add(placeholders[match.group(1)!] ?? const TextSpan());
    cursor = match.end;
  }
  if (cursor < template.length) {
    spans.add(TextSpan(text: template.substring(cursor), style: textStyle));
  }
  return spans;
}

/// タップで URL を開き、tap イベントを analytics に記録するリンク span を作る。
TextSpan _linkSpan({
  required String text,
  required TextStyle? style,
  required String analyticsEventName,
  required String url,
}) {
  return TextSpan(
    text: text,
    style: style,
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        analytics.logEvent(name: analyticsEventName, parameters: null);
        launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      },
  );
}
