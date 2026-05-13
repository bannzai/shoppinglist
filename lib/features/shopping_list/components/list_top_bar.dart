import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_round_button.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/features/shopping_list_item_filter/page.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// ShoppingListPage の最上段（高さ 48）。
/// `design_handoff_shopping_list/source/screens-list.jsx#ListTopBar` 相当。
/// 左にリスト名 + ▼（タップでリスト切替シート）、右に filter / more-h の 2 ボタン。
/// AvatarStack は最新のデザイン（screens-list.jsx）には無いので持たない。
class ListTopBar extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> sortByCategory;
  final void Function(String newID) onShoppingListIDChanged;

  const ListTopBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.showChecked,
    required this.sortByCategory,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Row(
          children: [
            InkWell(
              onTap: shoppingLists.isEmpty
                  ? null
                  : () {
                      analytics.logEvent(
                        name: 'tap_open_list_picker',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                        },
                      );
                      FocusScope.of(context).unfocus();
                      appShowModalBottomSheet(
                        context: context,
                        builder: (context) => ListPickerSheet(
                          groupID: groupID,
                          shoppingLists: shoppingLists,
                          currentShoppingListID: shoppingListID,
                          onShoppingListIDChanged: onShoppingListIDChanged,
                        ),
                      );
                    },
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        shoppingList?.name ?? '買い物リスト',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: tokens.neutral.ink,
                          letterSpacing: -0.17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: tokens.neutral.ink2,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // 仕様: AvatarStack は無い。 RoundBtn(filter) + RoundBtn(more-h) のみ。
            AppRoundButton(
              icon: Icons.filter_list,
              onPressed: shoppingList == null
                  ? null
                  : () {
                      analytics.logEvent(
                        name: 'tap_open_item_filter',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                        },
                      );
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ShoppingListItemFilterPage(
                          groupID: groupID,
                          shoppingListID: shoppingListID,
                          showChecked: showChecked,
                          sortByCategory: sortByCategory,
                        ),
                      ));
                    },
            ),
            const SizedBox(width: 4),
            AppRoundButton(
              icon: Icons.more_horiz,
              onPressed: shoppingList == null
                  ? null
                  : () {
                      analytics.logEvent(
                        name: 'tap_open_list_setting',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                        },
                      );
                      FocusScope.of(context).unfocus();
                      appShowModalBottomSheet(
                        context: context,
                        builder: (sheetContext) => ShoppingListSettingPage(
                          groupID: groupID,
                          shoppingListID: shoppingListID,
                          shoppingList: shoppingList!,
                          onDelete: () {
                            ref
                                .read(shoppingListDeleteProvider(
                                    groupID: groupID))
                                .call(shoppingListID: shoppingListID);
                            Navigator.of(sheetContext)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
