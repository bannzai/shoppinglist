import 'package:flutter/material.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// カテゴリ別表示時の見出し行。
/// `design_handoff_shopping_list/source/screens-list.jsx` のカテゴリヘッダ相当。
/// 色ドット + カテゴリ名（11px / 700 / ink2）+ セクションの順番を入れ替える上下ボタン
/// （Issue #622）+ 右端に mono の `done/total`。
class CategorySectionHeader extends StatelessWidget {
  final String name;

  /// カテゴリ色 HEX（任意）。null のときは `ink3` の灰色ドット。
  final String? colorHex;

  final int doneCount;
  final int totalCount;

  /// セクションを1つ上へ移動する処理。null のときは上ボタンを無効化する（先頭セクション）。
  final VoidCallback? onMoveUp;

  /// セクションを1つ下へ移動する処理。null のときは下ボタンを無効化する（末尾セクション）。
  /// [onMoveUp] と両方 null のとき（並び順を持たない「未分類」、入れ替え先が無い単独セクション）は
  /// 上下ボタン自体を出さない。
  final VoidCallback? onMoveDown;

  const CategorySectionHeader({
    super.key,
    required this.name,
    required this.colorHex,
    required this.doneCount,
    required this.totalCount,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
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
          Expanded(
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
          if (onMoveUp != null || onMoveDown != null) ...[
            _sectionMoveButton(
              key: const Key('category_section_move_up_button'),
              icon: Icons.keyboard_arrow_up,
              tooltip: context.l10n.shoppingListSectionMoveUpTooltip,
              onPressed: onMoveUp,
              neutral: neutral,
            ),
            _sectionMoveButton(
              key: const Key('category_section_move_down_button'),
              icon: Icons.keyboard_arrow_down,
              tooltip: context.l10n.shoppingListSectionMoveDownTooltip,
              onPressed: onMoveDown,
              neutral: neutral,
            ),
            const SizedBox(width: 4),
          ],
          // 件数は上下ボタンの有無(未分類はボタンなし)にかかわらず右端にそろえる。
          Text(
            '$doneCount/$totalCount',
            style: monoTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: neutral.ink3,
              letterSpacing: null,
            ),
          ),
        ],
      ),
    );
  }
}

/// セクションの上下移動ボタン。見出し行を低く保つため、IconButton 既定の 48px ではなく
/// 28px 四方に詰める（見出しの文字 11px に対し、行の高さの増加を抑えつつ指で押せる最小限の大きさ）。
Widget _sectionMoveButton({
  required Key key,
  required IconData icon,
  required String tooltip,
  required VoidCallback? onPressed,
  required AppNeutralColors neutral,
}) => IconButton(
  key: key,
  tooltip: tooltip,
  onPressed: onPressed,
  icon: Icon(icon),
  iconSize: 18,
  color: neutral.ink2,
  disabledColor: neutral.ink4,
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
  style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
);
