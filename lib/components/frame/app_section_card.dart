import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 設定画面の Section + Cell ラッパー。
/// `design_handoff_shopping_list/source/screens-settings.jsx` の Section 構造を再現する。
/// 任意の `title`（小見出し）と `children`（Cell）を縦に積み、Cell 間に薄い divider2 を挟む。
class AppSectionCard extends StatelessWidget {
  /// 小見出し（任意）。
  final String? title;

  /// Cell の Widget リスト。
  final List<Widget> children;

  const AppSectionCard({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: neutral.ink3,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: neutral.card,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(color: neutral.divider, width: 0.5),
              boxShadow: tokens.cardShadow,
            ),
            child: Column(children: _withDividers(children, neutral.divider2)),
          ),
        ],
      ),
    );
  }

  static List<Widget> _withDividers(List<Widget> items, Color divider) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(color: divider, height: 0.5, thickness: 0.5));
      }
    }
    return result;
  }
}
