import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// `ShoppingListPage` 右下、アイテム追加 FAB の上に置く「新しいリストを作成」ボタン。
/// 買い物リストアイコンに + バッジを重ねた合成アイコン([_AddListIcon])の白地円形ボタンで、
/// accent 塗りのアイテム追加 FAB と役割の違いを見せる。
///
/// タップで以下を連鎖し、「新しい買い物を始める」をワンタップにする:
/// 1. リストを作成（名前は日付の自動命名。`ShoppingListAdd` 参照）
/// 2. 作成したリストへ表示を切り替え
/// 3. 空アイテムを 1 件追加（入力行の auto-focus 機構でそのままキーボード入力に入れる。
///    `TextShoppingListItemWidget` 参照）
class CreateListFab extends HookConsumerWidget {
  final String groupID;

  /// 本体ツリーで取得済みの AppUser。リスト作成の createUserID に使う。
  /// 未ロード（null）の間はタップしても何もしない。
  final AppUser? appUser;

  const CreateListFab({
    super.key,
    required this.groupID,
    required this.appUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    // フィールドは null promotion が効かないため、コールバックで `appUser.id` を
    // 参照できるよう final ローカルに束ねる。
    final appUser = this.appUser;
    // 新規リスト作成リクエストの実行中フラグ。作成は上限カウント等のサーバー往復を
    // 伴い時間がかかるため、その間の連打による多重作成を防ぐ。
    final isCreating = useState(false);

    return Container(
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
          onTap: isCreating.value || appUser == null
              ? null
              : () async {
                  analytics.logEvent(
                    name: 'tap_create_list_fab',
                    parameters: {'groupID': groupID},
                  );
                  final messenger = ScaffoldMessenger.of(context);
                  // リスト作成が Stream へ反映されると、_ActiveShoppingList が
                  // 先頭リストフォールバック(resolveShoppingListID)で新リストへ
                  // 切り替わり ValueKey 差し替えでこの widget ごと破棄される。
                  // 破棄後の ref.read は使えないため、await を挟む前に
                  // call クラスと notifier を束縛しておく。
                  final shoppingListAdd =
                      ref.read(shoppingListAddProvider(groupID: groupID));
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
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    // 破棄済みの ValueNotifier へ書き込まないようガードする。
                    if (context.mounted) {
                      isCreating.value = false;
                    }
                  }
                },
          child: Center(
            child: isCreating.value
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                    ),
                  )
                : const _AddListIcon(),
          ),
        ),
      ),
    );
  }
}

/// 買い物リスト（receipt）アイコンの右上に + バッジを重ねた合成アイコン。
/// バッジはボタン背景と同色の縁取りで本体アイコンとの重なりを切り抜いて見せる。
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
