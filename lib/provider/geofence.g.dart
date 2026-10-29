// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GeofenceService のシングルトンインスタンスを提供するプロバイダー。

@ProviderFor(geofenceService)
final geofenceServiceProvider = GeofenceServiceProvider._();

/// GeofenceService のシングルトンインスタンスを提供するプロバイダー。

final class GeofenceServiceProvider
    extends
        $FunctionalProvider<GeofenceService, GeofenceService, GeofenceService>
    with $Provider<GeofenceService> {
  /// GeofenceService のシングルトンインスタンスを提供するプロバイダー。
  GeofenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geofenceServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$geofenceServiceHash();

  @$internal
  @override
  $ProviderElement<GeofenceService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeofenceService create(Ref ref) {
    return geofenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeofenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeofenceService>(value),
    );
  }
}

String _$geofenceServiceHash() => r'f0fb7c0f0a587f27b84f062eaf83838942fd2311';

/// ジオフェンス監視に必要なデータを計算するプロバイダー。
///
/// premium状態、トグル状態、監視対象の店舗データ、アクティブリストを監視（ref.watch）し、
/// 監視すべきか否かと監視対象データを [GeofenceMonitoringPlan] として返す。
/// 副作用（GeofenceService の開始/停止）はここでは行わず、購読側（app.dart）の
/// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従う。
// watch する provider は dependencies を持つ (scoped な) provider で、Riverpod 3 は
// それらを dependencies に列挙していないと実行時に例外を投げる

@ProviderFor(geofenceMonitoringPlan)
final geofenceMonitoringPlanProvider = GeofenceMonitoringPlanProvider._();

/// ジオフェンス監視に必要なデータを計算するプロバイダー。
///
/// premium状態、トグル状態、監視対象の店舗データ、アクティブリストを監視（ref.watch）し、
/// 監視すべきか否かと監視対象データを [GeofenceMonitoringPlan] として返す。
/// 副作用（GeofenceService の開始/停止）はここでは行わず、購読側（app.dart）の
/// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従う。
// watch する provider は dependencies を持つ (scoped な) provider で、Riverpod 3 は
// それらを dependencies に列挙していないと実行時に例外を投げる

final class GeofenceMonitoringPlanProvider
    extends
        $FunctionalProvider<
          GeofenceMonitoringPlan,
          GeofenceMonitoringPlan,
          GeofenceMonitoringPlan
        >
    with $Provider<GeofenceMonitoringPlan> {
  /// ジオフェンス監視に必要なデータを計算するプロバイダー。
  ///
  /// premium状態、トグル状態、監視対象の店舗データ、アクティブリストを監視（ref.watch）し、
  /// 監視すべきか否かと監視対象データを [GeofenceMonitoringPlan] として返す。
  /// 副作用（GeofenceService の開始/停止）はここでは行わず、購読側（app.dart）の
  /// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従う。
  // watch する provider は dependencies を持つ (scoped な) provider で、Riverpod 3 は
  // それらを dependencies に列挙していないと実行時に例外を投げる
  GeofenceMonitoringPlanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geofenceMonitoringPlanProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[
          boolSharedPreferencesProvider,
          userGroupsProvider,
          shoppingLocationsProvider,
          shoppingListsProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>{
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies0,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies1,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies2,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies3,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies4,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies5,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies6,
          GeofenceMonitoringPlanProvider.$allTransitiveDependencies7,
        },
      );

  static final $allTransitiveDependencies0 = boolSharedPreferencesProvider;
  static final $allTransitiveDependencies1 =
      BoolSharedPreferencesProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 = userGroupsProvider;
  static final $allTransitiveDependencies3 =
      UserGroupsProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies4 =
      UserGroupsProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies5 = shoppingLocationsProvider;
  static final $allTransitiveDependencies6 =
      ShoppingLocationsProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies7 = shoppingListsProvider;

  @override
  String debugGetCreateSourceHash() => _$geofenceMonitoringPlanHash();

  @$internal
  @override
  $ProviderElement<GeofenceMonitoringPlan> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeofenceMonitoringPlan create(Ref ref) {
    return geofenceMonitoringPlan(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeofenceMonitoringPlan value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeofenceMonitoringPlan>(value),
    );
  }
}

String _$geofenceMonitoringPlanHash() =>
    r'd51a5f3a5c817fb306b3963a6d671d3b18f97922';
