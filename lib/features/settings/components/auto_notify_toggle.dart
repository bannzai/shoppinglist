import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// 買い物リスト更新の自動通知 ON/OFF を切り替えるトグル。
class AutoNotifyToggle extends ConsumerWidget {
  const AutoNotifyToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(
      boolSharedPreferencesProvider(key: BoolKey.autoNotifyShoppingListUpdate),
    );

    return SwitchListTile(
      title: const Text('買い物リストの更新を通知する'),
      subtitle: const Text('画面を離れた時にグループメンバーへ自動通知'),
      value: isEnabled,
      onChanged: (_) {
        analytics.logEvent(
          name: 'tap_toggle_auto_notify',
          parameters: {'enabled': (!isEnabled).toString()},
        );
        ref
            .read(
              boolSharedPreferencesProvider(
                key: BoolKey.autoNotifyShoppingListUpdate,
              ).notifier,
            )
            .toggle();
      },
    );
  }
}
