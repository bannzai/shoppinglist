// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localNotificationsPluginHash() =>
    r'9008c49b4da1a9f569c514889ff35a0e1ab8289e';

/// flutter_local_notifications のプラグインインスタンスを提供するプロバイダー。
///
/// Copied from [localNotificationsPlugin].
@ProviderFor(localNotificationsPlugin)
final localNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>.internal(
  localNotificationsPlugin,
  name: r'localNotificationsPluginProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localNotificationsPluginHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalNotificationsPluginRef
    = ProviderRef<FlutterLocalNotificationsPlugin>;
String _$localNotificationsInitializedHash() =>
    r'b73b7108e471e7f007d1f874a62b1ff28c8576a6';

/// アプリ起動時にローカル通知プラグインを初期化する。
///
/// Copied from [localNotificationsInitialized].
@ProviderFor(localNotificationsInitialized)
final localNotificationsInitializedProvider = FutureProvider<void>.internal(
  localNotificationsInitialized,
  name: r'localNotificationsInitializedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localNotificationsInitializedHash,
  dependencies: <ProviderOrFamily>[localNotificationsPluginProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    localNotificationsPluginProvider,
    ...?localNotificationsPluginProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalNotificationsInitializedRef = FutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
