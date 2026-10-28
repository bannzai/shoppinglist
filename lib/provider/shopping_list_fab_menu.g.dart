// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_fab_menu.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アイテム追加 FAB（`ExpandableFab`）の展開メニューの開閉を管理する Notifier。
///
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。

@ProviderFor(ShoppingListFabMenu)
final shoppingListFabMenuProvider = ShoppingListFabMenuProvider._();

/// アイテム追加 FAB（`ExpandableFab`）の展開メニューの開閉を管理する Notifier。
///
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。
final class ShoppingListFabMenuProvider
    extends $NotifierProvider<ShoppingListFabMenu, bool> {
  /// アイテム追加 FAB（`ExpandableFab`）の展開メニューの開閉を管理する Notifier。
  ///
  /// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
  /// - スクロール等の外部イベントからは `close()` を呼んで閉じる。
  ShoppingListFabMenuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingListFabMenuProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingListFabMenuHash();

  @$internal
  @override
  ShoppingListFabMenu create() => ShoppingListFabMenu();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shoppingListFabMenuHash() =>
    r'7c095a5a46970774d91295e21f2fc98f61205fba';

/// アイテム追加 FAB（`ExpandableFab`）の展開メニューの開閉を管理する Notifier。
///
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。

abstract class _$ShoppingListFabMenu extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
