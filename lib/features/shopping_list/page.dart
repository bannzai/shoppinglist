import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/ai_processing_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/list_error_card.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/retention_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/group_chips_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/list_top_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_pill.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_body_content.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/current_group_id.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_fab_menu.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 買い物リストのメイン画面。買い物リスト一覧の状態(Loading/Error/空/データ)をハンドリングし、
/// 共通レイアウト(_ShoppingListShell)と、有効なリストがある時の本体(_ActiveShoppingList)へ振り分ける。
///
/// 表示中のグループ/リストは currentGroupIDProvider / currentShoppingListIDProvider から読む。
/// HomePage(薄いラッパ)経由でも、Previews から直接生成されても、provider を介して動作する。
/// item 系 provider の購読は resolvedShoppingListID が確定する _ActiveShoppingList 内でのみ行い、
/// 条件付き ref.watch を持ち込まない。
class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // groupID は CurrentGroupResolver(実機) / preview override により、この画面が生成される
    // 時点で常に非null。Notifier も update(String) で非nullしか入れないため生存中も非nullを保つ。
    // よって以下の早期 return は防御。
    final groupID = ref.watch(currentGroupIDProvider);
    if (groupID == null) {
      return LaunchLoading.shared();
    }

    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final groups = ref.watch(userGroupsProvider).asData?.value;
    final appUser = ref.watch(appUserProvider).asData?.value;
    final shoppingListsAsync = ref.watch(
      shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium),
    );
    final resolvedShoppingListID = resolveShoppingListID(
      selected: ref.watch(currentShoppingListIDProvider),
      shoppingLists: shoppingListsAsync.valueOrNull ?? [],
    );

    void invalidateLists() => ref.invalidate(
      shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium),
    );

    return shoppingListsAsync.when(
      data: (lists) {
        if (lists.isEmpty || resolvedShoppingListID == null) {
          return _ShoppingListScaffold(
            groupID: groupID,
            groups: groups,
            onRetry: invalidateLists,
            child: _NoListYet(groupID: groupID, appUserID: appUser?.id),
          );
        }
        return _ActiveShoppingList(
          key: ValueKey(resolvedShoppingListID),
          groupID: groupID,
          shoppingListID: resolvedShoppingListID,
          shoppingLists: lists,
          groups: groups,
          firestoreIsPremium: firestoreIsPremium,
        );
      },
      error:
          (e, st) => _ShoppingListScaffold(
            groupID: groupID,
            groups: groups,
            onRetry: invalidateLists,
            child: RetryPage(exception: e, stackTrace: st),
          ),
      loading:
          () => _ShoppingListScaffold(
            groupID: groupID,
            groups: groups,
            onRetry: invalidateLists,
            child: const Loading(),
          ),
    );
  }
}

/// 単一 Scaffold の共通レイアウト。paper 背景・GroupChipsBar・Retry を提供し、Expanded に child を置く。
/// 一覧の各状態(空/エラー/ロード/有効)で共有し、Scaffold が二重にならないようにする。
class _ShoppingListScaffold extends StatelessWidget {
  final String groupID;
  final List<Group>? groups;
  final VoidCallback onRetry;
  final Widget? floatingActionButton;
  final Widget child;

  const _ShoppingListScaffold({
    required this.groupID,
    required this.groups,
    required this.onRetry,
    this.floatingActionButton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.neutral.paper,
      floatingActionButton: floatingActionButton,
      body: Retry(
        retry: onRetry,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (groups != null)
                _GroupChips(groups: groups!, currentGroupID: groupID),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// グループ切替チップ。切替時に選択 provider を更新し defaultGroupID を永続化する。
/// 切替先グループの先頭リストへフォールバックさせるため currentShoppingListID は null に戻す。
class _GroupChips extends ConsumerWidget {
  final List<Group> groups;
  final String currentGroupID;

  const _GroupChips({required this.groups, required this.currentGroupID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GroupChipsBar(
      groups: groups,
      currentGroupID: currentGroupID,
      onGroupChanged: (newGroupID) {
        ref.read(currentGroupIDProvider.notifier).update(newGroupID);
        ref.read(currentShoppingListIDProvider.notifier).update(null);
        ref.read(defaultGroupUpdateProvider).call(groupID: newGroupID);
      },
    );
  }
}

/// 有効な買い物リストが確定している(resolvedShoppingListID 非null)時のみマウントされる本体。
/// item 系 provider の購読をここで無条件に行うため、ShoppingListPage 側に条件付き ref.watch を
/// 持ち込まずに済む。
class _ActiveShoppingList extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final List<Group>? groups;
  final bool firestoreIsPremium;

  const _ActiveShoppingList({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.groups,
    required this.firestoreIsPremium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final shoppingList = shoppingLists.firstWhereOrNull(
      (sl) => sl.id == shoppingListID,
    );

    // 表示リスト切替に使う notifier を build 時に束ねる。
    // この notifier を子(ListTopBar / ListPickerSheet)へ渡す onShoppingListIDChanged
    // クロージャに閉じ込める。リスト作成が Stream へ反映されると、この
    // _ActiveShoppingList は先頭フォールバックで新リストへ ValueKey 差し替え再構築され
    // 破棄される。クロージャ内で `ref` を直接使うと、破棄後にシート側から呼ばれた時に
    // "Cannot use ref after the widget was disposed" になる。notifier 自体は provider
    // (親 ShoppingListPage が watch 継続)が保持し続けるため、破棄後でも安全に使える。
    final currentShoppingListIDNotifier = ref.watch(
      currentShoppingListIDProvider.notifier,
    );

    // チェック済み含む全件。FAB・リスト本体・進捗ピルがこの一覧を基準にする。
    final shoppingListItemsAsync = ref.watch(
      textShoppingListItemsProvider(
        groupID: groupID,
        shoppingListID: shoppingListID,
      ),
    );
    final itemMetrics = shoppingListItemMetrics(
      shoppingListItemsAsync.valueOrNull ?? [],
    );
    final checkedCount = itemMetrics.checkedCount;
    final totalCount = itemMetrics.totalCount;

    final aiProcessingType = ref.watch(aIProcessingProvider);

    // グループへの更新通知は上部バー(ListTopBar)の手動ボタン(NotifyGroupButton)で行う。
    // 自動検知による通知バーは廃止した(Issue #449)。

    // ソフトキーボード表示中は、下部の浮遊要素(ダブル FAB・進捗ピル)を隠す。入力行は
    // フォーカス時に keepVisibleAtEnd でキーボード直上へスクロールされる
    // (text_shopping_list_item.dart, Issue #429)ため、同じくキーボード直上に浮く FAB・
    // 進捗ピルと重なってしまう。キーボード表示中は入力行での連続追加が主操作で FAB は不要な
    // ので、表示中だけ隠して重なりを解消する。この build は Scaffold の外側にあるため
    // viewInsets はキーボード実高を保持する(Scaffold body 内では viewInsets が 0 に潰れる)。
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return _ShoppingListScaffold(
      groupID: groupID,
      groups: groups,
      onRetry: () {
        ref.invalidate(
          shoppingListsProvider(
            groupID: groupID,
            isPremium: firestoreIsPremium,
          ),
        );
        ref.invalidate(
          textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: shoppingListID,
          ),
        );
      },
      // ダブル FAB: 上がリスト作成（CreateListFab）、下がアイテム入力（ExpandableFab）。
      // CreateListFab(48px) は ExpandableFab(56px) と中心が揃うよう右に 4px 寄せる。
      // キーボード表示中は入力行と重なるため隠す(Scaffold の FAB スケールアニメで消える)。
      floatingActionButton:
          isKeyboardVisible
              ? null
              : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: CreateListFab(
                      groupID: groupID,
                      appUser: ref.watch(appUserProvider).asData?.value,
                      shoppingList: shoppingList,
                      shoppingListItems:
                          shoppingListItemsAsync.asData?.value ?? const [],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ExpandableFab(
                    groupID: groupID,
                    shoppingListID: shoppingListID,
                    shoppingListItems:
                        shoppingListItemsAsync.asData?.value ?? const [],
                  ),
                ],
              ),
      // NavBar(surface)の帯 + 白(card)コンテンツ部のハイブリッドサーフェス。
      // リスト本体のスクロール開始時に FAB の展開メニューを閉じる。onNotification は
      // false を返して通知を上位へ伝播させ続ける（スクロール自体は通常どおり動く）。
      child: NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          ref.read(shoppingListFabMenuProvider.notifier).close();
          return false;
        },
        child: Container(
          color: tokens.neutral.surface,
          child: Column(
            children: [
              ListTopBar(
                groupID: groupID,
                shoppingListID: shoppingListID,
                shoppingLists: shoppingLists,
                shoppingList: shoppingList,
                onShoppingListIDChanged:
                    (newID) => currentShoppingListIDNotifier.update(newID),
              ),
              Expanded(
                child: Container(
                  color: tokens.neutral.card,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          if (aiProcessingType != null)
                            AIProcessingBanner(type: aiProcessingType),
                          Expanded(
                            child: shoppingListItemsAsync.when(
                              data:
                                  (shoppingListItems) =>
                                      ShoppingListBodyContent(
                                        groupID: groupID,
                                        shoppingListID: shoppingListID,
                                        shoppingLists: shoppingLists,
                                        shoppingList: shoppingList,
                                        shoppingListItems: shoppingListItems,
                                        onShoppingListIDChanged:
                                            (newID) =>
                                                currentShoppingListIDNotifier
                                                    .update(newID),
                                      ),
                              error:
                                  (e, st) => ListErrorCard(
                                    exception: e,
                                    stackTrace: st,
                                    onRetry: () => Retry.of(context).retry(),
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
                      // キーボード表示中は入力行と重なるため隠す(FAB と同じ扱い)。
                      if (totalCount > 0 && !isKeyboardVisible)
                        Positioned(
                          left: 16,
                          bottom: 16 + MediaQuery.of(context).padding.bottom,
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
    final tokens = context.appTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add, size: 80, color: tokens.neutral.ink4),
            const SizedBox(height: 24),
            Text(
              '買い物リストがありません',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '新しい買い物リストを作成しましょう',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.neutral.ink2),
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
                  parameters: {'groupID': groupID},
                );
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
                        persist: false,
                        content: Text(e.toString()),
                        action: SnackBarAction(
                          label: 'アップグレード',
                          onPressed: () => showPaywall(context: context),
                        ),
                      ),
                    );
                  }
                } catch (e, st) {
                  if (context.mounted) {
                    showErrorSnackBar(context, e, st);
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
