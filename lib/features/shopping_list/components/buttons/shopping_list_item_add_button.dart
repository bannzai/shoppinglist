import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

class ShoppingListItemAddButton extends HookConsumerWidget {
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const ShoppingListItemAddButton(
      {super.key,
      required this.shoppingListID,
      required this.shoppingListItems});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        ref.read(addTextShoppingListItemProvider).call(
              shoppingListID: shoppingListID,
              message: '',
              order: shoppingListItems.nextOrder,
            );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Icon(Icons.add),
      ),
    );
  }
}
