import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class ShoppingListItemAddButton extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const ShoppingListItemAddButton({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addShoppingListItem = ref.watch(
      addShoppingListItemProvider(groupID: groupID),
    );
    return OutlinedButton(
      onPressed: () {
        analytics.logEvent(
          name: 'tap_add_item',
          parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
        );
        addShoppingListItem.call(
          shoppingListID: shoppingListID,
          userID: ref.read(currentUserIDProvider)!,
          message: '',
          order: shoppingListItems.nextOrder,
          description: null,
          color: null,
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Icon(Icons.add),
      ),
    );
  }
}
