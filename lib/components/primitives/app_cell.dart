import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 設定画面等で使う Cell row。
/// `design_handoff_shopping_list/source/screens-list-settings.jsx` の Cell 相当。
///
/// 構造: 左 icon tile (32×32 radius 9, surface2 bg) + title + subtitle (任意) +
/// 右 chev-r または Switch。最小高さ 52px。
///
/// - [onTap] のみ指定 → タップ可能なナビ Cell (右端 chev-r)
/// - [onSwitch] + [switchValue] 指定 → スイッチ付き Cell
/// - [danger] true → アイコンとタイトルを danger 色で描画
class AppCell extends StatelessWidget {
  /// 左端 icon tile に表示するアイコン。
  final IconData icon;

  /// セルの主タイトル。
  final String title;

  /// 補足テキスト（任意）。
  final String? subtitle;

  /// 末尾 chev-r の手前に表示する補助テキスト（任意）。
  /// `design_handoff_shopping_list/preview/screens-list-settings.jsx#Cell` の `detail` 相当
  /// (`fontSize: 13, color: ink3`)。Switch 付き Cell には表示されない。
  final String? detail;

  /// 全面タップ時のコールバック。null で disabled。
  final VoidCallback? onTap;

  /// スイッチ切替時のコールバック。
  final ValueChanged<bool>? onSwitch;

  /// スイッチの現在値。[onSwitch] と併用する。
  final bool? switchValue;

  /// 破壊的操作 (削除・サインアウト等)。
  final bool danger;

  const AppCell({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.onTap,
    required this.onSwitch,
    required this.switchValue,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = danger ? neutral.danger : tokens.accent;
    final titleColor = danger ? neutral.danger : neutral.ink;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: neutral.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            textTheme.bodyLarge?.copyWith(color: titleColor)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style:
                            textTheme.bodySmall?.copyWith(color: neutral.ink3),
                      ),
                    ],
                  ],
                ),
              ),
              if (onSwitch != null && switchValue != null)
                Switch(value: switchValue!, onChanged: onSwitch)
              else ...[
                if (detail != null) ...[
                  Text(
                    detail!,
                    style: textTheme.bodySmall?.copyWith(
                      color: neutral.ink3,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (onTap != null)
                  Icon(Icons.chevron_right, size: 18, color: neutral.ink3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
