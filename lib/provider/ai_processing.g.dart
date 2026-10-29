// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_processing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 画面横断で「AI 処理中バナー」を表示するためのフラグ。
/// `null` のとき非表示、値が入っているとそのタイプのバナーを表示する。
/// 画像/URL 起動側で `start(...)` を呼び、結果到着 / エラー時に `end()` を呼ぶ。

@ProviderFor(AIProcessing)
final aIProcessingProvider = AIProcessingProvider._();

/// 画面横断で「AI 処理中バナー」を表示するためのフラグ。
/// `null` のとき非表示、値が入っているとそのタイプのバナーを表示する。
/// 画像/URL 起動側で `start(...)` を呼び、結果到着 / エラー時に `end()` を呼ぶ。
final class AIProcessingProvider
    extends $NotifierProvider<AIProcessing, AIProcessingType?> {
  /// 画面横断で「AI 処理中バナー」を表示するためのフラグ。
  /// `null` のとき非表示、値が入っているとそのタイプのバナーを表示する。
  /// 画像/URL 起動側で `start(...)` を呼び、結果到着 / エラー時に `end()` を呼ぶ。
  AIProcessingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aIProcessingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aIProcessingHash();

  @$internal
  @override
  AIProcessing create() => AIProcessing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIProcessingType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIProcessingType?>(value),
    );
  }
}

String _$aIProcessingHash() => r'0f8d22f5c479b1c3c936ba592b3775337dbfcd4a';

/// 画面横断で「AI 処理中バナー」を表示するためのフラグ。
/// `null` のとき非表示、値が入っているとそのタイプのバナーを表示する。
/// 画像/URL 起動側で `start(...)` を呼び、結果到着 / エラー時に `end()` を呼ぶ。

abstract class _$AIProcessing extends $Notifier<AIProcessingType?> {
  AIProcessingType? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AIProcessingType?, AIProcessingType?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AIProcessingType?, AIProcessingType?>,
              AIProcessingType?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
