import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/utils/local_notification/local_notification.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// 位置情報リマインダーの有効/無効を切り替えるトグル。
class LocationReminderToggle extends ConsumerWidget {
  const LocationReminderToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final isEnabled = ref.watch(
      boolSharedPreferencesProvider(key: BoolKey.locationReminderEnabled),
    );
    final localNotificationsPlugin = ref.watch(
      localNotificationsPluginProvider,
    );
    final locationReminderNotifier = ref.watch(
      boolSharedPreferencesProvider(
        key: BoolKey.locationReminderEnabled,
      ).notifier,
    );

    return SwitchListTile(
      title: const Text('位置情報リマインダー'),
      subtitle: const Text('店舗の近くに来たら買い物リストを通知'),
      secondary: Icon(
        Icons.location_on,
        color:
            !isPremium ? Theme.of(context).colorScheme.onSurfaceVariant : null,
      ),
      value: isPremium && isEnabled,
      onChanged:
          isPremium
              ? (value) async {
                analytics.logEvent(
                  name: 'tap_toggle_location_remind',
                  parameters: {
                    'enabled': value.toString(),
                    'isPremium': isPremium.toString(),
                  },
                );

                if (value) {
                  // Android通知権限の確認
                  final androidNotifications =
                      localNotificationsPlugin
                          .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin
                          >();
                  if (await androidNotifications
                          ?.requestNotificationsPermission() ==
                      false) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('通知権限を許可すると利用できます')),
                      );
                    }
                    return;
                  }

                  // 「常に許可」が必要
                  var permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever) {
                    permission = await Geolocator.requestPermission();
                  }
                  if (permission == LocationPermission.whileInUse) {
                    permission = await Geolocator.requestPermission();
                  }
                  if (permission != LocationPermission.always) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('バックグラウンドの位置情報を「常に許可」にすると利用できます'),
                        ),
                      );
                    }
                    return;
                  }
                }

                await locationReminderNotifier.set(value: value);
              }
              : (value) {
                analytics.logEvent(
                  name: 'tap_toggle_location_remind',
                  parameters: {
                    'enabled': value.toString(),
                    'isPremium': isPremium.toString(),
                  },
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    persist: false,
                    content: const Text('位置情報リマインダーはプレミアム機能です'),
                    action: SnackBarAction(
                      label: 'アップグレード',
                      onPressed: () => showPaywall(context: context),
                    ),
                  ),
                );
              },
    );
  }
}
