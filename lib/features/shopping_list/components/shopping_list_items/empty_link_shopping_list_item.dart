import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/style/button.dart';

class EmptyLinkShoppingListItems extends HookConsumerWidget {
  final String shoppingListID;
  final ValueNotifier<List<GroupShoppingListItem>> shoppingListItems;
  const EmptyLinkShoppingListItems(
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
                child: Text('ECサイトメモが空です'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: outlinedButtonStyle,
                child: const Text('最初のECサイトメモを作成しましょう！'),
                onPressed: () {
                  // showModalBottomSheet(
                  //   context: context,
                  //   builder: (context) => AppResolvers(
                  //     builder: (context, user) => LinkShoppingListItemAddPage(
                  //       shoppingListID: shoppingListID,
                  //       shoppingListItems: shoppingListItems.value,
                  //       linkShoppingListItem: LinkShoppingListItem(url: '', shoppingListID: shoppingListID, order: shoppingListItems.value.length),
                  //     ),
                  //   ),
                  // );
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
