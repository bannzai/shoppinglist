// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appIsReleased)
final appIsReleasedProvider = AppIsReleasedProvider._();

final class AppIsReleasedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  AppIsReleasedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appIsReleasedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appIsReleasedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return appIsReleased(ref);
  }
}

String _$appIsReleasedHash() => r'cd68fb9b60121a2c8e19d2db9057c4deca0fb528';
