// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_fab_menu.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingListFabMenuHash() =>
    r'98050cd891a762b9479a267f23d47be4d30cce67';

/// ダブル FAB の展開メニューの開閉を一元管理する Notifier。
///
/// 開閉状態を 2 つの FAB で共有することで以下を満たす:
/// - もう一方の FAB を開くと、単一状態の置き換えにより前のメニューが自動的に閉じる。
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。
///
/// Copied from [ShoppingListFabMenu].
@ProviderFor(ShoppingListFabMenu)
final shoppingListFabMenuProvider = AutoDisposeNotifierProvider<
  ShoppingListFabMenu,
  ShoppingListFabMenuKind?
>.internal(
  ShoppingListFabMenu.new,
  name: r'shoppingListFabMenuProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shoppingListFabMenuHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShoppingListFabMenu = AutoDisposeNotifier<ShoppingListFabMenuKind?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
