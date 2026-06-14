import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/inquiry_category.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// メールアドレスの形式チェック用の正規表現。
final _emailRegExp = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// お問い合わせフォーム画面。
///
/// メールアドレス・お問い合わせの種類・内容を入力して送信する。送信処理は
/// `functions.submitInquiry` 経由で Firebase Functions を呼び、Functions 側で
/// Firestore へのスナップショット保存と Slack 通知を行う。
class InquiryPage extends HookConsumerWidget {
  const InquiryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final contentController = useTextEditingController();
    final selectedCategory = useState<InquiryCategory?>(null);
    final isSubmitting = useState(false);
    final errorMessage = useState<String?>(null);

    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    Future<void> submit() async {
      analytics.logEvent(
        name: 'tap_submit_inquiry',
        parameters: {
          'categoryType': selectedCategory.value?.wireValue ?? 'none',
        },
      );

      final email = emailController.text.trim();
      final content = contentController.text.trim();
      final category = selectedCategory.value;

      if (email.isEmpty) {
        errorMessage.value = 'メールアドレスを入力してください';
        return;
      }
      if (!_emailRegExp.hasMatch(email)) {
        errorMessage.value = 'メールアドレスの形式が正しくありません';
        return;
      }
      if (category == null) {
        errorMessage.value = 'お問い合わせの種類を選択してください';
        return;
      }
      if (content.isEmpty) {
        errorMessage.value = 'お問い合わせ内容を入力してください';
        return;
      }

      isSubmitting.value = true;
      errorMessage.value = null;
      try {
        final package = await PackageInfo.fromPlatform();
        await functions.submitInquiry(
          email: email,
          categoryType: category,
          content: content,
          platform: Platform.isIOS ? 'ios' : 'android',
          appVersion: '${package.version} (${package.buildNumber})',
        );
        // 画面を閉じた後も見えるよう、OverlayEntry 方式のグローバルトーストで通知する。
        showGlobalToast('お問い合わせを送信しました', title: null);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isSubmitting.value = false;
      }
    }

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('お問い合わせ'),
        backgroundColor: neutral.paper,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'いただいた内容は開発の参考にさせていただきます。返信が必要な場合はご連絡先のメールアドレスをご記入ください。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: neutral.ink2),
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'メールアドレス', neutral: neutral),
              const SizedBox(height: 8),
              _InputContainer(
                neutral: neutral,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  cursorColor: tokens.accent,
                  decoration: _inputDecoration(
                    context,
                    hintText: 'example@email.com',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'お問い合わせの種類', neutral: neutral),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InquiryCategory.values.map((category) {
                  final isSelected = selectedCategory.value == category;
                  return GestureDetector(
                    onTap: () {
                      analytics.logEvent(
                        name: 'select_inquiry_category',
                        parameters: {'categoryType': category.wireValue},
                      );
                      selectedCategory.value = category;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.accentSoft : neutral.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? tokens.accent : neutral.divider,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        category.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? tokens.accent : neutral.ink,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'お問い合わせ内容', neutral: neutral),
              const SizedBox(height: 8),
              _InputContainer(
                neutral: neutral,
                child: TextField(
                  controller: contentController,
                  maxLines: 8,
                  minLines: 5,
                  cursorColor: tokens.accent,
                  decoration: _inputDecoration(
                    context,
                    hintText: 'お困りの内容やご要望をご記入ください',
                  ),
                ),
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: neutral.dangerSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    errorMessage.value!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: neutral.danger),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                  label: isSubmitting.value ? '送信中...' : '送信する',
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed: isSubmitting.value ? null : submit,
                  icon: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 入力欄の共通装飾(枠線・角丸・下線)を生成する。
InputDecoration _inputDecoration(
  BuildContext context, {
  required String hintText,
}) {
  final tokens = context.appTheme;
  return InputDecoration(
    hintText: hintText,
    border: InputBorder.none,
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: tokens.neutral.divider2, width: 1),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: tokens.accent, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

/// フォーム項目のラベル。
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.neutral});

  /// 表示するラベル文字列。
  final String label;

  /// 配色トークン(neutral グループ)。
  final AppNeutralColors neutral;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: neutral.ink2,
            letterSpacing: 0.04,
          ),
    );
  }
}

/// 入力欄を囲むカード状コンテナ。
class _InputContainer extends StatelessWidget {
  const _InputContainer({required this.child, required this.neutral});

  /// 内側に配置する入力ウィジェット。
  final Widget child;

  /// 配色トークン(neutral グループ)。
  final AppNeutralColors neutral;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: neutral.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: neutral.divider, width: 0.5),
      ),
      child: child,
    );
  }
}
