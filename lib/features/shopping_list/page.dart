import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/home_widget/home_widget_sync.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/ai_processing_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/all_done_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/list_error_card.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/retention_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/filter_chips_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/group_chips_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/list_top_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/notification_member_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_block.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_body_content.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/notification_setting.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

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
    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final shoppingLists = ref.watch(
        shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium));
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    useValueListenable(currentShoppingListID);

    return Retry(
      retry: () => ref.invalidate(shoppingListsProvider(
          groupID: groupID, isPremium: firestoreIsPremium)),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (userGroupsAsync.asData?.value != null)
              GroupChipsBar(
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
                    return _NoListYet(
                      groupID: groupID,
                      appUserID: appUser?.id,
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

/// 買い物リストが 0 件のときの「最初の 1 件を作る」プロンプト。
class _NoListYet extends ConsumerWidget {
  final String groupID;
  final String? appUserID;
  const _NoListYet({required this.groupID, required this.appUserID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.playlist_add,
              size: 80,
              color: tokens.neutral.ink4,
            ),
            const SizedBox(height: 24),
            Text(
              '買い物リストがありません',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '新しい買い物リストを作成しましょう',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: tokens.neutral.ink2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                if (appUserID == null) return;
                analytics.logEvent(
                    name: 'tap_create_first_shopping_list',
                    parameters: {'groupID': groupID});
                try {
                  await ref
                      .read(shoppingListAddProvider(groupID: groupID))
                      .call(
                        createUserID: appUserID!,
                        groupID: groupID,
                        shoppingLocationID: null,
                        duplicatedFromGroupShoppingListID: null,
                      );
                } on ShoppingListLimitExceededException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        action: SnackBarAction(
                          label: 'アップグレード',
                          onPressed: () => showPaywall(context: context),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
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
    final tokens = context.tokens;
    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final shoppingLists = ref
            .watch(shoppingListsProvider(
                groupID: groupID, isPremium: firestoreIsPremium))
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
    final itemMetrics = ShoppingListItemMetrics.fromItems(allItems);
    final checkedCount = itemMetrics.checkedCount;
    final totalCount = itemMetrics.totalCount;
    final shoppingList =
        shoppingLists.firstWhereOrNull((sl) => sl.id == shoppingListID);

    final currentUserID = ref.watch(currentUserIDProvider);
    final memberProfilesAsync =
        ref.watch(groupUserProfilesProvider(groupID: groupID));
    final memberProfiles = memberProfilesAsync.asData?.value ?? [];

    final itemChangeCount = useState(0);
    final isInitialLoad = useState(true);
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

    useEffect(() {
      if (itemChangeCount.value > 0 && currentUserID != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            showNotificationToast(
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
          }
        },
      );
      return listener.dispose;
    }, [autoNotify, currentUserID, memberProfiles]);

    final aiProcessingType = ref.watch(aIProcessingProvider);

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: shoppingListID,
            showChecked: showChecked.value));
      },
      child: Scaffold(
        backgroundColor: tokens.neutral.surface,
        floatingActionButton: ExpandableFab(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingListItems: shoppingListItemsAsync.asData?.value ?? const [],
        ),
        body: Column(
          children: [
            // NavBar (paper bg)
            ListTopBar(
              groupID: groupID,
              shoppingListID: shoppingListID,
              shoppingLists: shoppingLists,
              shoppingList: shoppingList,
              onShoppingListIDChanged: onShoppingListIDChanged,
            ),
            // 白 (card) コンテンツ部 — ハイブリッドサーフェスの内側
            Expanded(
              child: Container(
                color: tokens.neutral.card,
                child: Column(
                  children: [
                    FilterChipsBar(
                      groupID: groupID,
                      shoppingListID: shoppingListID,
                      showChecked: showChecked,
                      sortByCategory: sortByCategory,
                    ),
                    if (totalCount > 0)
                      ProgressBlock(
                        checkedCount: checkedCount,
                        totalCount: totalCount,
                      ),
                    if (totalCount > 0 && checkedCount == totalCount)
                      const AllDoneBanner(),
                    if (aiProcessingType != null)
                      AIProcessingBanner(type: aiProcessingType),
                    Expanded(
                      child: shoppingListItemsAsync.when(
                        data: (shoppingListItems) => ShoppingListBodyContent(
                          groupID: groupID,
                          shoppingListID: shoppingListID,
                          shoppingLists: shoppingLists,
                          shoppingList: shoppingList,
                          shoppingListItems: shoppingListItems,
                          showChecked: showChecked.value,
                          sortByCategory: sortByCategory.value,
                          onShoppingListIDChanged: onShoppingListIDChanged,
                        ),
                        error: (e, st) => ListErrorCard(
                          exception: e,
                          onRetry: () => Retry.of(context).retry(),
                        ),
                        loading: () => const Loading(),
                      ),
                    ),
                    if (!firestoreIsPremium && totalCount > 50)
                      const RetentionBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
