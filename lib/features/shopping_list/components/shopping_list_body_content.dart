import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/receipt/receipt_section.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// ShoppingListPage のメインコンテンツ部分。
/// アイテムが空のときは [EmptyTextShoppingListItems] を表示し、
/// それ以外では複製元リストへのリンク（複製で作られたリストのときのみ）と [ShoppingListItems] を表示する。
class ShoppingListBodyContent extends StatelessWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final List<GroupShoppingListItem> shoppingListItems;
  final void Function(String newID) onShoppingListIDChanged;

  const ShoppingListBodyContent({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.shoppingListItems,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    if (shoppingListItems.isEmpty) {
      return EmptyTextShoppingListItems(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListItems: shoppingListItems,
      );
    }
    return Column(
      children: [
        if (shoppingList?.duplicatedFromGroupShoppingListID != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              final sourceID = shoppingList!.duplicatedFromGroupShoppingListID!;
              analytics.logEvent(name: 'tap_navigate_source_list', parameters: {
                'groupID': groupID,
                'shoppingListID': shoppingListID,
                'sourceShoppingListID': sourceID,
              });
              if (shoppingLists.any((sl) => sl.id == sourceID)) {
                onShoppingListIDChanged(sourceID);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('複製元の買い物リストは削除されています')),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_copy, size: 14, color: tokens.accent),
                const SizedBox(width: 4),
                Text(
                  '${shoppingLists.firstWhereOrNull((sl) => sl.id == shoppingList!.duplicatedFromGroupShoppingListID)?.name ?? "削除済みリスト"}から複製',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.accent,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        Expanded(
          child: ShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingLocationID: shoppingList?.shoppingLocationID,
          ),
        ),
        // 買い物が始まった/終わった後（チェック済みが1件以上）にのみ、リスト末尾に
        // レシート登録の導線を出す。
        if (shoppingListItemMetrics(shoppingListItems).checkedCount > 0)
          ReceiptSection(groupID: groupID, shoppingListID: shoppingListID),
      ],
    );
  }
}
