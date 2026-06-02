import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/settings/page.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// ShoppingListPage の最上段（高さ 52）。
/// `design_handoff_shopping_list/source/screens-list.jsx#ListTopBar` 相当。
/// 左にリスト名 + ▼（タップでリスト切替シート）、右にリスト設定（…）と設定アイコン。
class ListTopBar extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final void Function(String newID) onShoppingListIDChanged;

  const ListTopBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final appUser = ref.watch(appUserProvider).asData?.value;

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
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
                            appUser: appUser,
                          ),
                        );
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        shoppingList?.name ?? '買い物リスト',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: tokens.neutral.ink,
                              letterSpacing: -0.17,
                            ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: tokens.neutral.ink2,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              key: const Key('list_setting_button'),
              icon: Icon(
                Icons.more_horiz,
                size: 22,
                color: tokens.neutral.ink2,
              ),
              tooltip: 'リスト設定',
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
            IconButton(
              key: const Key('app_settings_button'),
              icon: Icon(
                Icons.settings_outlined,
                size: 22,
                color: tokens.neutral.ink2,
              ),
              tooltip: '設定',
              onPressed: () {
                analytics.logEvent(
                    name: 'tap_open_app_setting', parameters: null);
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingPage(),
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
