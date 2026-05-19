// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasSeenOnboardingHash() => r'598bf8801135be4505600f53027381571357f5c7';

/// オンボーディング画面（OnboardingPage）を表示済みかどうか。
/// `false` のときに未認証ユーザーへ OnboardingPage を出す。
/// 完了時に `markAsSeen()` を呼ぶと SharedPreferences に true が永続化される。
///
/// Copied from [HasSeenOnboarding].
@ProviderFor(HasSeenOnboarding)
final hasSeenOnboardingProvider =
    NotifierProvider<HasSeenOnboarding, bool>.internal(
  HasSeenOnboarding.new,
  name: r'hasSeenOnboardingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasSeenOnboardingHash,
  dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    sharedPreferencesProvider,
    ...?sharedPreferencesProvider.allTransitiveDependencies
  },
);

typedef _$HasSeenOnboarding = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
