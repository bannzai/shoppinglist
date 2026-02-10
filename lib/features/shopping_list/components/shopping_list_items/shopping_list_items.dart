import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/link_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

class ShoppingListItems extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const ShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListItemBatchUpdate =
        ref.watch(shoppingListItemBatchUpdateProvider(groupID: groupID));
    final items = useState(shoppingListItems);

    return ReorderableList(
      onReorder: (oldIndex, newIndex) {
        // NOTE: ドラッグ時にリストから要素を一時的に削除するため、newIndex が1つずれるのを調整。
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        debugPrint('oldIndex: $oldIndex, newIndex: $newIndex');

        final changedItems = [...items.value];
        final movedItem = changedItems.removeAt(oldIndex);
        changedItems.insert(newIndex, movedItem);

        // 更新したリストに基づき order を再計算
        final orderedItems = changedItems
            .asMap()
            .entries
            .map((entry) => entry.value.copyWith(order: entry.key))
            .toList();

        items.value = [...orderedItems];

        shoppingListItemBatchUpdate.call(
          shoppingListID: shoppingListID,
          shoppingListItems: orderedItems,
        );
      },
      itemCount: items.value.length,
      itemBuilder: (context, index) {
        final item = items.value[index];

        return switch (item) {
          TextGroupShoppingListItem textItem => TextShoppingListItemWidget(
              key: ValueKey(item.id),
              groupID: groupID,
              textShoppingListItem: textItem,
              shoppingListItems: items.value),
          LinkGroupShoppingListItem linkItem => LinkShoppingListItemWidget(
              key: ValueKey(item.id),
              linkShoppingListItem: linkItem,
              shoppingListItems: items.value),
        };
      },
    );
  }
}
