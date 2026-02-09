import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toolbar/picker.dart';
import 'package:shoppinglist/entity/shopping_list.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list_item_filter/page.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class ShoppingListAppBar extends HookConsumerWidget
    implements PreferredSizeWidget {
  final ValueNotifier<String> shoppingListID;
  final List<ShoppingList> shoppingLists;
  final ShoppingList? shoppingList;
  final ValueNotifier<bool> showChecked;
  final List<ShoppingListItem> shoppingListItems;
  const ShoppingListAppBar({
    super.key,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.showChecked,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = this.shoppingList;
    final shoppingListAdd = ref.watch(shoppingListAddProvider);
    final shoppingListDelete = ref.watch(shoppingListDeleteProvider);
    final shoppingListDuplicate = ref.watch(shoppingListDuplicateProvider);

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
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('買い物リストを追加'),
                          onTap: () async {
                            final newShoppingList = await shoppingListAdd(
                                createUserID: shoppingList.createUserID,
                                groupID: shoppingList.groupID);
                            shoppingListID.value = newShoppingList.id;

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('現在の買い物リストを複製'),
                          onTap: () async {
                            final newShoppingList = await shoppingListDuplicate(
                                createUserID: shoppingList.createUserID,
                                groupID: shoppingList.groupID,
                                shoppingListItems: shoppingListItems);
                            shoppingListID.value = newShoppingList.id;

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
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
                  shoppingListID: shoppingListID.value,
                  showChecked: showChecked,
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
