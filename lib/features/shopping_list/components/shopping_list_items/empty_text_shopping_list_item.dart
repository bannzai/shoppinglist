import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class EmptyTextShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  const EmptyTextShoppingListItems(
      {super.key,
      required this.groupID,
      required this.shoppingListID,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              '買い物リストが空です',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'アイテムを追加して買い物を始めましょう',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final nextOrder = shoppingListItems.nextOrder;
                debugPrint(
                    '[EmptyTextShoppingListItems] ボタン押下: shoppingListID=$shoppingListID, groupID=$groupID, nextOrder=$nextOrder');
                analytics.logEvent(name: 'tap_create_first_item', parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID
                });
                try {
                  final result = await ref
                      .read(addShoppingListItemProvider(groupID: groupID))
                      .call(
                        shoppingListID: shoppingListID,
                        message: '',
                        order: nextOrder,
                        groupShoppingListItemCategoryID: null,
                        description: null,
                        color: null,
                      );
                  debugPrint(
                      '[EmptyTextShoppingListItems] call() 成功: docID=${result.id}');
                } catch (e, st) {
                  debugPrint('[EmptyTextShoppingListItems] call() 失敗: $e\n$st');
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('アイテムを追加'),
            ),
          ],
        ),
      ),
    );
  }
}
