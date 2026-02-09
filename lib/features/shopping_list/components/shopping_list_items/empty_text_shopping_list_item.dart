import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/button.dart';

class EmptyTextShoppingListItems extends HookConsumerWidget {
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  const EmptyTextShoppingListItems(
      {super.key,
      required this.shoppingListID,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Column(
            children: [
              const Center(
                child: Text('買い物リストが空です'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: outlinedButtonStyle,
                child: const Text('最初の買い物リストを作成しましょう！'),
                onPressed: () {
                  ref.read(addTextShoppingListItemProvider).call(
                        shoppingListID: shoppingListID,
                        message: '',
                        order: shoppingListItems.nextOrder,
                      );
                },
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
