import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/shopping_list_fab_menu.dart';

/// アイテム追加 FAB の展開メニュー開閉を管理する `ShoppingListFabMenu` の回帰テスト。
/// - 初期状態は閉じている（false）
/// - close() は冪等
/// - 開いてから 3 秒で自動クローズする（要件: 3秒経過でクローズ）
void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('初期状態は閉じている（false）', () {
    final container = makeContainer();
    expect(container.read(shoppingListFabMenuProvider), isFalse);
  });

  test('open でメニューが開く', () {
    final container = makeContainer();
    container.read(shoppingListFabMenuProvider.notifier).open();
    expect(container.read(shoppingListFabMenuProvider), isTrue);
  });

  test('close でメニューが閉じ、既に閉じていても安全（冪等）', () {
    final container = makeContainer();
    final notifier = container.read(shoppingListFabMenuProvider.notifier);

    notifier.open();
    notifier.close();
    expect(container.read(shoppingListFabMenuProvider), isFalse);

    // 既に閉じている状態で再度 close しても例外なく false のまま。
    notifier.close();
    expect(container.read(shoppingListFabMenuProvider), isFalse);
  });

  test('開いてから 3 秒で自動クローズする', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      // autoDispose の Provider を生存させる（実アプリでは FAB が watch して保持する状況を再現）。
      container.listen(shoppingListFabMenuProvider, (_, _) {});
      final notifier = container.read(shoppingListFabMenuProvider.notifier);

      notifier.open();
      expect(container.read(shoppingListFabMenuProvider), isTrue);

      // 3 秒経過前は開いたまま。
      async.elapse(const Duration(seconds: 2));
      expect(container.read(shoppingListFabMenuProvider), isTrue);

      // 3 秒経過で自動的に閉じる。
      async.elapse(const Duration(seconds: 1));
      expect(container.read(shoppingListFabMenuProvider), isFalse);

      container.dispose();
    });
  });

  test('再度 open すると自動クローズタイマーが貼り直される', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      // autoDispose の Provider を生存させる（実アプリでは FAB が watch して保持する状況を再現）。
      container.listen(shoppingListFabMenuProvider, (_, _) {});
      final notifier = container.read(shoppingListFabMenuProvider.notifier);

      notifier.open();
      async.elapse(const Duration(seconds: 2));
      // 2 秒時点で開き直す → タイマーがリセットされる。
      notifier.open();

      // 最初の open から 3 秒（=開き直しから 1 秒）ではまだ開いている。
      async.elapse(const Duration(seconds: 1));
      expect(
        container.read(shoppingListFabMenuProvider),
        isTrue,
        reason: 'open のたびにタイマーが貼り直されるため、直近の open から 3 秒で閉じる',
      );

      // 開き直しから 3 秒でようやく閉じる。
      async.elapse(const Duration(seconds: 2));
      expect(container.read(shoppingListFabMenuProvider), isFalse);

      container.dispose();
    });
  });
}
