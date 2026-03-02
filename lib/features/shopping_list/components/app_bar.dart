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
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class ShoppingListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> sortByCategory;
  final List<GroupShoppingListItem> shoppingListItems;
  final void Function(String newID) onShoppingListIDChanged;
  const ShoppingListAppBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.showChecked,
    required this.sortByCategory,
    required this.shoppingListItems,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = this.shoppingList;
    final shoppingListDelete =
        ref.watch(shoppingListDeleteProvider(groupID: groupID));
    return AppBar(
      title: GestureDetector(
        onTap: () {
          analytics.logEvent(name: 'tap_open_list_picker', parameters: {
            'groupID': groupID,
            'shoppingListID': shoppingListID
          });
          _showPicker(context);
        },
        child: Row(
          children: [
            Text(shoppingList?.name ?? ''),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      actions: [
        if (shoppingList != null) ...[
          IconButton(
            onPressed: () {
              analytics.logEvent(name: 'tap_open_list_setting', parameters: {
                'groupID': groupID,
                'shoppingListID': shoppingListID
              });
              appShowModalBottomSheet(
                context: context,
                builder: (context) {
                  return ShoppingListSettingPage(
                    groupID: groupID,
                    shoppingListID: shoppingListID,
                    shoppingList: shoppingList,
                    onDelete: () {
                      shoppingListDelete(shoppingListID: shoppingListID);
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
              analytics.logEvent(
                  name: 'tap_open_add_list_sheet',
                  parameters: {'groupID': groupID});
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return _AddShoppingListBottomSheet(
                    groupID: groupID,
                    shoppingList: shoppingList,
                    shoppingListID: shoppingListID,
                    shoppingListItems: shoppingListItems,
                    onShoppingListIDChanged: onShoppingListIDChanged,
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
        IconButton(
          onPressed: () {
            analytics.logEvent(name: 'tap_open_filter', parameters: {
              'groupID': groupID,
              'shoppingListID': shoppingListID
            });
            appShowModalBottomSheet(
              context: context,
              builder: (context) {
                return ShoppingListItemFilterPage(
                  groupID: groupID,
                  shoppingListID: shoppingListID,
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

  void _showPicker(BuildContext context) {
    var selectedID = shoppingLists.first.id;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                PickerToolbar(
                  done: () {
                    analytics.logEvent(
                        name: 'tap_confirm_list_picker',
                        parameters: {
                          'groupID': groupID,
                          'selectedShoppingListID': selectedID
                        });
                    Navigator.pop(context);
                    onShoppingListIDChanged(selectedID);
                  },
                  cancel: () {
                    analytics.logEvent(
                        name: 'cancel_list_picker',
                        parameters: {'groupID': groupID});
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
                      children:
                          shoppingLists.map((sl) => Text(sl.name)).toList(),
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          selectedID = shoppingLists[value].id;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          },
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
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  final void Function(String newID) onShoppingListIDChanged;

  const _AddShoppingListBottomSheet({
    required this.groupID,
    required this.shoppingList,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.onShoppingListIDChanged,
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
                initialValue: selectedGroupID.value,
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
              analytics.logEvent(name: 'tap_create_new_list', parameters: {
                'groupID': groupID,
                'selectedGroupID': selectedGroupID.value
              });
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
                onShoppingListIDChanged(newShoppingList.id);
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: const Text('現在の買い物リストを複製'),
            onTap: () async {
              analytics.logEvent(name: 'tap_duplicate_list', parameters: {
                'groupID': groupID,
                'selectedGroupID': selectedGroupID.value,
                'sourceShoppingListID': shoppingList.id
              });
              final shoppingListDuplicate = ref.read(
                  shoppingListDuplicateProvider(
                      groupID: selectedGroupID.value));
              final newShoppingList = await shoppingListDuplicate(
                createUserID: shoppingList.createUserID,
                groupID: selectedGroupID.value,
                sourceShoppingList: shoppingList,
                shoppingListItems: shoppingListItems,
              );
              // 同じグループの場合のみshoppingListIDを切り替える
              if (selectedGroupID.value == groupID) {
                onShoppingListIDChanged(newShoppingList.id);
              }

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
