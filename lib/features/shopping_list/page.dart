import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/app_bar.dart';

import 'package:shoppinglist/features/shopping_list/components/group_switcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';


class ShoppingListPage extends HookConsumerWidget {
  final String groupID;
  final ValueNotifier<String?> currentShoppingListID;
  final void Function(String groupID)? onGroupChanged;
  const ShoppingListPage({
    super.key,
    required this.groupID,
    required this.currentShoppingListID,
    this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider(groupID: groupID));
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    useValueListenable(currentShoppingListID);

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
                final currentShoppingListIDValue = currentShoppingListID.value;
                final resolvedShoppingListID =
                    (currentShoppingListIDValue != null &&
                            shoppingLists
                                .any((e) => e.id == currentShoppingListIDValue))
                        ? currentShoppingListIDValue
                        : shoppingLists.first.id;
                return _Body(
                  key: ValueKey(resolvedShoppingListID),
                  groupID: groupID,
                  shoppingListID: resolvedShoppingListID,
                  onShoppingListIDChanged: (newID) {
                    currentShoppingListID.value = newID;
                  },
                );
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
  final String shoppingListID;
  final void Function(String newID) onShoppingListIDChanged;

  const _Body({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists =
        ref.watch(shoppingListsProvider(groupID: groupID)).valueOrNull ?? [];
    final retry = Retry.of(context).retry;
    final showChecked = useState(true);
    final sortByCategory = useState(true);
    final shoppingListItemsAsync = ref.watch(textShoppingListItemsProvider(
      groupID: groupID,
      shoppingListID: shoppingListID,
      showChecked: showChecked.value,
    ));
    final allItemsAsync = ref.watch(textShoppingListItemsProvider(
      groupID: groupID,
      shoppingListID: shoppingListID,
      showChecked: true,
    ));
    final allItems = allItemsAsync.valueOrNull ?? [];
    final checkedCount = allItems
        .where((i) => i.status == GroupShoppingListItemStatus.checked)
        .length;
    final totalCount = allItems.length;
    final shoppingList =
        shoppingLists.firstWhereOrNull((sl) => sl.id == shoppingListID);
    final ttlExpiresDateTime = shoppingList?.ttlExpiresDateTime;

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: shoppingListID,
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
          onShoppingListIDChanged: onShoppingListIDChanged,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            analytics.logEvent(name: 'tap_add_item_fab', parameters: {
              'groupID': groupID,
              'shoppingListID': shoppingListID,
            });
            ref.read(addShoppingListItemProvider(groupID: groupID)).call(
                  shoppingListID: shoppingListID,
                  message: '',
                  order: (shoppingListItemsAsync.asData?.value ?? []).nextOrder,
                  groupShoppingListItemCategoryID: null,
                  description: null,
                  color: null,
                );
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: shoppingListItemsAsync.when(
            data: (shoppingListItems) {
              final isEmpty = shoppingListItems.isEmpty;
              debugPrint(
                  '[ShoppingListPage] data: アイテム数=${shoppingListItems.length}, showChecked=${showChecked.value}, isEmpty=$isEmpty, 空表示=${showChecked.value && isEmpty}');
              if (showChecked.value && isEmpty) {
                return EmptyTextShoppingListItems(
                    groupID: groupID,
                    shoppingListID: shoppingListID,
                    shoppingListItems: shoppingListItems);
              } else {
                return Column(
                  children: [
                    if (ttlExpiresDateTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '※ この買い物リストは${DateFormat.MEd().format(ttlExpiresDateTime)}まで保存されてます',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                'shoppingListID': shoppingListID,
                                'sourceShoppingListID': sourceID
                              });
                          if (shoppingLists.any((sl) => sl.id == sourceID)) {
                            onShoppingListIDChanged(sourceID);
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
                    if (totalCount > 0)
                      _ProgressSection(
                        checkedCount: checkedCount,
                        totalCount: totalCount,
                      ),
                    Expanded(
                        child: ShoppingListItems(
                            groupID: groupID,
                            shoppingListID: shoppingListID,
                            sortByCategory: sortByCategory.value)),
                    _AddItemPlaceholder(
                      onTap: () {
                        analytics.logEvent(
                            name: 'tap_add_item_placeholder',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID,
                            });
                        ref
                            .read(addShoppingListItemProvider(groupID: groupID))
                            .call(
                              shoppingListID: shoppingListID,
                              message: '',
                              order: allItems.nextOrder,
                              groupShoppingListItemCategoryID: null,
                              description: null,
                              color: null,
                            );
                      },
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

class _ProgressSection extends StatelessWidget {
  final int checkedCount;
  final int totalCount;

  const _ProgressSection({
    required this.checkedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;
    final isComplete = checkedCount == totalCount && totalCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isComplete
                    ? '$checkedCount/$totalCount 完了!'
                    : '$checkedCount/$totalCount 完了',
                style: TextStyle(
                  fontSize: 12,
                  color: isComplete
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemPlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const _AddItemPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline,
                size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(
              'アイテムを追加',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
