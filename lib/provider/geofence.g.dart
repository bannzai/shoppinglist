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
String _$geofenceMonitorHash() => r'f25fedeaa526e56378edf961a6acf94b277324ff';

/// ジオフェンス監視の状態を管理し、条件に応じて開始/停止するプロバイダー。
///
/// premium状態、トグル状態、監視対象の店舗データを監視し、
/// すべての条件が満たされる場合にのみ GeofenceService の監視を開始する。
///
/// Copied from [geofenceMonitor].
@ProviderFor(geofenceMonitor)
final geofenceMonitorProvider = AutoDisposeProvider<void>.internal(
  geofenceMonitor,
  name: r'geofenceMonitorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geofenceMonitorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeofenceMonitorRef = AutoDisposeProviderRef<void>;
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
