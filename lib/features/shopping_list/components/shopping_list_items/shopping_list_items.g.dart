// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_items.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 入力行 GlobalKey レジストリ。アプリ起動中ずっと同一インスタンスを保持する
/// (リビルドを跨いで GlobalKey を維持しキーボードを閉じさせないため keepAlive)。

@ProviderFor(shoppingListItemRowKeys)
final shoppingListItemRowKeysProvider = ShoppingListItemRowKeysProvider._();

/// 入力行 GlobalKey レジストリ。アプリ起動中ずっと同一インスタンスを保持する
/// (リビルドを跨いで GlobalKey を維持しキーボードを閉じさせないため keepAlive)。

final class ShoppingListItemRowKeysProvider
    extends
        $FunctionalProvider<
          ShoppingListItemRowKeys,
          ShoppingListItemRowKeys,
          ShoppingListItemRowKeys
        >
    with $Provider<ShoppingListItemRowKeys> {
  /// 入力行 GlobalKey レジストリ。アプリ起動中ずっと同一インスタンスを保持する
  /// (リビルドを跨いで GlobalKey を維持しキーボードを閉じさせないため keepAlive)。
  ShoppingListItemRowKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingListItemRowKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingListItemRowKeysHash();

  @$internal
  @override
  $ProviderElement<ShoppingListItemRowKeys> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingListItemRowKeys create(Ref ref) {
    return shoppingListItemRowKeys(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListItemRowKeys value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListItemRowKeys>(value),
    );
  }
}

String _$shoppingListItemRowKeysHash() =>
    r'31d07700acbc86099db9f1e2e030912f632f547f';
