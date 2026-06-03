import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/ai_processing_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/list_error_card.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/retention_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/filter_chips_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/group_chips_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/list_top_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/notification_member_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_pill.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_body_content.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/current_group_id.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// 買い物リストのメイン画面。単一の Scaffold を持ち、FAB・トップバー・リスト本体を内包する。
///
/// 表示中のグループ/リストは currentGroupIDProvider / currentShoppingListIDProvider から読む。
/// HomePage(薄いラッパ)経由でも、Previews から直接生成されても、provider を介して動作する。
class ShoppingListPage extends HookConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    // groupID は CurrentGroupResolver(実機) / preview override により、この画面が生成される
    // 時点で常に非null。Notifier も update(String) で非nullしか入れないため生存中も非nullを保つ。
    // よって以下の早期 return は防御で、hooks 呼び出し前でも数の不整合は起きない。
    final groupID = ref.watch(currentGroupIDProvider);
    if (groupID == null) {
      return LaunchLoading.shared();
    }

    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final appUser = ref.watch(appUserProvider).asData?.value;
    final currentUserID = ref.watch(currentUserIDProvider);
    final aiProcessingType = ref.watch(aIProcessingProvider);

    final shoppingListsAsync = ref.watch(
        shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium));
    final shoppingLists = shoppingListsAsync.valueOrNull ?? [];
    final resolvedShoppingListID = resolveShoppingListID(
      selected: ref.watch(currentShoppingListIDProvider),
      shoppingLists: shoppingLists,
    );
    final shoppingList =
        shoppingLists.firstWhereOrNull((sl) => sl.id == resolvedShoppingListID);

    final showChecked = useState(true);
    final sortByCategory = useState(true);

    // 表示用: フィルタ(チェック済み表示の ON/OFF)を反映した一覧。FAB とリスト本体に渡す。
    final shoppingListItemsAsync = resolvedShoppingListID == null
        ? null
        : ref.watch(textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: resolvedShoppingListID,
            showChecked: showChecked.value,
          ));
    // 集計用: フィルタに関係なく常に全件。進捗ピル・変更検知・通知トーストはフィルタ表示の
    // ON/OFF に左右されず全件基準で判定する必要があるため、showChecked: true で別途 watch する。
    final textShoppingListItemsAsync = resolvedShoppingListID == null
        ? null
        : ref.watch(textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: resolvedShoppingListID,
            showChecked: true,
          ));
    final textShoppingListItems = textShoppingListItemsAsync?.valueOrNull ?? [];
    final itemMetrics = shoppingListItemMetrics(textShoppingListItems);
    final checkedCount = itemMetrics.checkedCount;
    final totalCount = itemMetrics.totalCount;

    final memberProfiles =
        ref.watch(groupUserProfilesProvider(groupID: groupID)).asData?.value ??
            [];

    final autoNotify = ref.watch(boolSharedPreferencesProvider(
        key: BoolKey.autoNotifyShoppingListUpdate));

    final itemChangeCount = useState(0);
    final isInitialLoad = useState(true);
    // 全件の取得結果が更新されるたびに「初回ロードか / 以降の変更か」を判定する。
    // 初回(AsyncData 初到達)は通知対象外なのでフラグを倒すだけ、2回目以降の変化で
    // itemChangeCount を増やし、通知トースト / 自動通知のトリガーにする。
    // 依存配列を textShoppingListItemsAsync にするのは、この Async 値の更新そのものを
    // アイテム変更イベントとして扱うため(表示フィルタに依存しない全件側を見る)。
    useEffect(() {
      if (textShoppingListItemsAsync is AsyncData) {
        if (isInitialLoad.value) {
          isInitialLoad.value = false;
        } else {
          itemChangeCount.value++;
        }
      }
      return null;
    }, [textShoppingListItemsAsync]);

    // アイテムの変更(2回目以降)を検知したら、家族へ通知を促すトーストを表示する。
    // モーダル表示中でも最前面に出すためグローバルトースト経由で出す。ソログループ(自分のみ)では
    // 空のトースト枠だけが残るため、他メンバーが居る時だけ表示する。
    // 依存配列は itemChangeCount.value のみ — 変更回数の増加イベントだけをトリガーにする。
    useEffect(() {
      if (itemChangeCount.value > 0 && currentUserID != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          if (resolvedShoppingListID == null) {
            return;
          }
          if (!memberProfiles.any((p) => p.userID != currentUserID)) {
            return;
          }
          showGlobalToastWidget(
            NotificationMemberBar(
              groupID: groupID,
              shoppingListID: resolvedShoppingListID,
              shoppingListName: shoppingList?.name,
              currentUserID: currentUserID,
              memberProfiles: memberProfiles,
            ),
          );
        });
      }
      return null;
    }, [itemChangeCount.value]);

    // 自動通知: アプリがバックグラウンドへ移る(paused)時に未通知の変更があれば家族へ送る。
    // autoNotify 設定 OFF / 未ログイン / リスト未解決時は監視しない。依存配列の値が変わったら
    // 古い AppLifecycleListener を破棄して張り直す。
    useEffect(() {
      if (!autoNotify ||
          currentUserID == null ||
          resolvedShoppingListID == null) {
        return null;
      }
      final listener = AppLifecycleListener(
        onStateChange: (state) {
          if (state == AppLifecycleState.paused && itemChangeCount.value > 0) {
            final otherMemberIDs = memberProfiles
                .where((p) => p.userID != currentUserID)
                .map((p) => p.userID)
                .toList();
            if (otherMemberIDs.isEmpty) {
              return;
            }

            functions.sendShoppingListUpdateNotification(
              groupID: groupID,
              shoppingListID: resolvedShoppingListID,
              shoppingListName: shoppingList?.name,
              targetUserIDs: otherMemberIDs,
            );
            itemChangeCount.value = 0;
          }
        },
      );
      return listener.dispose;
    }, [autoNotify, currentUserID, memberProfiles, resolvedShoppingListID]);

    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      floatingActionButton: resolvedShoppingListID == null
          ? null
          : ExpandableFab(
              groupID: groupID,
              shoppingListID: resolvedShoppingListID,
              shoppingListItems: shoppingListItemsAsync?.asData?.value ?? const [],
            ),
      body: Retry(
        retry: () {
          ref.invalidate(shoppingListsProvider(
              groupID: groupID, isPremium: firestoreIsPremium));
          if (resolvedShoppingListID != null) {
            ref.invalidate(textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: resolvedShoppingListID,
                showChecked: showChecked.value));
          }
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (userGroupsAsync.asData?.value != null)
                GroupChipsBar(
                  groups: userGroupsAsync.asData!.value,
                  currentGroupID: groupID,
                  onGroupChanged: (newGroupID) {
                    ref.read(currentGroupIDProvider.notifier).update(newGroupID);
                    // 切替先グループの先頭リストへフォールバックさせるため選択をクリアする。
                    ref.read(currentShoppingListIDProvider.notifier).update(null);
                    ref.read(defaultGroupUpdateProvider).call(groupID: newGroupID);
                  },
                ),
              Expanded(
                child: shoppingListsAsync.when(
                  data: (lists) {
                    if (lists.isEmpty) {
                      return _NoListYet(groupID: groupID, appUserID: appUser?.id);
                    }
                    // lists が非空なら resolveShoppingListID は必ず先頭以上を返すため非null。
                    final listID = resolvedShoppingListID!;
                    // NavBar(surface)の帯 + 白(card)コンテンツ部のハイブリッドサーフェス。
                    return Container(
                      color: tokens.neutral.surface,
                      child: Column(
                        children: [
                          ListTopBar(
                            groupID: groupID,
                            shoppingListID: listID,
                            shoppingLists: lists,
                            shoppingList: shoppingList,
                            onShoppingListIDChanged: (newID) => ref
                                .read(currentShoppingListIDProvider.notifier)
                                .update(newID),
                          ),
                          Expanded(
                            child: Container(
                              color: tokens.neutral.card,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      FilterChipsBar(
                                        groupID: groupID,
                                        shoppingListID: listID,
                                        showChecked: showChecked,
                                        sortByCategory: sortByCategory,
                                      ),
                                      if (aiProcessingType != null)
                                        AIProcessingBanner(type: aiProcessingType),
                                      Expanded(
                                        // listID 非null ⇒ shoppingListItemsAsync 非null。
                                        child: shoppingListItemsAsync!.when(
                                          data: (shoppingListItems) =>
                                              ShoppingListBodyContent(
                                            groupID: groupID,
                                            shoppingListID: listID,
                                            shoppingLists: lists,
                                            shoppingList: shoppingList,
                                            shoppingListItems: shoppingListItems,
                                            showChecked: showChecked.value,
                                            sortByCategory: sortByCategory.value,
                                            onShoppingListIDChanged: (newID) => ref
                                                .read(currentShoppingListIDProvider
                                                    .notifier)
                                                .update(newID),
                                          ),
                                          error: (e, st) => ListErrorCard(
                                            exception: e,
                                            onRetry: () =>
                                                Retry.of(context).retry(),
                                          ),
                                          loading: () => const Loading(),
                                        ),
                                      ),
                                      if (!firestoreIsPremium && totalCount > 50)
                                        const RetentionBanner(),
                                    ],
                                  ),
                                  // チェック進捗を左下に浮かせる小さなピル(FAB は右下なので対称)。
                                  // 外側 SafeArea が bottom:false のため、ホームインジケータ分を加味する。
                                  if (totalCount > 0)
                                    Positioned(
                                      left: AppTokens.s16,
                                      bottom: AppTokens.s16 +
                                          MediaQuery.of(context).padding.bottom,
                                      child: ProgressPill(
                                        checkedCount: checkedCount,
                                        totalCount: totalCount,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  error: (e, st) => RetryPage(exception: e, stackTrace: st),
                  loading: () => const Loading(),
                ),
              ),
            ],
          ),
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
                if (appUserID == null) {
                  return;
                }
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
