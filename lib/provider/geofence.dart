import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/location_reminder/geofence_service.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/utils/local_notification/local_notification.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

part 'geofence.g.dart';

/// GeofenceService のシングルトンインスタンスを提供するプロバイダー。
@Riverpod(keepAlive: true, dependencies: [localNotificationsPlugin])
GeofenceService geofenceService(Ref ref) {
  final service = GeofenceService(
    notificationsPlugin: ref.watch(localNotificationsPluginProvider),
  );
  ref.onDispose(service.dispose);
  return service;
}

/// ジオフェンス監視の計算結果（不変値）。
///
/// この値の算出は純粋（副作用なし）。実際の監視開始/停止は購読側（app.dart）の
/// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従うための分離。
class GeofenceMonitoringPlan {
  /// 監視を行うべきか。premium かつトグル有効かつ対象グループがある場合のみ true。
  final bool shouldMonitor;

  /// 監視対象の店舗一覧。groupID -> locations。
  final Map<String, List<GroupShoppingLocation>> locationsByGroupID;

  /// 各店舗に紐づくアクティブな買い物リスト。locationID -> lists。
  final Map<String, List<GroupShoppingList>> activeListsByLocationID;

  const GeofenceMonitoringPlan({
    required this.shouldMonitor,
    required this.locationsByGroupID,
    required this.activeListsByLocationID,
  });

  /// 監視停止状態を表す定数。停止が連続する間は同一参照となり ref.listen の無駄発火を抑える。
  static const stopped = GeofenceMonitoringPlan(
    shouldMonitor: false,
    locationsByGroupID: {},
    activeListsByLocationID: {},
  );
}

/// ジオフェンス監視に必要なデータを計算するプロバイダー。
///
/// premium状態、トグル状態、監視対象の店舗データ、アクティブリストを監視（ref.watch）し、
/// 監視すべきか否かと監視対象データを [GeofenceMonitoringPlan] として返す。
/// 副作用（GeofenceService の開始/停止）はここでは行わず、購読側（app.dart）の
/// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従う。
@Riverpod()
GeofenceMonitoringPlan geofenceMonitoringPlan(Ref ref) {
  final isPremium =
      ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
  final isEnabled = ref.watch(
    boolSharedPreferencesProvider(key: BoolKey.locationReminderEnabled),
  );
  final groups = ref.watch(userGroupsProvider).asData?.value ?? [];

  if (!isPremium || !isEnabled || groups.isEmpty) {
    return GeofenceMonitoringPlan.stopped;
  }

  // 全グループの位置情報とアクティブリストを収集
  final locationsByGroupID = <String, List<GroupShoppingLocation>>{};
  final activeListsByLocationID = <String, List<GroupShoppingList>>{};

  for (final group in groups) {
    final locationsWithCoords =
        (ref
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
                .watch(
                  shoppingListsProvider(
                    groupID: group.id,
                    isPremium: isPremium,
                  ),
                )
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

  return GeofenceMonitoringPlan(
    shouldMonitor: true,
    locationsByGroupID: locationsByGroupID,
    activeListsByLocationID: activeListsByLocationID,
  );
}
