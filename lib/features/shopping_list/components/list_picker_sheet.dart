import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/navigator.dart';

/// リスト切替用のボトムシート。
/// 旧 `ShoppingListAppBar` の `DropdownButton` を置き換えるシート版 UI。
/// 現在選択中のリストには accent のチェックマークを表示する。
/// 末尾に「+ 新しいリストを追加」 row を備える。
class ListPickerSheet extends HookConsumerWidget {
  final String groupID;
  final List<GroupShoppingList> shoppingLists;
  final String currentShoppingListID;
  final void Function(String newID) onShoppingListIDChanged;

  /// 本体ツリー（ListTopBar）で取得済みの AppUser を受け取る。
  /// このシートは appShowModalBottomSheet 経由で root Navigator 側に表示され、
  /// ページのネスト ProviderScope の外（AppEntityPrepareResolver なし）になる。
  /// そのためシート内で appUserProvider を watch / read しても cold instance の
  /// AsyncLoading(null) を返しうる。値は warm な親ツリーから渡す。
  final AppUser? appUser;

  const ListPickerSheet({
    super.key,
    required this.groupID,
    required this.shoppingLists,
    required this.currentShoppingListID,
    required this.onShoppingListIDChanged,
    required this.appUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    // フィールドは null promotion が効かないため、コールバックで `appUser.id` を
    // 参照できるよう final ローカルに束ねる。
    final appUser = this.appUser;
    final shoppingListAdd = ref.watch(
      shoppingListAddProvider(groupID: groupID),
    );
    // 新規リスト作成リクエストの実行中フラグ。作成は上限カウント等のサーバー往復を
    // 伴い時間がかかるため、その間の連打による作成と pop の多重実行を防ぐ (#372)。
    final isCreatingList = useState(false);
    return SafeArea(
      top: false,
      child: Container(
        color: tokens.neutral.card,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: tokens.neutral.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    context.l10n.shoppingListPickerTitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.neutral.ink2,
                    ),
                  ),
                ],
              ),
            ),
            for (final list in shoppingLists)
              _ListPickerRow(
                list: list,
                selected: list.id == currentShoppingListID,
                onTap: () {
                  analytics.logEvent(
                    name: 'tap_confirm_list_picker',
                    parameters: {
                      'groupID': groupID,
                      'selectedShoppingListID': list.id,
                    },
                  );
                  Navigator.of(context).pop();
                  if (list.id != currentShoppingListID) {
                    onShoppingListIDChanged(list.id);
                  }
                },
              ),
            Container(
              height: 0.5,
              color: tokens.neutral.divider,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            ListPickerAddListRow(
              isCreating: isCreatingList.value,
              onTap: () async {
                analytics.logEvent(
                  name: 'tap_create_new_list',
                  parameters: {'groupID': groupID},
                );
                if (appUser == null) {
                  Navigator.of(context).pop();
                  return;
                }
                // pop を await より後に行う。先に pop すると catch 実行時には
                // context.mounted=false となり、エラー SnackBar / paywall が
                // 握り潰される。navigator / messenger を await 前に束ねておく。
                // また、await 中にシートが手動クローズされると遅延した pop が
                // ホーム(唯一のページルート)まで剥がして黒画面になるため、
                // pop はこのシート自身のルートに限定する (#372)。
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final sheetRoute = ModalRoute.of(context);
                final l10n = context.l10n;
                isCreatingList.value = true;
                try {
                  final newList = await shoppingListAdd.call(
                    createUserID: appUser.id,
                    groupID: groupID,
                    shoppingLocationID: null,
                    duplicatedFromGroupShoppingListID: null,
                  );
                  popRouteSafely(navigator: navigator, route: sheetRoute);
                  onShoppingListIDChanged(newList.id);
                } on ShoppingListLimitExceededException catch (e) {
                  popRouteSafely(navigator: navigator, route: sheetRoute);
                  messenger.showSnackBar(
                    SnackBar(
                      persist: false,
                      content: Text(l10n.shoppingListLimitExceeded(e.limit)),
                      action: SnackBarAction(
                        label: l10n.commonUpgrade,
                        onPressed:
                            () => showPaywall(context: navigator.context),
                      ),
                    ),
                  );
                } catch (e, st) {
                  logError(e, st);
                  popRouteSafely(navigator: navigator, route: sheetRoute);
                  messenger.showSnackBar(
                    SnackBar(content: Text(describeError(e, st).message)),
                  );
                } finally {
                  // シートが既に dispose 済み(手動クローズ等)の場合に
                  // 破棄済みの ValueNotifier へ書き込まないようガードする。
                  if (context.mounted) {
                    isCreatingList.value = false;
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 「+ 新しいリストを追加」行。
/// [isCreating] の間はタップを無効化しスピナーを表示して、連打による多重実行を防ぐ。
class ListPickerAddListRow extends StatelessWidget {
  /// 行タップで新規リスト作成を開始するコールバック。
  final VoidCallback onTap;

  /// 新規リスト作成リクエストの実行中か。
  final bool isCreating;

  const ListPickerAddListRow({
    super.key,
    required this.onTap,
    required this.isCreating,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return InkWell(
      onTap: isCreating ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            if (isCreating)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                ),
              )
            else
              Icon(Icons.add, size: 18, color: tokens.accent),
            const SizedBox(width: 8),
            Text(
              context.l10n.shoppingListPickerAddList,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListPickerRow extends StatelessWidget {
  final GroupShoppingList list;
  final bool selected;
  final VoidCallback onTap;
  const _ListPickerRow({
    required this.list,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                list.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: tokens.neutral.ink,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: tokens.accent),
          ],
        ),
      ),
    );
  }
}
