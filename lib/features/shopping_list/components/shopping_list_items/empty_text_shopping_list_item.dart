import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/button.dart';
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
                onPressed: () async {
                  final nextOrder = shoppingListItems.nextOrder;
                  debugPrint('[EmptyTextShoppingListItems] ボタン押下: shoppingListID=$shoppingListID, groupID=$groupID, nextOrder=$nextOrder');
                  analytics.logEvent(
                      name: 'tap_create_first_item',
                      parameters: {
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
                    debugPrint('[EmptyTextShoppingListItems] call() 成功: docID=${result.id}');
                  } catch (e, st) {
                    debugPrint('[EmptyTextShoppingListItems] call() 失敗: $e\n$st');
                  }
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
