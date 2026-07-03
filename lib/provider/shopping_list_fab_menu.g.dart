// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_fab_menu.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingListFabMenuHash() =>
    r'7c095a5a46970774d91295e21f2fc98f61205fba';

/// アイテム追加 FAB（`ExpandableFab`）の展開メニューの開閉を管理する Notifier。
///
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。
///
/// Copied from [ShoppingListFabMenu].
@ProviderFor(ShoppingListFabMenu)
final shoppingListFabMenuProvider =
    AutoDisposeNotifierProvider<ShoppingListFabMenu, bool>.internal(
      ShoppingListFabMenu.new,
      name: r'shoppingListFabMenuProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$shoppingListFabMenuHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShoppingListFabMenu = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
