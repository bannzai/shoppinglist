import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_fab_menu.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// [CreateListMenuButton] のメニュー選択肢。
enum _CreateListMenuAction {
  /// 今日の日付でリストを追加。
  createToday,

  /// 現在のリストを複製（全アイテム引き継ぎ）。
  duplicate,

  /// 未チェックのみ引き継いで複製（チェック済みアイテムは引き継がない）。
  duplicateUncheckedOnly,
}

/// `ListTopBar` 右側に置く「リストを追加」ボタン（Issue #461 で右下 FAB から移動）。
/// 買い物リストアイコンに + バッジを重ねた合成アイコン([_AddListIcon])で、
/// アイテム追加の FAB(`ExpandableFab`)とは対象が違う（リスト自体を作る）ことを見せる。
///
/// タップで以下 3 アクションのメニュー(PopupMenu)を開く:
/// - 今日の日付でリストを追加（リスト作成 → 表示切替 → 空アイテム 1 件追加まで連鎖し、
///   入力行の auto-focus 機構でそのままキーボード入力に入れる。
///   `ShoppingListAdd` / `TextShoppingListItemWidget` 参照）
/// - 現在のリストを複製（全アイテムを引き継ぐ）
/// - 未チェックのみ引き継いで複製（チェック済みアイテムは引き継がない）
class CreateListMenuButton extends HookConsumerWidget {
  final String groupID;

  /// 本体ツリーで取得済みの AppUser。リスト作成の createUserID に使う。
  /// 未ロード（null）の間はボタンを無効化する。
  final AppUser? appUser;

  /// 表示中の買い物リスト。複製アクションの複製元になる。
  /// 未取得（null）の間は複製アクションを無効化（dim 表示）する。
  final GroupShoppingList? shoppingList;

  /// 表示中リストのアイテム一覧（チェック済み含む全件）。複製アクションで引き継ぐ。
  /// 未取得（null）の間は複製アクションを無効化（dim 表示）する。
  /// 取得完了前に空リスト扱いで複製するとアイテムが失われるため、空（[]）とは区別する。
  final List<GroupShoppingListItem>? shoppingListItems;

  const CreateListMenuButton({
    super.key,
    required this.groupID,
    required this.appUser,
    required this.shoppingList,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    // フィールドは null promotion が効かないため、コールバックで `appUser.id` を
    // 参照できるよう final ローカルに束ねる。
    final appUser = this.appUser;
    final shoppingList = this.shoppingList;
    final shoppingListItems = this.shoppingListItems;
    // 新規リスト作成・複製リクエストの実行中フラグ。作成は上限カウント等のサーバー往復を
    // 伴い時間がかかるため、その間の連打による多重作成を防ぐ。
    final isCreating = useState(false);
    // 複製はメニュー展開中に複製元リストの取得が完了することはない
    // （itemBuilder 時点の値がメニューに固定される）ため、build 時点の取得状況で判定する。
    // アイテム一覧未取得（null）の間も無効化する。ロード中に複製すると空リストとして
    // 複製されアイテムが失われるため。
    final canDuplicate =
        shoppingList != null && shoppingListItems != null && !isCreating.value;

    final fabMenuNotifier = ref.watch(shoppingListFabMenuProvider.notifier);
    final shoppingListAdd = ref.watch(
      shoppingListAddProvider(groupID: groupID),
    );
    final addShoppingListItem = ref.watch(
      addShoppingListItemProvider(groupID: groupID),
    );
    final shoppingListDuplicate = ref.watch(
      shoppingListDuplicateProvider(groupID: groupID),
    );
    final currentShoppingListIDNotifier = ref.watch(
      currentShoppingListIDProvider.notifier,
    );

    return PopupMenuButton<_CreateListMenuAction>(
      key: const Key('create_list_menu_button'),
      tooltip: context.l10n.shoppingListCreateListTooltip,
      // AppUser 未ロード・実行中は無効化（タップ不可）。
      enabled: appUser != null && !isCreating.value,
      icon:
          isCreating.value
              ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                ),
              )
              // AppUser 未ロードで無効の間は dim 表示し、タップ不可であることを見せる
              // （enabled: false はアイコンの見た目を変えないため）。
              : Opacity(
                opacity: appUser == null ? 0.5 : 1,
                child: const _AddListIcon(),
              ),
      onOpened: () {
        HapticFeedback.mediumImpact();
        analytics.logEvent(
          name: 'tap_open_create_list_menu',
          parameters: {'groupID': groupID},
        );
        // アイテム追加 FAB(`ExpandableFab`)の展開メニューが開いたままだと、この
        // PopupMenu の背後に残り追加メニューが 2 つ同時表示されるため閉じる
        // （旧ダブル FAB では共有状態の置換で自動的に閉じていた挙動の踏襲）。
        fabMenuNotifier.close();
        // 入力行フォーカス中はキーボードを閉じてからメニューを重ねる
        // （リスト設定等のシート系ボタンと同じ扱い）。
        FocusScope.of(context).unfocus();
      },
      onCanceled: () {
        analytics.logEvent(
          name: 'cancel_create_list_menu',
          parameters: {'groupID': groupID},
        );
      },
      onSelected: (action) {
        // enabled 条件（appUser != null）で保証されるが、null promotion のため防御する。
        if (appUser == null) {
          return;
        }
        switch (action) {
          case _CreateListMenuAction.createToday:
            analytics.logEvent(
              name: 'tap_create_list_menu_today',
              parameters: {'groupID': groupID},
            );
            _createTodayList(
              context: context,
              appUser: appUser,
              isCreating: isCreating,
              shoppingListAdd: shoppingListAdd,
              addShoppingListItem: addShoppingListItem,
              currentShoppingListIDNotifier: currentShoppingListIDNotifier,
            );
          case _CreateListMenuAction.duplicate:
            // 複製元リスト・アイテム一覧未取得の間は enabled: false で選択されないため
            // 到達しない（防御）。
            if (shoppingList == null || shoppingListItems == null) {
              return;
            }
            analytics.logEvent(
              name: 'tap_duplicate_list_from_menu',
              parameters: {
                'groupID': groupID,
                'sourceShoppingListID': shoppingList.id,
              },
            );
            _duplicateCurrentList(
              context: context,
              appUser: appUser,
              sourceShoppingList: shoppingList,
              shoppingListItems: _latestShoppingListItems(
                ref: ref,
                sourceShoppingList: shoppingList,
                buildTimeShoppingListItems: shoppingListItems,
              ),
              isCreating: isCreating,
              uncheckedOnly: false,
              shoppingListDuplicate: shoppingListDuplicate,
              currentShoppingListIDNotifier: currentShoppingListIDNotifier,
            );
          case _CreateListMenuAction.duplicateUncheckedOnly:
            // 複製元リスト・アイテム一覧未取得の間は enabled: false で選択されないため
            // 到達しない（防御）。
            if (shoppingList == null || shoppingListItems == null) {
              return;
            }
            analytics.logEvent(
              name: 'tap_duplicate_unchecked_from_menu',
              parameters: {
                'groupID': groupID,
                'sourceShoppingListID': shoppingList.id,
              },
            );
            _duplicateCurrentList(
              context: context,
              appUser: appUser,
              sourceShoppingList: shoppingList,
              shoppingListItems: _latestShoppingListItems(
                ref: ref,
                sourceShoppingList: shoppingList,
                buildTimeShoppingListItems: shoppingListItems,
              ),
              isCreating: isCreating,
              uncheckedOnly: true,
              shoppingListDuplicate: shoppingListDuplicate,
              currentShoppingListIDNotifier: currentShoppingListIDNotifier,
            );
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: _CreateListMenuAction.createToday,
              child: _CreateListMenuRow(
                icon: Icons.today_outlined,
                label: context.l10n.shoppingListCreateTodayList,
                enabled: true,
              ),
            ),
            PopupMenuItem(
              value: _CreateListMenuAction.duplicate,
              enabled: canDuplicate,
              child: _CreateListMenuRow(
                icon: Icons.content_copy_outlined,
                label: context.l10n.shoppingListDuplicateCurrentList,
                enabled: canDuplicate,
              ),
            ),
            PopupMenuItem(
              value: _CreateListMenuAction.duplicateUncheckedOnly,
              enabled: canDuplicate,
              child: _CreateListMenuRow(
                icon: Icons.check_box_outline_blank,
                label: context.l10n.shoppingListDuplicateUncheckedOnly,
                enabled: canDuplicate,
              ),
            ),
          ],
    );
  }

  /// 複製に使う、選択時点の最新アイテム一覧を返す。
  ///
  /// メニュー表示中に onOpened の unfocus 起点でフォーカス喪失保存（編集中テキストの
  /// 確定・空行削除。`TextShoppingListItemWidget` 参照）が非同期に走ることがあり、
  /// build 時に固定した [buildTimeShoppingListItems] のままでは直前の入力が複製先から
  /// 欠落する。選択時点で provider から読み直して確定済みの最新一覧を使う
  /// （ストリーム未反映・エラー時は build 時の一覧に fallback）。
  List<GroupShoppingListItem> _latestShoppingListItems({
    required WidgetRef ref,
    required GroupShoppingList sourceShoppingList,
    required List<GroupShoppingListItem> buildTimeShoppingListItems,
  }) {
    return ref
            .read(
              textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: sourceShoppingList.id,
              ),
            )
            .valueOrNull ??
        buildTimeShoppingListItems;
  }

  /// 今日の日付名でリストを作成 → 表示切替 → 空アイテム追加まで連鎖する。
  Future<void> _createTodayList({
    required BuildContext context,
    required AppUser appUser,
    required ValueNotifier<bool> isCreating,
    required ShoppingListAdd shoppingListAdd,
    required AddShoppingListItem addShoppingListItem,
    required CurrentShoppingListID currentShoppingListIDNotifier,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    isCreating.value = true;
    try {
      final newShoppingList = await shoppingListAdd(
        createUserID: appUser.id,
        groupID: groupID,
        shoppingLocationID: null,
        duplicatedFromGroupShoppingListID: null,
      );
      // 作成直後のリストは空なので order は先頭の 0
      // (`List<GroupShoppingListItem>.nextOrder` の空リスト値)。
      // この空アイテムが新リストの入力行として mount され、
      // auto-focus でそのままキーボード入力に入れる。
      await addShoppingListItem(
        shoppingListID: newShoppingList.id,
        userID: appUser.id,
        message: '',
        order: 0,
        description: null,
        color: null,
      );
      // 先頭フォールバックと同じ結果になるが、明示選択として
      // 記録しグループ切替等の揺れに備える(冪等)。
      currentShoppingListIDNotifier.update(newShoppingList.id);
    } on ShoppingListLimitExceededException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          persist: false,
          content: Text(l10n.shoppingListLimitExceeded(e.limit)),
          action: SnackBarAction(
            label: l10n.commonUpgrade,
            // SnackBar はこの widget の破棄後も ScaffoldMessenger 上に残るため、
            // タップ時に破棄済み context で showPaywall しないようガードする。
            onPressed: () {
              if (context.mounted) {
                showPaywall(context: context);
              }
            },
          ),
        ),
      );
    } catch (e, st) {
      logError(e, st);
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(e, st).message)),
      );
    } finally {
      // 破棄済みの ValueNotifier へ書き込まないようガードする。
      if (context.mounted) {
        isCreating.value = false;
      }
    }
  }

  /// 表示中のリストを複製し、複製先リストへ表示を切り替える。
  /// [uncheckedOnly] が true のときは未チェックのアイテムだけを引き継ぐ。
  /// [shoppingListItems] はフィールドの null（未取得）を呼び出し元（onSelected の防御）で
  /// 除いた非 null の一覧を受け取る。
  Future<void> _duplicateCurrentList({
    required BuildContext context,
    required AppUser appUser,
    required GroupShoppingList sourceShoppingList,
    required List<GroupShoppingListItem> shoppingListItems,
    required ValueNotifier<bool> isCreating,
    required bool uncheckedOnly,
    required ShoppingListDuplicate shoppingListDuplicate,
    required CurrentShoppingListID currentShoppingListIDNotifier,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    isCreating.value = true;
    try {
      final newShoppingList = await shoppingListDuplicate(
        createUserID: appUser.id,
        groupID: groupID,
        sourceShoppingList: sourceShoppingList,
        shoppingListItems:
            uncheckedOnly
                ? shoppingListItems
                    .where(
                      (item) =>
                          item.status == GroupShoppingListItemStatus.unchecked,
                    )
                    .toList()
                : shoppingListItems,
      );
      currentShoppingListIDNotifier.update(newShoppingList.id);
      messenger.showSnackBar(
        SnackBar(persist: false, content: Text(l10n.shoppingListDuplicated)),
      );
    } on ShoppingListLimitExceededException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          persist: false,
          content: Text(l10n.shoppingListLimitExceeded(e.limit)),
          action: SnackBarAction(
            label: l10n.commonUpgrade,
            // SnackBar はこの widget の破棄後も ScaffoldMessenger 上に残るため、
            // タップ時に破棄済み context で showPaywall しないようガードする。
            onPressed: () {
              if (context.mounted) {
                showPaywall(context: context);
              }
            },
          ),
        ),
      );
    } catch (e, st) {
      logError(e, st);
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(e, st).message)),
      );
    } finally {
      // 破棄済みの ValueNotifier へ書き込まないようガードする。
      if (context.mounted) {
        isCreating.value = false;
      }
    }
  }
}

/// メニュー 1 行分（アイコン + ラベル）。
/// [enabled] が false のときは `FabActionMenu` の無効行と同じ opacity 0.5 で dim 表示する
/// （`PopupMenuItem.enabled` はテキスト色しか変えず、アイコンが無効に見えないため）。
class _CreateListMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;

  const _CreateListMenuRow({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: tokens.neutral.ink),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

/// 買い物リスト（receipt）アイコンの右上に + バッジを重ねた合成アイコン。
/// バッジはツールバー背景(surface)と同色の縁取りで本体アイコンとの重なりを切り抜いて見せる。
class _AddListIcon extends StatelessWidget {
  const _AddListIcon();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(Icons.receipt_long, size: 22, color: tokens.accent),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.accent,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.neutral.surface, width: 1.5),
              ),
              child: const Icon(Icons.add, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
