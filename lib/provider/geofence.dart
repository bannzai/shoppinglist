import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/location_reminder/geofence_service.dart';
import 'package:shoppinglist/provider/local_notification.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

part 'geofence.g.dart';

const _locationReminderEnabledKey = 'locationReminderEnabled';

/// 位置情報リマインダーの有効/無効を管理するプロバイダー。
@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
class LocationReminderEnabled extends _$LocationReminderEnabled {
  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(
              _locationReminderEnabledKey,
            ) ??
        false;
  }

  /// 設定値を保存する。冪等にするため toggle ではなく値指定。
  Future<void> setEnabled({required bool enabled}) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_locationReminderEnabledKey, enabled);
    state = enabled;
  }
}

/// GeofenceService のシングルトンインスタンスを提供するプロバイダー。
@Riverpod(keepAlive: true, dependencies: [localNotificationsPlugin])
GeofenceService geofenceService(Ref ref) {
  final service = GeofenceService(
    notificationsPlugin: ref.watch(localNotificationsPluginProvider),
  );
  ref.onDispose(service.dispose);
  return service;
}

/// ジオフェンス監視の状態を管理し、条件に応じて開始/停止するプロバイダー。
///
/// premium状態、トグル状態、監視対象の店舗データを監視し、
/// すべての条件が満たされる場合にのみ GeofenceService の監視を開始する。
@Riverpod()
void geofenceMonitor(Ref ref) {
  final isPremium =
      ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
  final isEnabled = ref.watch(locationReminderEnabledProvider);
  final service = ref.watch(geofenceServiceProvider);
  final groups = ref.watch(userGroupsProvider).asData?.value ?? [];

  if (!isPremium || !isEnabled || groups.isEmpty) {
    service.stopMonitoring();
    return;
  }

  // 全グループの位置情報とアクティブリストを収集
  final locationsByGroupID = <String, List<GroupShoppingLocation>>{};
  final activeListsByLocationID = <String, List<GroupShoppingList>>{};

  for (final group in groups) {
    final locationsWithCoords = (ref
                .watch(shoppingLocationsProvider(groupID: group.id))
                .asData
                ?.value ??
            [])
        .where((l) => l.latitude != null && l.longitude != null)
        .toList();
    if (locationsWithCoords.isNotEmpty) {
      locationsByGroupID[group.id] = locationsWithCoords;
    }

    for (final list in (ref
                .watch(shoppingListsProvider(
                    groupID: group.id, isPremium: isPremium))
                .asData
                ?.value ??
            [])
        .where((l) => l.status == GroupShoppingListStatus.active)) {
      if (list.shoppingLocationID != null) {
        activeListsByLocationID
            .putIfAbsent(list.shoppingLocationID!, () => [])
            .add(list);
      }
    }
  }

  service.updateMonitoredData(
    locationsByGroupID: locationsByGroupID,
    activeListsByLocationID: activeListsByLocationID,
  );
  service.startMonitoring();
}
