import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class CopyMultilineTextButton extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const CopyMultilineTextButton(
      {super.key,
      required this.groupID,
      required this.shoppingListID,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        analytics.logEvent(name: 'tap_paste_multiline', parameters: {'groupID': groupID, 'shoppingListID': shoppingListID});
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text != null) {
          final lines = text.split('\n').toSet();
          for (final (index, line) in lines.indexed) {
            if (shoppingListItems.any((item) =>
                item is TextGroupShoppingListItem && item.message == line)) {
              continue;
            }
            await ref
                .read(addTextShoppingListItemProvider(groupID: groupID))
                .call(
                  shoppingListID: shoppingListID,
                  message: line,
                  order: shoppingListItems.nextOrder + index,
                  groupShoppingListItemCategoryID: null,
                  description: null,
                  color: null,
                );
          }
        }
      },
      child: const Icon(Icons.content_paste_go),
    );
  }
}
