import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// リスト切替用のボトムシート。
/// 旧 `ShoppingListAppBar` の `DropdownButton` を置き換えるシート版 UI。
/// 現在選択中のリストには accent のチェックマークを表示する。
/// 末尾に「+ 新しいリストを追加」 row を備える。
class ListPickerSheet extends ConsumerWidget {
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
    final tokens = context.tokens;
    // フィールドは null promotion が効かないため、コールバックで `appUser.id` を
    // 参照できるよう final ローカルに束ねる。
    final appUser = this.appUser;
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
                    'リストを切り替える',
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
            _AddListRow(
              onTap: () async {
                analytics.logEvent(name: 'tap_create_new_list', parameters: {
                  'groupID': groupID,
                });
                if (appUser == null) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop();
                try {
                  final newList = await ref
                      .read(shoppingListAddProvider(groupID: groupID))
                      .call(
                        createUserID: appUser.id,
                        groupID: groupID,
                        shoppingLocationID: null,
                        duplicatedFromGroupShoppingListID: null,
                      );
                  onShoppingListIDChanged(newList.id);
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
            ),
          ],
        ),
      ),
    );
  }
}

class _AddListRow extends StatelessWidget {
  final VoidCallback onTap;
  const _AddListRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: tokens.accent),
            const SizedBox(width: 8),
            Text(
              '新しいリストを追加',
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
    final tokens = context.tokens;
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
