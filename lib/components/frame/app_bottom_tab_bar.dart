import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 下タブの識別子。
enum AppTab {
  /// 買い物リスト。
  list,

  /// 設定。
  settings,
}

/// 2 タブ固定の下部ナビゲーション。
/// `design_handoff_shopping_list/source/frame.jsx#TabBar` 相当。
class AppBottomTabBar extends StatelessWidget {
  /// 現在選択中のタブ。
  final AppTab active;

  /// タブ切替時のコールバック。
  final ValueChanged<AppTab> onChanged;

  const AppBottomTabBar({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Container(
      decoration: BoxDecoration(
        color: neutral.surface,
        border: Border(top: BorderSide(color: neutral.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              _AppTabItem(
                tab: AppTab.list,
                icon: Icons.shopping_cart_outlined,
                label: '買い物リスト',
                selected: active == AppTab.list,
                onTap: () => onChanged(AppTab.list),
              ),
              _AppTabItem(
                tab: AppTab.settings,
                icon: Icons.settings_outlined,
                label: '設定',
                selected: active == AppTab.settings,
                onTap: () => onChanged(AppTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTabItem extends StatelessWidget {
  final AppTab tab;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AppTabItem({
    required this.tab,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = selected ? tokens.accent : tokens.neutral.ink3;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.02,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
