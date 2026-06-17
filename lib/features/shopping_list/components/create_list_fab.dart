import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/fab_action_menu.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// `ShoppingListPage` 右下、アイテム追加 FAB の上に置く「新しいリストを作成」ボタン。
/// 買い物リストアイコンに + バッジを重ねた合成アイコン([_AddListIcon])の白地円形ボタンで、
/// accent 塗りのアイテム追加 FAB と役割の違いを見せる。
///
/// タップで以下 3 アクションのメニューを上方向に展開する（`ExpandableFab` と同じ展開機構）:
/// - 今日の日付でリストを追加（リスト作成 → 表示切替 → 空アイテム 1 件追加まで連鎖し、
///   入力行の auto-focus 機構でそのままキーボード入力に入れる。
///   `ShoppingListAdd` / `TextShoppingListItemWidget` 参照）
/// - 現在のリストを複製（全アイテムを引き継ぐ）
/// - 未チェックのみ引き継いで複製（チェック済みアイテムは引き継がない）
///
/// 展開中（x 状態）にもう一度タップするとメニューを閉じる。
class CreateListFab extends HookConsumerWidget {
  final String groupID;

  /// 本体ツリーで取得済みの AppUser。リスト作成の createUserID に使う。
  /// 未ロード（null）の間はタップしても何もしない。
  final AppUser? appUser;

  /// 表示中の買い物リスト。複製アクションの複製元になる。
  /// 未取得（null）の間は複製アクションを無効化（dim 表示）する。
  final GroupShoppingList? shoppingList;

  /// 表示中リストのアイテム一覧（チェック済み含む全件）。複製アクションで引き継ぐ。
  final List<GroupShoppingListItem> shoppingListItems;

  const CreateListFab({
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
    // 新規リスト作成・複製リクエストの実行中フラグ。作成は上限カウント等のサーバー往復を
    // 伴い時間がかかるため、その間の連打による多重作成を防ぐ。
    final isCreating = useState(false);
    final open = useState(false);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
    final curve = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
      [controller],
    );

    // 展開メニューの開閉に合わせてアニメーションを駆動する（`ExpandableFab` と同じ機構）。
    // 依存配列は open.value のみ — 開閉の変化イベントだけで forward/reverse を切り替える。
    useEffect(() {
      if (open.value) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [open.value]);

    void close() => open.value = false;

    final actions = <FabMenuAction>[
      FabMenuAction(
        icon: Icons.today_outlined,
        label: '今日の日付でリストを追加',
        // AppUser 未ロード・実行中は無効化（dim 表示・タップ不可）。
        onTap: appUser == null || isCreating.value
            ? null
            : () {
                analytics.logEvent(
                  name: 'tap_create_list_menu_today',
                  parameters: {'groupID': groupID},
                );
                close();
                _createTodayList(
                  context: context,
                  ref: ref,
                  appUser: appUser,
                  isCreating: isCreating,
                );
              },
      ),
      FabMenuAction(
        icon: Icons.content_copy_outlined,
        label: '現在のリストを複製',
        // AppUser・複製元リスト未ロード・実行中は無効化（dim 表示・タップ不可）。
        onTap: appUser == null || shoppingList == null || isCreating.value
            ? null
            : () {
                analytics.logEvent(
                  name: 'tap_duplicate_list_from_fab',
                  parameters: {
                    'groupID': groupID,
                    'sourceShoppingListID': shoppingList.id,
                  },
                );
                close();
                _duplicateCurrentList(
                  context: context,
                  ref: ref,
                  appUser: appUser,
                  sourceShoppingList: shoppingList,
                  isCreating: isCreating,
                  uncheckedOnly: false,
                );
              },
      ),
      FabMenuAction(
        icon: Icons.check_box_outline_blank,
        label: '未チェックのみ引き継いで複製',
        // AppUser・複製元リスト未ロード・実行中は無効化（dim 表示・タップ不可）。
        onTap: appUser == null || shoppingList == null || isCreating.value
            ? null
            : () {
                analytics.logEvent(
                  name: 'tap_duplicate_unchecked_from_fab',
                  parameters: {
                    'groupID': groupID,
                    'sourceShoppingListID': shoppingList.id,
                  },
                );
                close();
                _duplicateCurrentList(
                  context: context,
                  ref: ref,
                  appUser: appUser,
                  sourceShoppingList: shoppingList,
                  isCreating: isCreating,
                  uncheckedOnly: true,
                );
              },
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 展開メニュー。FAB の上に積み、open に応じて下端基準で上方向へ伸縮する。
        FabActionMenu(animation: curve, actions: actions),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tokens.neutral.card,
            shape: BoxShape.circle,
            border: Border.all(color: tokens.neutral.divider),
            boxShadow: tokens.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              // タップでメニューを開閉する。展開中（x 状態）なら閉じ、それ以外は展開する。
              // リスト作成（今日の日付）はメニュー内の先頭アクションに集約している。
              onTap: isCreating.value || appUser == null
                  ? null
                  : () {
                      if (open.value) {
                        analytics.logEvent(
                          name: 'tap_close_create_list_menu',
                          parameters: {'groupID': groupID},
                        );
                        close();
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      analytics.logEvent(
                        name: 'tap_open_create_list_menu',
                        parameters: {'groupID': groupID},
                      );
                      open.value = true;
                    },
              child: Center(
                child: isCreating.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(tokens.accent),
                        ),
                      )
                    // 閉時は合成アイコン、メニュー展開中は x（閉じる）。
                    // `ExpandableFab` と同じ AnimatedSwitcher の回転+フェードで入れ替える。
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            RotationTransition(
                          turns:
                              Tween(begin: 0.85, end: 1.0).animate(animation),
                          child:
                              FadeTransition(opacity: animation, child: child),
                        ),
                        child: open.value
                            ? Icon(
                                Icons.close,
                                key: const ValueKey(true),
                                size: 22,
                                color: tokens.accent,
                              )
                            : const _AddListIcon(key: ValueKey(false)),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 今日の日付名でリストを作成 → 表示切替 → 空アイテム追加まで連鎖する（従来のタップ動作）。
  Future<void> _createTodayList({
    required BuildContext context,
    required WidgetRef ref,
    required AppUser appUser,
    required ValueNotifier<bool> isCreating,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    // リスト作成が Stream へ反映されると、_ActiveShoppingList が
    // 先頭リストフォールバック(resolveShoppingListID)で新リストへ
    // 切り替わり ValueKey 差し替えでこの widget ごと破棄される。
    // 破棄後の ref.read は使えないため、await を挟む前に
    // call クラスと notifier を束縛しておく。
    final shoppingListAdd = ref.read(shoppingListAddProvider(groupID: groupID));
    final addShoppingListItem =
        ref.read(addShoppingListItemProvider(groupID: groupID));
    final currentShoppingListIDNotifier =
        ref.read(currentShoppingListIDProvider.notifier);
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
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'アップグレード',
            onPressed: () => showPaywall(context: context),
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
  Future<void> _duplicateCurrentList({
    required BuildContext context,
    required WidgetRef ref,
    required AppUser appUser,
    required GroupShoppingList sourceShoppingList,
    required ValueNotifier<bool> isCreating,
    required bool uncheckedOnly,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    // 複製が Stream へ反映されると _ActiveShoppingList の ValueKey 差し替えで
    // この widget ごと破棄されるため、await を挟む前に call クラスと notifier を
    // 束縛しておく（_createTodayList と同じ理由）。
    final shoppingListDuplicate =
        ref.read(shoppingListDuplicateProvider(groupID: groupID));
    final currentShoppingListIDNotifier =
        ref.read(currentShoppingListIDProvider.notifier);
    isCreating.value = true;
    try {
      final newShoppingList = await shoppingListDuplicate(
        createUserID: appUser.id,
        groupID: groupID,
        sourceShoppingList: sourceShoppingList,
        shoppingListItems: uncheckedOnly
            ? shoppingListItems
                .where((item) =>
                    item.status == GroupShoppingListItemStatus.unchecked)
                .toList()
            : shoppingListItems,
      );
      currentShoppingListIDNotifier.update(newShoppingList.id);
      messenger.showSnackBar(
        SnackBar(
          persist: false,
          content: const Text('リストを複製しました'),
        ),
      );
    } on ShoppingListLimitExceededException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          persist: false,
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'アップグレード',
            onPressed: () => showPaywall(context: context),
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

/// 買い物リスト（receipt）アイコンの右上に + バッジを重ねた合成アイコン。
/// バッジはボタン背景と同色の縁取りで本体アイコンとの重なりを切り抜いて見せる。
class _AddListIcon extends StatelessWidget {
  const _AddListIcon({super.key});

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
                border: Border.all(color: tokens.neutral.card, width: 1.5),
              ),
              child: const Icon(Icons.add, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
