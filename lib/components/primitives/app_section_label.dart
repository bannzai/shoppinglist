import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 設定画面のセクション見出し。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#Section` の
/// label 相当 (`fontSize: 11, fontWeight: 700, color: ink2,
/// padding: '0 12px 6px', letterSpacing: 0.05, textTransform: uppercase`)。
class AppSectionLabel extends StatelessWidget {
  /// 表示文字列。`toUpperCase()` で大文字化する。
  final String text;

  const AppSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05,
          color: context.appTheme.neutral.ink2,
        ),
      ),
    );
  }
}
