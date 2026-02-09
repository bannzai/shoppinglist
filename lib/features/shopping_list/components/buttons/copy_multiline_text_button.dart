import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

class CopyMultilineTextButton extends HookConsumerWidget {
  final String shoppingListID;
  final List<ShoppingListItem> shoppingListItems;

  const CopyMultilineTextButton(
      {super.key,
      required this.shoppingListID,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text != null) {
          final lines = text.split('\n').toSet();
          for (final (index, line) in lines.indexed) {
            if (shoppingListItems.any((item) =>
                item is TextShoppingListItem && item.message == line)) {
              continue;
            }
            await ref.read(addTextShoppingListItemProvider).call(
                  shoppingListID: shoppingListID,
                  message: line,
                  order: shoppingListItems.nextOrder + index,
                );
          }
        }
      },
      child: const Icon(Icons.content_paste_go),
    );
  }
}
