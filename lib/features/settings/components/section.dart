import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_section_card.dart';

/// 設定画面用のセクション。タイトル + 子 Cell を `AppSectionCard` でラップする。
/// 旧実装と API 互換のため `text` / `children` を受け取る。
class SettingSectionTitle extends StatelessWidget {
  final String text;
  final List<Widget> children;

  const SettingSectionTitle({
    super.key,
    required this.text,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(title: text, children: children);
  }
}
