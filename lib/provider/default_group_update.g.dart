// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_group_update.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultGroupUpdate)
final defaultGroupUpdateProvider = DefaultGroupUpdateProvider._();

final class DefaultGroupUpdateProvider
    extends
        $FunctionalProvider<
          DefaultGroupUpdate,
          DefaultGroupUpdate,
          DefaultGroupUpdate
        >
    with $Provider<DefaultGroupUpdate> {
  DefaultGroupUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultGroupUpdateProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[userDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          DefaultGroupUpdateProvider.$allTransitiveDependencies0,
          DefaultGroupUpdateProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = userDatabaseProvider;
  static final $allTransitiveDependencies1 =
      UserDatabaseProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$defaultGroupUpdateHash();

  @$internal
  @override
  $ProviderElement<DefaultGroupUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DefaultGroupUpdate create(Ref ref) {
    return defaultGroupUpdate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefaultGroupUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefaultGroupUpdate>(value),
    );
  }
}

String _$defaultGroupUpdateHash() =>
    r'14dc7bb6ee08c6921daf4c795fa16abe52ba8396';
