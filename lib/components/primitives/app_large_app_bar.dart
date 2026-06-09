import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 大見出し付きの AppBar。
/// `design_handoff_shopping_list/source/frame.jsx#AppBar(large=true)` 相当。
/// 上段（高さ 52）に leading / trailing、下段（padding 14）に大見出し + 任意 subtitle を配置する。
class AppLargeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 大見出しテキスト。
  final String title;

  /// 補足テキスト（任意）。
  final String? subtitle;

  /// 左端アイコンスロット（任意）。`AppRoundButton(chev-l)` 等を渡す。
  final Widget? leading;

  /// 右端アイコン群。
  final List<Widget> trailing;

  const AppLargeAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    this.trailing = const [],
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 110 : 130);

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: neutral.surface,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  SizedBox(width: 44, child: leading),
                  const Spacer(),
                  ...trailing,
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.displayMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(color: neutral.ink2),
                  ),
                ],
              ],
            ),
          ),
          Container(height: 0.5, color: neutral.divider),
        ],
      ),
    );
  }
}
