import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/recently_added_shopping_list_item.dart';

void main() {
  test('書き込み完了順が前後しても最後に確定した入力だけを強調する', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      recentlyAddedShoppingListItemProvider('shopping-list'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final notifier = container.read(
      recentlyAddedShoppingListItemProvider('shopping-list').notifier,
    );

    final firstSubmission = notifier.beginSubmission();
    final secondSubmission = notifier.beginSubmission();
    notifier.highlightIfLatest(
      submissionSequence: firstSubmission,
      shoppingListItemID: 'first-item',
    );
    expect(
      container.read(recentlyAddedShoppingListItemProvider('shopping-list')),
      isNull,
    );

    notifier.highlightIfLatest(
      submissionSequence: secondSubmission,
      shoppingListItemID: 'second-item',
    );
    expect(
      container.read(recentlyAddedShoppingListItemProvider('shopping-list')),
      'second-item',
    );
  });
}
