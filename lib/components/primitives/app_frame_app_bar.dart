import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// compact (h=48) AppBar。
/// `design_handoff_shopping_list/source/frame.jsx#AppBar(large=false)` 相当。
/// [AppLargeAppBar] が 52px + subtitle 構成のため、サブ画面向け 48px を分離して提供する。
/// bottom に 0.5px divider と paper 背景を持つ。
class AppFrameAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 中央タイトル。
  final String title;

  /// 左端アイコンスロット（任意）。`AppRoundButton(chev-l)` 等を渡す。
  final Widget? leading;

  /// 右端アイコンスロット（任意）。
  final Widget? trailing;

  /// タイトルを accent 色で描画するか。
  final bool accent;

  const AppFrameAppBar({
    super.key,
    required this.title,
    required this.leading,
    required this.trailing,
    this.accent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    return Material(
      color: neutral.paper,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: neutral.divider, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(width: 36, child: leading),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent ? tokens.accent : neutral.ink,
                    ),
              ),
            ),
            SizedBox(width: 36, child: trailing),
          ],
        ),
      ),
    );
  }
}
