import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// テーマカラー（5 色プリセット）の選択画面。プレミアム機能。
/// `design_handoff_shopping_list/source/screens-settings.jsx#ThemeColorSelectionPage` 相当。
class ThemeColorSelectionPage extends ConsumerWidget {
  const ThemeColorSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final selectedHex =
        ref.watch(appUserProvider).asData?.value.themeColorHex ??
            defaultThemeColorHex;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('テーマカラー'),
        backgroundColor: neutral.paper,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                child: Text(
                  '和の伝統色 5 色から選んで、アプリ全体の差し色を切り替えます。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: neutral.ink2,
                        height: 1.6,
                      ),
                ),
              ),
              GridView.count(
                crossAxisCount: 5,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: themeColorPresets
                    .map(
                      (preset) => _ColorSwatch(
                        preset: preset.preset,
                        selected: preset.hex == selectedHex,
                        onTap: () async {
                          analytics.logEvent(
                            name: 'select_theme_color',
                            parameters: {'themeColorHex': preset.hex},
                          );
                          try {
                            await ref
                                .read(themeColorUpdateProvider)
                                .call(preset: preset.preset);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('テーマカラーを変更しました')),
                              );
                            }
                          } catch (e, st) {
                            if (context.mounted) {
                              showErrorSnackBar(context, e, st);
                            }
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final AccentPreset preset;
  final bool selected;
  final VoidCallback onTap;
  const _ColorSwatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final color = preset.light;
    return Semantics(
      button: true,
      selected: selected,
      label: '${preset.label}のテーマカラー',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        key: Key('theme_preset_${preset.name}'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: neutral.surface, width: 3)
                    : null,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              foregroundDecoration: selected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: neutral.ink, width: 2),
                    )
                  : null,
              alignment: Alignment.center,
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              preset.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? neutral.ink : neutral.ink2,
                letterSpacing: -0.01,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
