// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_location.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shoppingLocations)
final shoppingLocationsProvider = ShoppingLocationsFamily._();

final class ShoppingLocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupShoppingLocation>>,
          List<GroupShoppingLocation>,
          Stream<List<GroupShoppingLocation>>
        >
    with
        $FutureModifier<List<GroupShoppingLocation>>,
        $StreamProvider<List<GroupShoppingLocation>> {
  ShoppingLocationsProvider._({
    required ShoppingLocationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingLocationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingLocationsHash();

  @override
  String toString() {
    return r'shoppingLocationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupShoppingLocation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupShoppingLocation>> create(Ref ref) {
    final argument = this.argument as String;
    return shoppingLocations(ref, groupID: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingLocationsHash() => r'7aed51dda16a45608c0db4f7a23717bdd80c6f27';

final class ShoppingLocationsFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<GroupShoppingLocation>>, String> {
  ShoppingLocationsFamily._()
    : super(
        retry: null,
        name: r'shoppingLocationsProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingLocationsProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingLocationsProvider call({required String groupID}) =>
      ShoppingLocationsProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingLocationsProvider';
}

@ProviderFor(shoppingLocationAdd)
final shoppingLocationAddProvider = ShoppingLocationAddFamily._();

final class ShoppingLocationAddProvider
    extends
        $FunctionalProvider<
          ShoppingLocationAdd,
          ShoppingLocationAdd,
          ShoppingLocationAdd
        >
    with $Provider<ShoppingLocationAdd> {
  ShoppingLocationAddProvider._({
    required ShoppingLocationAddFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingLocationAddProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingLocationAddHash();

  @override
  String toString() {
    return r'shoppingLocationAddProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingLocationAdd> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingLocationAdd create(Ref ref) {
    final argument = this.argument as String;
    return shoppingLocationAdd(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingLocationAdd value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingLocationAdd>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationAddProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingLocationAddHash() =>
    r'de0716db61107ad8cbd46cf74587fb167f6d8598';

final class ShoppingLocationAddFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingLocationAdd, String> {
  ShoppingLocationAddFamily._()
    : super(
        retry: null,
        name: r'shoppingLocationAddProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingLocationAddProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingLocationAddProvider call({required String groupID}) =>
      ShoppingLocationAddProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingLocationAddProvider';
}

@ProviderFor(shoppingLocationUpdate)
final shoppingLocationUpdateProvider = ShoppingLocationUpdateFamily._();

final class ShoppingLocationUpdateProvider
    extends
        $FunctionalProvider<
          ShoppingLocationUpdate,
          ShoppingLocationUpdate,
          ShoppingLocationUpdate
        >
    with $Provider<ShoppingLocationUpdate> {
  ShoppingLocationUpdateProvider._({
    required ShoppingLocationUpdateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingLocationUpdateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingLocationUpdateHash();

  @override
  String toString() {
    return r'shoppingLocationUpdateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingLocationUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingLocationUpdate create(Ref ref) {
    final argument = this.argument as String;
    return shoppingLocationUpdate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingLocationUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingLocationUpdate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationUpdateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingLocationUpdateHash() =>
    r'0557896dbd7b18fa7eb8f3239a5934a8688d2114';

final class ShoppingLocationUpdateFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingLocationUpdate, String> {
  ShoppingLocationUpdateFamily._()
    : super(
        retry: null,
        name: r'shoppingLocationUpdateProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingLocationUpdateProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingLocationUpdateProvider call({required String groupID}) =>
      ShoppingLocationUpdateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingLocationUpdateProvider';
}

@ProviderFor(shoppingLocationDelete)
final shoppingLocationDeleteProvider = ShoppingLocationDeleteFamily._();

final class ShoppingLocationDeleteProvider
    extends
        $FunctionalProvider<
          ShoppingLocationDelete,
          ShoppingLocationDelete,
          ShoppingLocationDelete
        >
    with $Provider<ShoppingLocationDelete> {
  ShoppingLocationDeleteProvider._({
    required ShoppingLocationDeleteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingLocationDeleteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingLocationDeleteHash();

  @override
  String toString() {
    return r'shoppingLocationDeleteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingLocationDelete> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingLocationDelete create(Ref ref) {
    final argument = this.argument as String;
    return shoppingLocationDelete(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingLocationDelete value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingLocationDelete>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationDeleteProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingLocationDeleteHash() =>
    r'7782457cf60a645870f39b136a8088058d359816';

final class ShoppingLocationDeleteFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingLocationDelete, String> {
  ShoppingLocationDeleteFamily._()
    : super(
        retry: null,
        name: r'shoppingLocationDeleteProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingLocationDeleteProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingLocationDeleteProvider call({required String groupID}) =>
      ShoppingLocationDeleteProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingLocationDeleteProvider';
}
