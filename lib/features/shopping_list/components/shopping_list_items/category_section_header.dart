import 'package:flutter/material.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// カテゴリ別表示時の見出し行。
/// `design_handoff_shopping_list/source/screens-list.jsx` のカテゴリヘッダ相当。
/// 色ドット + カテゴリ名（11px / 700 / ink2）+ 末尾に mono の `done/total`。
class CategorySectionHeader extends StatelessWidget {
  final String name;

  /// カテゴリ色 HEX（任意）。null のときは `ink3` の灰色ドット。
  final String? colorHex;

  final int doneCount;
  final int totalCount;

  const CategorySectionHeader({
    super.key,
    required this.name,
    required this.colorHex,
    required this.doneCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final dot = colorHex != null ? colorFromHex(colorHex!) : neutral.ink3;
    return Container(
      width: double.infinity,
      color: neutral.surface,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: neutral.ink2,
                    letterSpacing: 0.06,
                  ),
            ),
          ),
          const Spacer(),
          Text(
            '$doneCount/$totalCount',
            style: monoTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: neutral.ink3,
            ),
          ),
        ],
      ),
    );
  }
}
