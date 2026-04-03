import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';

/// RootPage の Resolver パターンに倣い、builder で子ウィジェットをラップする。
/// ref.listen でデータ変更を検知し、ウィジェットストレージへの同期を行う。
class HomeWidgetSync extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final Widget Function(BuildContext context) builder;

  const HomeWidgetSync({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    // 買い物リスト一覧の変更を検知して同期
    ref.listen(
        shoppingListsProvider(groupID: groupID, isPremium: isPremium),
        (prev, next) {
      final lists = next.valueOrNull;
      if (lists != null && lists.isNotEmpty) {
        final groups = ref.read(userGroupsProvider).valueOrNull ?? [];
        final group = groups.firstWhereOrNull((g) => g.id == groupID);
        HomeWidgetDataSync.syncShoppingLists(
          shoppingLists: lists,
          groupID: groupID,
          groupName: group?.name ?? '',
        );
      }
    });

    // 現在の買い物リストアイテムの変更を検知して同期
    ref.listen(
        textShoppingListItemsProvider(
          groupID: groupID,
          shoppingListID: shoppingListID,
          showChecked: true,
        ), (prev, next) {
      final items = next.valueOrNull;
      if (items != null) {
        final lists = ref
                .read(shoppingListsProvider(
                    groupID: groupID, isPremium: isPremium))
                .valueOrNull ??
            [];
        final list = lists.firstWhereOrNull((sl) => sl.id == shoppingListID);
        HomeWidgetDataSync.syncCurrentShoppingListItems(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingListName: list?.name ?? '',
          items: items,
        );
      }
    });

    return builder(context);
  }
}
