// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_group_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
///
/// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
/// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
/// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。

@ProviderFor(CurrentGroupID)
final currentGroupIDProvider = CurrentGroupIDProvider._();

/// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
///
/// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
/// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
/// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。
final class CurrentGroupIDProvider
    extends $NotifierProvider<CurrentGroupID, String?> {
  /// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
  ///
  /// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
  /// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
  /// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。
  CurrentGroupIDProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentGroupIDProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentGroupIDHash();

  @$internal
  @override
  CurrentGroupID create() => CurrentGroupID();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentGroupIDHash() => r'249ca4f9127397143dc3d1b1e275770ac31987a6';

/// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
///
/// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
/// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
/// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。

abstract class _$CurrentGroupID extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
