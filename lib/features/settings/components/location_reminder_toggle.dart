import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/l10n/l10n.dart';
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
    final locationReminderNotifier = ref.watch(
      boolSharedPreferencesProvider(
        key: BoolKey.locationReminderEnabled,
      ).notifier,
    );

    return SwitchListTile(
      title: Text(context.l10n.settingsLocationReminderTitle),
      subtitle: Text(context.l10n.settingsLocationReminderSubtitle),
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
                      localNotifications
                          .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin
                          >();
                  if (await androidNotifications
                          ?.requestNotificationsPermission() ==
                      false) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context
                                .l10n
                                .settingsLocationReminderNotificationPermissionRequired,
                          ),
                        ),
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
                        SnackBar(
                          content: Text(
                            context
                                .l10n
                                .settingsLocationReminderAlwaysPermissionRequired,
                          ),
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
                    content: Text(
                      context.l10n.settingsLocationReminderPremiumOnly,
                    ),
                    action: SnackBarAction(
                      label: context.l10n.commonUpgrade,
                      onPressed: () => showPaywall(context: context),
                    ),
                  ),
                );
              },
    );
  }
}
