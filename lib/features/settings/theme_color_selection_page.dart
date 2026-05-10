import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// テーマカラー選択画面。プレミアムユーザー向け機能。
class ThemeColorSelectionPage extends ConsumerWidget {
  const ThemeColorSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserThemeColorHex =
        ref.watch(appUserProvider).asData?.value.themeColorHex ??
            defaultThemeColorHex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('テーマカラー'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'アプリのテーマカラーを選択してください',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: themeColorPresets.map((preset) {
                  final isSelected = appUserThemeColorHex == preset.hex;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: '${preset.label}のテーマカラー',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          analytics.logEvent(
                            name: 'select_theme_color',
                            parameters: {'themeColorHex': preset.hex},
                          );
                          try {
                            await ref.read(themeColorUpdateProvider).call(
                                  preset: preset.preset,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('テーマカラーを変更しました')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: preset.color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 24)
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
