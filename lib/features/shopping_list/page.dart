import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/app_bar.dart';

import 'package:shoppinglist/features/shopping_list/components/group_switcher.dart';
import 'package:shoppinglist/features/shopping_list/components/notification_member_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/features/home_widget/home_widget_sync.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/notification_setting.dart';
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
    final isPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final shoppingLists = ref
        .watch(shoppingListsProvider(groupID: groupID, isPremium: isPremium));
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    useValueListenable(currentShoppingListID);

    return Retry(
      retry: () => ref.invalidate(
          shoppingListsProvider(groupID: groupID, isPremium: isPremium)),
      // SafeAreaでGroupSwitcherをステータスバー/ノッチ領域の下に配置する
      child: SafeArea(
        bottom: false,
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
                    final colorScheme = Theme.of(context).colorScheme;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.playlist_add,
                              size: 80,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '買い物リストがありません',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '新しい買い物リストを作成しましょう',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            FilledButton.icon(
                              onPressed: () async {
                                if (appUser == null) return;
                                analytics.logEvent(
                                    name: 'tap_create_first_shopping_list',
                                    parameters: {
                                      'groupID': groupID,
                                    });
                                try {
                                  await ref
                                      .read(shoppingListAddProvider(
                                          groupID: groupID))
                                      .call(
                                        createUserID: appUser.id,
                                        groupID: groupID,
                                        shoppingLocationID: null,
                                        duplicatedFromGroupShoppingListID: null,
                                      );
                                } on ShoppingListLimitExceededException catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('買い物リストの作成に失敗しました')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('買い物リストを作成'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final currentShoppingListIDValue =
                      currentShoppingListID.value;
                  final resolvedShoppingListID = (currentShoppingListIDValue !=
                              null &&
                          shoppingLists
                              .any((e) => e.id == currentShoppingListIDValue))
                      ? currentShoppingListIDValue
                      : shoppingLists.first.id;
                  return HomeWidgetSync(
                    groupID: groupID,
                    shoppingListID: resolvedShoppingListID,
                    builder: (context) {
                      return _Body(
                        key: ValueKey(resolvedShoppingListID),
                        groupID: groupID,
                        shoppingListID: resolvedShoppingListID,
                        onShoppingListIDChanged: (newID) {
                          currentShoppingListID.value = newID;
                        },
                      );
                    },
                  );
                },
                error: (e, st) => RetryPage(exception: e, stackTrace: st),
                loading: () => const Loading(),
              ),
            ),
          ],
        ),
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
    final isPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final shoppingLists = ref
            .watch(
                shoppingListsProvider(groupID: groupID, isPremium: isPremium))
            .valueOrNull ??
        [];
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

    // 手動通知用: メンバープロフィールとアイテム変更検知
    final currentUserID = ref.watch(currentUserIDProvider);
    final memberProfilesAsync =
        ref.watch(groupUserProfilesProvider(groupID: groupID));
    final memberProfiles = memberProfilesAsync.asData?.value ?? [];

    // アイテムストリームの変更回数を追跡し、初回ロード以降の変更でSnackBarを表示するためのカウンター
    final itemChangeCount = useState(0);
    final isInitialLoad = useState(true);
    // アイテム変更検知: allItemsAsyncが更新されるたびに変更回数をインクリメント（初回ロードは除外）
    // 依存配列: [allItemsAsync] — Firestoreストリームからアイテムデータが更新されるたびに実行
    useEffect(() {
      if (allItemsAsync is AsyncData) {
        if (isInitialLoad.value) {
          isInitialLoad.value = false;
        } else {
          itemChangeCount.value++;
        }
      }
      return null;
    }, [allItemsAsync]);

    // 手動通知SnackBar表示: アイテム変更が検知されたらメンバーアイコン付きSnackBarを表示
    // 依存配列: [itemChangeCount.value] — 変更回数が増えるたびに新しいSnackBarを表示
    useEffect(() {
      if (itemChangeCount.value > 0 && currentUserID != null) {
        // WidgetsBinding.instance.addPostFrameCallback でSnackBarをbuild完了後に表示
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            showNotificationSnackBar(
              context: context,
              groupID: groupID,
              shoppingListID: shoppingListID,
              shoppingListName: shoppingList?.name,
              currentUserID: currentUserID,
              memberProfiles: memberProfiles,
            );
          }
        });
      }
      return null;
    }, [itemChangeCount.value]);

    // 自動通知: 設定ONかつアイテム変更があった場合、バックグラウンド移行時にグループ全メンバーへ通知を自動送信
    // 依存配列: [autoNotify, currentUserID, memberProfiles] — 設定変更・ユーザー変更・メンバー変更時にリスナーを再登録
    final autoNotify = ref.watch(autoNotifyShoppingListUpdateProvider);
    useEffect(() {
      if (!autoNotify || currentUserID == null) return null;

      final listener = AppLifecycleListener(
        onStateChange: (state) {
          if (state == AppLifecycleState.paused && itemChangeCount.value > 0) {
            final otherMemberIDs = memberProfiles
                .where((p) => p.userID != currentUserID)
                .map((p) => p.userID)
                .toList();
            if (otherMemberIDs.isEmpty) return;

            functions.sendShoppingListUpdateNotification(
              groupID: groupID,
              shoppingListID: shoppingListID,
              shoppingListName: shoppingList?.name,
              targetUserIDs: otherMemberIDs,
            );
            itemChangeCount.value = 0;
            debugPrint('[AutoNotify] バックグラウンド移行時に自動通知送信');
          }
        },
      );
      return listener.dispose;
    }, [autoNotify, currentUserID, memberProfiles]);

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
                  userID: ref.read(currentUserIDProvider)!,
                  message: '',
                  order: (shoppingListItemsAsync.asData?.value ?? []).nextOrder,
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
                            sortByCategory: sortByCategory.value,
                            shoppingLocationID:
                                shoppingList?.shoppingLocationID)),
                    if (!isPremium)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '無料プランでは過去30日以内のリストのみ表示されます',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
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
