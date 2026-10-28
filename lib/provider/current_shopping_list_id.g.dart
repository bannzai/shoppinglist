// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_shopping_list_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
/// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。

@ProviderFor(CurrentShoppingListID)
final currentShoppingListIDProvider = CurrentShoppingListIDProvider._();

/// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
/// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。
final class CurrentShoppingListIDProvider
    extends $NotifierProvider<CurrentShoppingListID, String?> {
  /// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
  /// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。
  CurrentShoppingListIDProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentShoppingListIDProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentShoppingListIDHash();

  @$internal
  @override
  CurrentShoppingListID create() => CurrentShoppingListID();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentShoppingListIDHash() =>
    r'767f84743ebb572811f0bcd00f3e4a39d7684266';

/// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
/// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。

abstract class _$CurrentShoppingListID extends $Notifier<String?> {
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
