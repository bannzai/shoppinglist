// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_usage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 現在月のAI利用回数をリアルタイム購読するProvider。

@ProviderFor(currentMonthAIUsage)
final currentMonthAIUsageProvider = CurrentMonthAIUsageProvider._();

/// 現在月のAI利用回数をリアルタイム購読するProvider。

final class CurrentMonthAIUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserAIUsage?>,
          UserAIUsage?,
          Stream<UserAIUsage?>
        >
    with $FutureModifier<UserAIUsage?>, $StreamProvider<UserAIUsage?> {
  /// 現在月のAI利用回数をリアルタイム購読するProvider。
  CurrentMonthAIUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMonthAIUsageProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[userDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CurrentMonthAIUsageProvider.$allTransitiveDependencies0,
          CurrentMonthAIUsageProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = userDatabaseProvider;
  static final $allTransitiveDependencies1 =
      UserDatabaseProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$currentMonthAIUsageHash();

  @$internal
  @override
  $StreamProviderElement<UserAIUsage?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserAIUsage?> create(Ref ref) {
    return currentMonthAIUsage(ref);
  }
}

String _$currentMonthAIUsageHash() =>
    r'3d8355d9a3949fc1cc7c962144e0108db902cfde';

/// 現在月のAI画像認識の残り回数を返すProvider。

@ProviderFor(remainingImageRecognitionCount)
final remainingImageRecognitionCountProvider =
    RemainingImageRecognitionCountFamily._();

/// 現在月のAI画像認識の残り回数を返すProvider。

final class RemainingImageRecognitionCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 現在月のAI画像認識の残り回数を返すProvider。
  RemainingImageRecognitionCountProvider._({
    required RemainingImageRecognitionCountFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'remainingImageRecognitionCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = currentMonthAIUsageProvider;
  static final $allTransitiveDependencies1 =
      CurrentMonthAIUsageProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      CurrentMonthAIUsageProvider.$allTransitiveDependencies1;

  @override
  String debugGetCreateSourceHash() => _$remainingImageRecognitionCountHash();

  @override
  String toString() {
    return r'remainingImageRecognitionCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as bool;
    return remainingImageRecognitionCount(ref, isPremium: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemainingImageRecognitionCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remainingImageRecognitionCountHash() =>
    r'9bde2770216ed8bfbf8ab3aab78db52a1b656d5c';

/// 現在月のAI画像認識の残り回数を返すProvider。

final class RemainingImageRecognitionCountFamily extends $Family
    with $FunctionalFamilyOverride<int, bool> {
  RemainingImageRecognitionCountFamily._()
    : super(
        retry: null,
        name: r'remainingImageRecognitionCountProvider',
        dependencies: <ProviderOrFamily>[currentMonthAIUsageProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          RemainingImageRecognitionCountProvider.$allTransitiveDependencies0,
          RemainingImageRecognitionCountProvider.$allTransitiveDependencies1,
          RemainingImageRecognitionCountProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  /// 現在月のAI画像認識の残り回数を返すProvider。

  RemainingImageRecognitionCountProvider call({required bool isPremium}) =>
      RemainingImageRecognitionCountProvider._(argument: isPremium, from: this);

  @override
  String toString() => r'remainingImageRecognitionCountProvider';
}

/// 現在月のURL認識の残り回数を返すProvider。

@ProviderFor(remainingURLRecognitionCount)
final remainingURLRecognitionCountProvider =
    RemainingURLRecognitionCountFamily._();

/// 現在月のURL認識の残り回数を返すProvider。

final class RemainingURLRecognitionCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 現在月のURL認識の残り回数を返すProvider。
  RemainingURLRecognitionCountProvider._({
    required RemainingURLRecognitionCountFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'remainingURLRecognitionCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = currentMonthAIUsageProvider;
  static final $allTransitiveDependencies1 =
      CurrentMonthAIUsageProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      CurrentMonthAIUsageProvider.$allTransitiveDependencies1;

  @override
  String debugGetCreateSourceHash() => _$remainingURLRecognitionCountHash();

  @override
  String toString() {
    return r'remainingURLRecognitionCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as bool;
    return remainingURLRecognitionCount(ref, isPremium: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemainingURLRecognitionCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remainingURLRecognitionCountHash() =>
    r'430b41d057a58b5d4a7bf1be275aea2fd688e1ed';

/// 現在月のURL認識の残り回数を返すProvider。

final class RemainingURLRecognitionCountFamily extends $Family
    with $FunctionalFamilyOverride<int, bool> {
  RemainingURLRecognitionCountFamily._()
    : super(
        retry: null,
        name: r'remainingURLRecognitionCountProvider',
        dependencies: <ProviderOrFamily>[currentMonthAIUsageProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          RemainingURLRecognitionCountProvider.$allTransitiveDependencies0,
          RemainingURLRecognitionCountProvider.$allTransitiveDependencies1,
          RemainingURLRecognitionCountProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  /// 現在月のURL認識の残り回数を返すProvider。

  RemainingURLRecognitionCountProvider call({required bool isPremium}) =>
      RemainingURLRecognitionCountProvider._(argument: isPremium, from: this);

  @override
  String toString() => r'remainingURLRecognitionCountProvider';
}

/// 現在月のAIカテゴリ分けの残り回数を返すProvider。

@ProviderFor(remainingCategorizeCount)
final remainingCategorizeCountProvider = RemainingCategorizeCountFamily._();

/// 現在月のAIカテゴリ分けの残り回数を返すProvider。

final class RemainingCategorizeCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 現在月のAIカテゴリ分けの残り回数を返すProvider。
  RemainingCategorizeCountProvider._({
    required RemainingCategorizeCountFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'remainingCategorizeCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = currentMonthAIUsageProvider;
  static final $allTransitiveDependencies1 =
      CurrentMonthAIUsageProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      CurrentMonthAIUsageProvider.$allTransitiveDependencies1;

  @override
  String debugGetCreateSourceHash() => _$remainingCategorizeCountHash();

  @override
  String toString() {
    return r'remainingCategorizeCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as bool;
    return remainingCategorizeCount(ref, isPremium: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemainingCategorizeCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remainingCategorizeCountHash() =>
    r'45ac5f01ade8a165b79e74919134b5c2311f75d0';

/// 現在月のAIカテゴリ分けの残り回数を返すProvider。

final class RemainingCategorizeCountFamily extends $Family
    with $FunctionalFamilyOverride<int, bool> {
  RemainingCategorizeCountFamily._()
    : super(
        retry: null,
        name: r'remainingCategorizeCountProvider',
        dependencies: <ProviderOrFamily>[currentMonthAIUsageProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          RemainingCategorizeCountProvider.$allTransitiveDependencies0,
          RemainingCategorizeCountProvider.$allTransitiveDependencies1,
          RemainingCategorizeCountProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  /// 現在月のAIカテゴリ分けの残り回数を返すProvider。

  RemainingCategorizeCountProvider call({required bool isPremium}) =>
      RemainingCategorizeCountProvider._(argument: isPremium, from: this);

  @override
  String toString() => r'remainingCategorizeCountProvider';
}
