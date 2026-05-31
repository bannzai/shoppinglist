import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// リスト切替用のボトムシート。
/// 旧 `ShoppingListAppBar` の `DropdownButton` を置き換えるシート版 UI。
/// 現在選択中のリストには accent のチェックマークを表示する。
/// 末尾に「+ 新しいリストを追加」 row を備える。
class ListPickerSheet extends StatelessWidget {
  final String groupID;
  final List<GroupShoppingList> shoppingLists;
  final String currentShoppingListID;
  final void Function(String newID) onShoppingListIDChanged;

  /// 「新しいリストを追加」タップ時に呼ぶコールバック。
  /// 引数 [sheetContext] はこのシート自身の BuildContext で、追加完了後に
  /// `Navigator.of(sheetContext).pop()` でシートを閉じるために使う。
  /// appUser やプレミアム判定の Provider はモーダルシートのスコープでは温まらず
  /// `AsyncLoading` のままになる（appUser が null 扱いになる）ため、実処理は
  /// 本体ツリー側（ListTopBar）で実行し、ここからは委譲のみ行う。
  final void Function(BuildContext sheetContext) onCreateNewList;

  const ListPickerSheet({
    super.key,
    required this.groupID,
    required this.shoppingLists,
    required this.currentShoppingListID,
    required this.onShoppingListIDChanged,
    required this.onCreateNewList,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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
              onTap: () {
                analytics.logEvent(name: 'tap_create_new_list', parameters: {
                  'groupID': groupID,
                });
                onCreateNewList(context);
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
