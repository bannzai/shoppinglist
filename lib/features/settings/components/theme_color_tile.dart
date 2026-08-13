import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/settings/theme_color_selection_page.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// テーマカラー設定のListTile。プレミアムユーザーのみ選択画面へ遷移可能。
class ThemeColorTile extends ConsumerWidget {
  const ThemeColorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    return ListTile(
      title: Text(context.l10n.settingsThemeColorTitle),
      leading: const Icon(Icons.palette),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
                  resolveAccentPreset(
                    ref.watch(appUserProvider).asData?.value.themeColorHex,
                  ).light,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          if (!isPremium)
            Icon(
              Icons.lock,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        ],
      ),
      onTap: () {
        analytics.logEvent(
          name: 'tap_theme_color_setting',
          parameters: {'isPremium': isPremium.toString()},
        );
        if (isPremium) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThemeColorSelectionPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              persist: false,
              content: Text(context.l10n.settingsThemeColorPremiumOnly),
              action: SnackBarAction(
                label: context.l10n.commonUpgrade,
                onPressed: () => showPaywall(context: context),
              ),
            ),
          );
        }
      },
    );
  }
}
