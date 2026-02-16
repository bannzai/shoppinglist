import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toolbar/picker.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list_item_filter/page.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class ShoppingListAppBar extends HookConsumerWidget
    implements PreferredSizeWidget {
  final String groupID;
  final ValueNotifier<String> shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> sortByCategory;
  final List<GroupShoppingListItem> shoppingListItems;
  const ShoppingListAppBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.showChecked,
    required this.sortByCategory,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = this.shoppingList;
    final shoppingListDelete =
        ref.watch(shoppingListDeleteProvider(groupID: groupID));
    final shoppingListDuplicate =
        ref.watch(shoppingListDuplicateProvider(groupID: groupID));
    final linkShoppingListItemsAsync = ref.watch(linkShoppingListItemsProvider(
      groupID: groupID,
      shoppingListID: shoppingListID.value,
    ));

    return AppBar(
      title: HookBuilder(
        builder: (context) {
          final selectedID = useState<String>(shoppingListID.value);
          return GestureDetector(
            onTap: () {
              selectedID.value = shoppingLists.first.id;
              _showPicker(context, selectedID);
            },
            child: Row(
              children: [
                Text(shoppingList?.name ?? ''),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          );
        },
      ),
      actions: [
        if (shoppingList != null) ...[
          IconButton(
            onPressed: () {
              appShowModalBottomSheet(
                context: context,
                builder: (context) {
                  return ShoppingListSettingPage(
                    groupID: groupID,
                    shoppingListID: shoppingListID.value,
                    shoppingList: shoppingList,
                    onDelete: () {
                      shoppingListDelete(shoppingListID: shoppingListID.value);
                      // pop alert
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return _AddShoppingListBottomSheet(
                    groupID: groupID,
                    shoppingList: shoppingList,
                    shoppingListID: shoppingListID,
                    shoppingListItems: shoppingListItems,
                    linkShoppingListItemsAsync: linkShoppingListItemsAsync,
                    shoppingListDuplicate: shoppingListDuplicate,
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
        IconButton(
          onPressed: () {
            appShowModalBottomSheet(
              context: context,
              builder: (context) {
                return ShoppingListItemFilterPage(
                  groupID: groupID,
                  shoppingListID: shoppingListID.value,
                  showChecked: showChecked,
                  sortByCategory: sortByCategory,
                );
              },
            );
          },
          icon: const Icon(Icons.filter_1_outlined),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context, ValueNotifier<String> selectedID) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            PickerToolbar(
              done: () {
                Navigator.pop(context);
                shoppingListID.value = selectedID.value;
              },
              cancel: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 200,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CupertinoPicker(
                  itemExtent: 40,
                  children: shoppingLists.map((sl) => Text(sl.name)).toList(),
                  onSelectedItemChanged: (int value) {
                    selectedID.value = shoppingLists[value].id;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AddShoppingListBottomSheet extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingList shoppingList;
  final ValueNotifier<String> shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  final AsyncValue<List<GroupShoppingListItem>> linkShoppingListItemsAsync;
  final ShoppingListDuplicate shoppingListDuplicate;

  const _AddShoppingListBottomSheet({
    required this.groupID,
    required this.shoppingList,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.linkShoppingListItemsAsync,
    required this.shoppingListDuplicate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final groups = userGroupsAsync.asData?.value ?? [];
    final selectedGroupID = useState(groupID);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (groups.length > 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: selectedGroupID.value,
                decoration: const InputDecoration(
                  labelText: 'グループ',
                  border: OutlineInputBorder(),
                ),
                items: groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.name ?? 'グループ'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedGroupID.value = value;
                  }
                },
              ),
            ),
          ],
          ListTile(
            title: const Text('買い物リストを追加'),
            onTap: () async {
              final addProvider = ref.read(
                  shoppingListAddProvider(groupID: selectedGroupID.value));
              final newShoppingList = await addProvider(
                createUserID: shoppingList.createUserID,
                groupID: selectedGroupID.value,
                shoppingLocationID: null,
                duplicatedFromGroupShoppingListID: null,
              );
              // 同じグループの場合のみshoppingListIDを切り替える
              if (selectedGroupID.value == groupID) {
                shoppingListID.value = newShoppingList.id;
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: const Text('現在の買い物リストを複製'),
            onTap: () async {
              final linkItems =
                  linkShoppingListItemsAsync.asData?.value ?? [];
              final allItems = [...shoppingListItems, ...linkItems];
              final newShoppingList = await shoppingListDuplicate(
                createUserID: shoppingList.createUserID,
                groupID: shoppingList.groupID,
                sourceShoppingList: shoppingList,
                shoppingListItems: allItems,
              );
              shoppingListID.value = newShoppingList.id;

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
