import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/components/admob/banner.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/shopping_list/components/app_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/copy_multiline_text_button.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/image_picker_button.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/shopping_list_item_add_button.dart';
import 'package:shoppinglist/features/shopping_list/components/group_switcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/style/color.dart';

class ShoppingListPage extends HookConsumerWidget {
  final String groupID;
  final void Function(String groupID)? onGroupChanged;
  const ShoppingListPage({
    super.key,
    required this.groupID,
    this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider(groupID: groupID));
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;

    // 切り替え先のグループに買い物リストが0件の場合、デフォルトリストを自動作成
    useEffect(() {
      void f() async {
        if (appUser != null &&
            shoppingLists is AsyncData<List<GroupShoppingList>> &&
            shoppingLists.value.isEmpty == true) {
          final shoppingListAdd =
              ref.read(shoppingListAddProvider(groupID: groupID));
          await shoppingListAdd(
            createUserID: appUser.id,
            groupID: groupID,
            shoppingLocationID: null,
            duplicatedFromGroupShoppingListID: null,
          );
        }
      }

      f();
      return null;
    }, [shoppingLists]);

    return Retry(
      retry: () => ref.invalidate(shoppingListsProvider(groupID: groupID)),
      child: Column(
        children: [
          if (userGroupsAsync.asData?.value != null)
            GroupSwitcher(
              groups: userGroupsAsync.asData!.value,
              currentGroupID: groupID,
              onGroupChanged: (newGroupID) {
                onGroupChanged?.call(newGroupID);
              },
            ),
          Expanded(
            child: shoppingLists.when(
              data: (shoppingLists) {
                if (shoppingLists.isEmpty) {
                  return const Loading();
                }
                return _Body(groupID: groupID);
              },
              error: (e, st) => RetryPage(exception: e, stackTrace: st),
              loading: () => const Loading(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends HookConsumerWidget {
  final String groupID;

  const _Body({required this.groupID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists =
        ref.watch(shoppingListsProvider(groupID: groupID)).valueOrNull ?? [];
    final shoppingListID = useState(shoppingLists.first.id);
    final retry = Retry.of(context).retry;
    final showChecked = useState(true);
    final sortByCategory = useState(true);
    final shoppingListItemsAsync = ref.watch(textShoppingListItemsProvider(
      groupID: groupID,
      shoppingListID: shoppingListID.value,
      showChecked: showChecked.value,
    ));
    final shoppingList =
        shoppingLists.firstWhereOrNull((sl) => sl.id == shoppingListID.value);
    final ttlExpiresDateTime = shoppingList?.ttlExpiresDateTime;

    // 削除した時にshoppingListIDを入れ替える
    useEffect(() {
      if (!shoppingLists.map((e) => e.id).contains(shoppingListID.value)) {
        final firstID = shoppingLists.firstOrNull?.id;
        if (firstID != null) {
          shoppingListID.value = firstID;
        }
      }
      return null;
    }, [shoppingLists.length]);

    // shoppingListIDが変わったらshoppingListsProviderから更新してWidgetツリーを更新
    useEffect(() {
      ref.invalidate(shoppingListsProvider(groupID: groupID));
      return null;
    }, [shoppingListID.value]);

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: shoppingListID.value,
            showChecked: showChecked.value));
      },
      child: Scaffold(
        appBar: ShoppingListAppBar(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingLists: shoppingLists,
          shoppingList: shoppingList,
          showChecked: showChecked,
          sortByCategory: sortByCategory,
          shoppingListItems: shoppingListItemsAsync.asData?.value ?? [],
        ),
        body: SafeArea(
          child: shoppingListItemsAsync.when(
            data: (shoppingListItems) {
              if (showChecked.value && shoppingListItems.isEmpty) {
                return EmptyTextShoppingListItems(
                    groupID: groupID,
                    shoppingListID: shoppingListID.value,
                    shoppingListItems: shoppingListItems);
              } else {
                return Column(
                  children: [
                    if (ttlExpiresDateTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '※ この買い物リストは${DateFormat.MEd().format(ttlExpiresDateTime)}まで保存されてます',
                        style: const TextStyle(
                          color: TextColor.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (shoppingList?.duplicatedFromGroupShoppingListID !=
                        null) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          final sourceID =
                              shoppingList!.duplicatedFromGroupShoppingListID!;
                          analytics.logEvent(
                              name: 'tap_navigate_source_list',
                              parameters: {
                                'groupID': groupID,
                                'shoppingListID': shoppingListID.value,
                                'sourceShoppingListID': sourceID
                              });
                          if (shoppingLists.any((sl) => sl.id == sourceID)) {
                            shoppingListID.value = sourceID;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('複製元の買い物リストは削除されています')),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.content_copy,
                                size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              '${shoppingLists.firstWhereOrNull((sl) => sl.id == shoppingList!.duplicatedFromGroupShoppingListID)?.name ?? "削除済みリスト"}から複製',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Expanded(
                        child: ShoppingListItems(
                            groupID: groupID,
                            shoppingListID: shoppingListID.value,
                            sortByCategory: sortByCategory.value)),
                    const AdMobBanner(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: ShoppingListItemAddButton(
                                    groupID: groupID,
                                    shoppingListID: shoppingListID.value,
                                    shoppingListItems: shoppingListItems),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ImagePickerButton(
                                    groupID: groupID,
                                    shoppingListID: shoppingListID.value,
                                    shoppingListItems: shoppingListItems),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CopyMultilineTextButton(
                                    groupID: groupID,
                                    shoppingListID: shoppingListID.value,
                                    shoppingListItems: shoppingListItems),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
            error: (e, st) => RetryPage(exception: e, stackTrace: st),
            loading: () => const Loading(),
          ),
        ),
      ),
    );
  }
}
