// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_usage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentMonthAIUsageHash() =>
    r'3d8355d9a3949fc1cc7c962144e0108db902cfde';

/// 現在月のAI利用回数をリアルタイム購読するProvider。
///
/// Copied from [currentMonthAIUsage].
@ProviderFor(currentMonthAIUsage)
final currentMonthAIUsageProvider =
    AutoDisposeStreamProvider<UserAIUsage?>.internal(
  currentMonthAIUsage,
  name: r'currentMonthAIUsageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMonthAIUsageHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMonthAIUsageRef = AutoDisposeStreamProviderRef<UserAIUsage?>;
String _$remainingImageRecognitionCountHash() =>
    r'c3cf4729e2a50d7d66c6779309b687ce8c802dc3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 現在月のAI画像認識の残り回数を返すProvider。
///
/// Copied from [remainingImageRecognitionCount].
@ProviderFor(remainingImageRecognitionCount)
const remainingImageRecognitionCountProvider =
    RemainingImageRecognitionCountFamily();

/// 現在月のAI画像認識の残り回数を返すProvider。
///
/// Copied from [remainingImageRecognitionCount].
class RemainingImageRecognitionCountFamily extends Family<int> {
  /// 現在月のAI画像認識の残り回数を返すProvider。
  ///
  /// Copied from [remainingImageRecognitionCount].
  const RemainingImageRecognitionCountFamily();

  /// 現在月のAI画像認識の残り回数を返すProvider。
  ///
  /// Copied from [remainingImageRecognitionCount].
  RemainingImageRecognitionCountProvider call({
    required bool isPremium,
  }) {
    return RemainingImageRecognitionCountProvider(
      isPremium: isPremium,
    );
  }

  @override
  RemainingImageRecognitionCountProvider getProviderOverride(
    covariant RemainingImageRecognitionCountProvider provider,
  ) {
    return call(
      isPremium: provider.isPremium,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    currentMonthAIUsageProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    currentMonthAIUsageProvider,
    ...?currentMonthAIUsageProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'remainingImageRecognitionCountProvider';
}

/// 現在月のAI画像認識の残り回数を返すProvider。
///
/// Copied from [remainingImageRecognitionCount].
class RemainingImageRecognitionCountProvider extends AutoDisposeProvider<int> {
  /// 現在月のAI画像認識の残り回数を返すProvider。
  ///
  /// Copied from [remainingImageRecognitionCount].
  RemainingImageRecognitionCountProvider({
    required bool isPremium,
  }) : this._internal(
          (ref) => remainingImageRecognitionCount(
            ref as RemainingImageRecognitionCountRef,
            isPremium: isPremium,
          ),
          from: remainingImageRecognitionCountProvider,
          name: r'remainingImageRecognitionCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$remainingImageRecognitionCountHash,
          dependencies: RemainingImageRecognitionCountFamily._dependencies,
          allTransitiveDependencies:
              RemainingImageRecognitionCountFamily._allTransitiveDependencies,
          isPremium: isPremium,
        );

  RemainingImageRecognitionCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isPremium,
  }) : super.internal();

  final bool isPremium;

  @override
  Override overrideWith(
    int Function(RemainingImageRecognitionCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RemainingImageRecognitionCountProvider._internal(
        (ref) => create(ref as RemainingImageRecognitionCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isPremium: isPremium,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _RemainingImageRecognitionCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RemainingImageRecognitionCountProvider &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isPremium.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RemainingImageRecognitionCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `isPremium` of this provider.
  bool get isPremium;
}

class _RemainingImageRecognitionCountProviderElement
    extends AutoDisposeProviderElement<int>
    with RemainingImageRecognitionCountRef {
  _RemainingImageRecognitionCountProviderElement(super.provider);

  @override
  bool get isPremium =>
      (origin as RemainingImageRecognitionCountProvider).isPremium;
}

String _$remainingURLRecognitionCountHash() =>
    r'42983c98457de1831d18a9efef262310643eaa80';

/// 現在月のURL認識の残り回数を返すProvider。
///
/// Copied from [remainingURLRecognitionCount].
@ProviderFor(remainingURLRecognitionCount)
const remainingURLRecognitionCountProvider =
    RemainingURLRecognitionCountFamily();

/// 現在月のURL認識の残り回数を返すProvider。
///
/// Copied from [remainingURLRecognitionCount].
class RemainingURLRecognitionCountFamily extends Family<int> {
  /// 現在月のURL認識の残り回数を返すProvider。
  ///
  /// Copied from [remainingURLRecognitionCount].
  const RemainingURLRecognitionCountFamily();

  /// 現在月のURL認識の残り回数を返すProvider。
  ///
  /// Copied from [remainingURLRecognitionCount].
  RemainingURLRecognitionCountProvider call({
    required bool isPremium,
  }) {
    return RemainingURLRecognitionCountProvider(
      isPremium: isPremium,
    );
  }

  @override
  RemainingURLRecognitionCountProvider getProviderOverride(
    covariant RemainingURLRecognitionCountProvider provider,
  ) {
    return call(
      isPremium: provider.isPremium,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    currentMonthAIUsageProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    currentMonthAIUsageProvider,
    ...?currentMonthAIUsageProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'remainingURLRecognitionCountProvider';
}

/// 現在月のURL認識の残り回数を返すProvider。
///
/// Copied from [remainingURLRecognitionCount].
class RemainingURLRecognitionCountProvider extends AutoDisposeProvider<int> {
  /// 現在月のURL認識の残り回数を返すProvider。
  ///
  /// Copied from [remainingURLRecognitionCount].
  RemainingURLRecognitionCountProvider({
    required bool isPremium,
  }) : this._internal(
          (ref) => remainingURLRecognitionCount(
            ref as RemainingURLRecognitionCountRef,
            isPremium: isPremium,
          ),
          from: remainingURLRecognitionCountProvider,
          name: r'remainingURLRecognitionCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$remainingURLRecognitionCountHash,
          dependencies: RemainingURLRecognitionCountFamily._dependencies,
          allTransitiveDependencies:
              RemainingURLRecognitionCountFamily._allTransitiveDependencies,
          isPremium: isPremium,
        );

  RemainingURLRecognitionCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isPremium,
  }) : super.internal();

  final bool isPremium;

  @override
  Override overrideWith(
    int Function(RemainingURLRecognitionCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RemainingURLRecognitionCountProvider._internal(
        (ref) => create(ref as RemainingURLRecognitionCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isPremium: isPremium,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _RemainingURLRecognitionCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RemainingURLRecognitionCountProvider &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isPremium.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RemainingURLRecognitionCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `isPremium` of this provider.
  bool get isPremium;
}

class _RemainingURLRecognitionCountProviderElement
    extends AutoDisposeProviderElement<int>
    with RemainingURLRecognitionCountRef {
  _RemainingURLRecognitionCountProviderElement(super.provider);

  @override
  bool get isPremium =>
      (origin as RemainingURLRecognitionCountProvider).isPremium;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
