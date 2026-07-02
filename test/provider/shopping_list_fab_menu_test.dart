import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/shopping_list_fab_menu.dart';

/// ダブル FAB の展開メニュー開閉を共有管理する `ShoppingListFabMenu` の回帰テスト。
/// - 初期状態は閉じている（null）
/// - もう一方の FAB を開くと単一状態の置き換えで前のメニューが閉じる（要件: もう一方FAB選択時）
/// - close() は冪等
/// - 開いてから 3 秒で自動クローズする（要件: 3秒経過でクローズ）
void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('初期状態は閉じている（null）', () {
    final container = makeContainer();
    expect(container.read(shoppingListFabMenuProvider), isNull);
  });

  test('open で該当 FAB のメニューが開く', () {
    final container = makeContainer();
    container
        .read(shoppingListFabMenuProvider.notifier)
        .open(ShoppingListFabMenuKind.addItem);
    expect(
      container.read(shoppingListFabMenuProvider),
      ShoppingListFabMenuKind.addItem,
    );
  });

  test('もう一方の FAB を開くと単一状態の置き換えで前のメニューが閉じる', () {
    final container = makeContainer();
    final notifier = container.read(shoppingListFabMenuProvider.notifier);

    notifier.open(ShoppingListFabMenuKind.addItem);
    notifier.open(ShoppingListFabMenuKind.createList);

    expect(
      container.read(shoppingListFabMenuProvider),
      ShoppingListFabMenuKind.createList,
      reason: 'addItem を開いた状態で createList を開くと createList に置き換わる',
    );
  });

  test('close でメニューが閉じ、既に閉じていても安全（冪等）', () {
    final container = makeContainer();
    final notifier = container.read(shoppingListFabMenuProvider.notifier);

    notifier.open(ShoppingListFabMenuKind.createList);
    notifier.close();
    expect(container.read(shoppingListFabMenuProvider), isNull);

    // 既に閉じている状態で再度 close しても例外なく null のまま。
    notifier.close();
    expect(container.read(shoppingListFabMenuProvider), isNull);
  });

  test('開いてから 3 秒で自動クローズする', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      // autoDispose の Provider を生存させる（実アプリでは FAB が watch して保持する状況を再現）。
      container.listen(shoppingListFabMenuProvider, (_, _) {});
      final notifier = container.read(shoppingListFabMenuProvider.notifier);

      notifier.open(ShoppingListFabMenuKind.addItem);
      expect(
        container.read(shoppingListFabMenuProvider),
        ShoppingListFabMenuKind.addItem,
      );

      // 3 秒経過前は開いたまま。
      async.elapse(const Duration(seconds: 2));
      expect(
        container.read(shoppingListFabMenuProvider),
        ShoppingListFabMenuKind.addItem,
      );

      // 3 秒経過で自動的に閉じる。
      async.elapse(const Duration(seconds: 1));
      expect(container.read(shoppingListFabMenuProvider), isNull);

      container.dispose();
    });
  });

  test('再度 open すると自動クローズタイマーが貼り直される', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      // autoDispose の Provider を生存させる（実アプリでは FAB が watch して保持する状況を再現）。
      container.listen(shoppingListFabMenuProvider, (_, _) {});
      final notifier = container.read(shoppingListFabMenuProvider.notifier);

      notifier.open(ShoppingListFabMenuKind.addItem);
      async.elapse(const Duration(seconds: 2));
      // 2 秒時点で開き直す → タイマーがリセットされる。
      notifier.open(ShoppingListFabMenuKind.addItem);

      // 最初の open から 3 秒（=開き直しから 1 秒）ではまだ開いている。
      async.elapse(const Duration(seconds: 1));
      expect(
        container.read(shoppingListFabMenuProvider),
        ShoppingListFabMenuKind.addItem,
        reason: 'open のたびにタイマーが貼り直されるため、直近の open から 3 秒で閉じる',
      );

      // 開き直しから 3 秒でようやく閉じる。
      async.elapse(const Duration(seconds: 2));
      expect(container.read(shoppingListFabMenuProvider), isNull);

      container.dispose();
    });
  });
}
