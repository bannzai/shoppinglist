// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geofenceServiceHash() => r'ebaeef2e7db157d0c444c375c27136cc553ac3fd';

/// GeofenceService のシングルトンインスタンスを提供するプロバイダー。
///
/// Copied from [geofenceService].
@ProviderFor(geofenceService)
final geofenceServiceProvider = Provider<GeofenceService>.internal(
  geofenceService,
  name: r'geofenceServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geofenceServiceHash,
  dependencies: <ProviderOrFamily>[localNotificationsPluginProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    localNotificationsPluginProvider,
    ...?localNotificationsPluginProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeofenceServiceRef = ProviderRef<GeofenceService>;
String _$geofenceMonitoringPlanHash() =>
    r'c779fd1ed8edf53429591b4ff71f70fe9e989845';

/// ジオフェンス監視に必要なデータを計算するプロバイダー。
///
/// premium状態、トグル状態、監視対象の店舗データ、アクティブリストを監視（ref.watch）し、
/// 監視すべきか否かと監視対象データを [GeofenceMonitoringPlan] として返す。
/// 副作用（GeofenceService の開始/停止）はここでは行わず、購読側（app.dart）の
/// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従う。
///
/// Copied from [geofenceMonitoringPlan].
@ProviderFor(geofenceMonitoringPlan)
final geofenceMonitoringPlanProvider =
    AutoDisposeProvider<GeofenceMonitoringPlan>.internal(
  geofenceMonitoringPlan,
  name: r'geofenceMonitoringPlanProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geofenceMonitoringPlanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeofenceMonitoringPlanRef
    = AutoDisposeProviderRef<GeofenceMonitoringPlan>;
String _$locationReminderEnabledHash() =>
    r'0961f83f6995b63f4e2a2b4eb94f8d9e4e45a5b9';

/// 位置情報リマインダーの有効/無効を管理するプロバイダー。
///
/// Copied from [LocationReminderEnabled].
@ProviderFor(LocationReminderEnabled)
final locationReminderEnabledProvider =
    NotifierProvider<LocationReminderEnabled, bool>.internal(
  LocationReminderEnabled.new,
  name: r'locationReminderEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationReminderEnabledHash,
  dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    sharedPreferencesProvider,
    ...?sharedPreferencesProvider.allTransitiveDependencies
  },
);

typedef _$LocationReminderEnabled = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
