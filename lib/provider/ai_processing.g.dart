// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_processing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aIProcessingHash() => r'0f8d22f5c479b1c3c936ba592b3775337dbfcd4a';

/// 画面横断で「AI 処理中バナー」を表示するためのフラグ。
/// `null` のとき非表示、値が入っているとそのタイプのバナーを表示する。
/// 画像/URL 起動側で `start(...)` を呼び、結果到着 / エラー時に `end()` を呼ぶ。
///
/// Copied from [AIProcessing].
@ProviderFor(AIProcessing)
final aIProcessingProvider =
    AutoDisposeNotifierProvider<AIProcessing, AIProcessingType?>.internal(
  AIProcessing.new,
  name: r'aIProcessingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aIProcessingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AIProcessing = AutoDisposeNotifier<AIProcessingType?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
