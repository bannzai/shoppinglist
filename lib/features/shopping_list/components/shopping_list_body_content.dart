import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/receipt/receipt_section.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';
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
    // 買い物が始まった/終わった後（チェック済みが1件以上）にのみレシートの導線を出す。
    final hasCheckedItem =
        shoppingListItemMetrics(shoppingListItems).checkedCount > 0;
    return Column(
      children: [
        if (shoppingList?.duplicatedFromGroupShoppingListID != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              final sourceID = shoppingList!.duplicatedFromGroupShoppingListID!;
              analytics.logEvent(
                name: 'tap_navigate_source_list',
                parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                  'sourceShoppingListID': sourceID,
                },
              );
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
        // レシートの導線は、長いリストでも気づけるよう上部（AIカテゴリ分けボタンの
        // 直上）に控えめな pill で出す。レシートの有無はこのボタンのラベル
        // （追加 / 編集）で表現し、最下部のサムネ一覧は廃止した。
        if (hasCheckedItem)
          ReceiptAddButton(groupID: groupID, shoppingListID: shoppingListID),
        Expanded(
          child: ShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            // 店舗ごとの並び順はファーストリリースでは非表示のため、保存済みの
            // shoppingLocationID があっても表示・並び替えに反映しない (issue #465)。
            shoppingLocationID:
                shoppingLocationFeatureEnabled
                    ? shoppingList?.shoppingLocationID
                    : null,
          ),
        ),
      ],
    );
  }
}
