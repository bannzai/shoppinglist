import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

// CustomerInfo.isPremium は entitlements.active に premiumEntitlementIdentifier が
// 含まれるかで判定される（purchase.dart の CustomerInfoExtension）。
// テストでは entitlements のみ Fake して premium 状態を制御する。
class _FakeCustomerInfo implements CustomerInfo {
  _FakeCustomerInfo({required this.premium});
  final bool premium;

  @override
  EntitlementInfos get entitlements => _FakeEntitlementInfos(premium: premium);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeEntitlementInfos implements EntitlementInfos {
  _FakeEntitlementInfos({required this.premium});
  final bool premium;

  @override
  Map<String, EntitlementInfo> get active =>
      premium ? {premiumEntitlementIdentifier: _FakeEntitlementInfo()} : {};

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeEntitlementInfo implements EntitlementInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

const _locationID = 'loc-001';

// 座標付きの店舗（監視対象になる条件）。
GroupShoppingLocation _locationWithCoords() => const GroupShoppingLocation(
      id: _locationID,
      groupID: mockGroupID,
      name: 'テストスーパー',
      latitude: 35.6812,
      longitude: 139.7671,
      geofenceRadiusMeters: null,
    );

// 上記店舗に紐づく active な買い物リスト。
GroupShoppingList _activeListAtLocation() => GroupShoppingList(
      id: 'list-001',
      createUserID: 'user-001',
      groupID: mockGroupID,
      status: GroupShoppingListStatus.active,
      shoppingLocationID: _locationID,
      ttlExpiresDateTime: null,
    );

// locationReminderEnabled は sharedPreferences の値から build されるため、
// SharedPreferences のモック値で有効/無効を制御する。
Future<SharedPreferences> _sharedPrefs({required bool enabled}) async {
  SharedPreferences.setMockInitialValues({'locationReminderEnabled': enabled});
  return SharedPreferences.getInstance();
}

void main() {
  group('geofenceMonitoringPlan', () {
    test('premium でない場合は shouldMonitor=false（stopped）', () async {
      final sp = await _sharedPrefs(enabled: true);
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sp),
        customerInfoProvider.overrideWith(
            (ref) => Stream.value(_FakeCustomerInfo(premium: false))),
        userGroupsProvider.overrideWith((ref) => Stream.value([mockGroup()])),
      ]);
      addTearDown(container.dispose);
      await container.read(customerInfoProvider.future);
      await container.read(userGroupsProvider.future);

      final plan = container.read(geofenceMonitoringPlanProvider);
      expect(plan.shouldMonitor, isFalse);
      expect(plan.locationsByGroupID, isEmpty);
      expect(plan.activeListsByLocationID, isEmpty);
    });

    test('premium でもトグル無効の場合は shouldMonitor=false', () async {
      final sp = await _sharedPrefs(enabled: false);
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sp),
        customerInfoProvider.overrideWith(
            (ref) => Stream.value(_FakeCustomerInfo(premium: true))),
        userGroupsProvider.overrideWith((ref) => Stream.value([mockGroup()])),
      ]);
      addTearDown(container.dispose);
      await container.read(customerInfoProvider.future);
      await container.read(userGroupsProvider.future);

      final plan = container.read(geofenceMonitoringPlanProvider);
      expect(plan.shouldMonitor, isFalse);
    });

    test('premium・有効でもグループが空の場合は shouldMonitor=false', () async {
      final sp = await _sharedPrefs(enabled: true);
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sp),
        customerInfoProvider.overrideWith(
            (ref) => Stream.value(_FakeCustomerInfo(premium: true))),
        userGroupsProvider.overrideWith((ref) => Stream.value(<Group>[])),
      ]);
      addTearDown(container.dispose);
      await container.read(customerInfoProvider.future);
      await container.read(userGroupsProvider.future);

      final plan = container.read(geofenceMonitoringPlanProvider);
      expect(plan.shouldMonitor, isFalse);
    });

    test('premium・有効・座標付き店舗・アクティブリストが揃う場合は shouldMonitor=true でデータが入る',
        () async {
      final sp = await _sharedPrefs(enabled: true);
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sp),
        customerInfoProvider.overrideWith(
            (ref) => Stream.value(_FakeCustomerInfo(premium: true))),
        userGroupsProvider.overrideWith((ref) => Stream.value([mockGroup()])),
        shoppingLocationsProvider(groupID: mockGroupID)
            .overrideWith((ref) => Stream.value([_locationWithCoords()])),
        shoppingListsProvider(groupID: mockGroupID, isPremium: true)
            .overrideWith((ref) => Stream.value([_activeListAtLocation()])),
      ]);
      addTearDown(container.dispose);
      await container.read(customerInfoProvider.future);
      await container.read(userGroupsProvider.future);
      await container
          .read(shoppingLocationsProvider(groupID: mockGroupID).future);
      await container.read(
          shoppingListsProvider(groupID: mockGroupID, isPremium: true).future);

      final plan = container.read(geofenceMonitoringPlanProvider);
      expect(plan.shouldMonitor, isTrue);
      expect(plan.locationsByGroupID[mockGroupID], isNotEmpty);
      expect(plan.activeListsByLocationID[_locationID], hasLength(1));
    });
  });
}
