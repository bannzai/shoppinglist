import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/theme_color.dart';
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
    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
    final shoppingListsAsync = ref.watch(
        shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium));

    // 初回同期（WidgetRef.listen は fireImmediately 非対応）
    final currentAppUser = ref.read(appUserProvider).valueOrNull;
    if (currentAppUser != null) {
      HomeWidgetDataSync.syncThemeColor(
        themeColorHex: currentAppUser.themeColorHex ?? defaultThemeColorHex,
      );
    }
    HomeWidgetDataSync.syncPremiumStatus(isPremium: firestoreIsPremium);

    // テーマカラーの変更を検知して同期
    ref.listen(appUserProvider, (prev, next) {
      final prevThemeColorHex =
          prev?.valueOrNull?.themeColorHex ?? defaultThemeColorHex;
      final nextThemeColorHex =
          next.valueOrNull?.themeColorHex ?? defaultThemeColorHex;
      if (prevThemeColorHex == nextThemeColorHex) {
        return;
      }
      HomeWidgetDataSync.syncThemeColor(
        themeColorHex: nextThemeColorHex,
      );
    });

    // プレミアム状態の変更を検知して同期
    ref.listen(firestoreIsPremiumProvider, (prev, next) {
      final prevPremiumValue = prev?.valueOrNull;
      final nextPremiumValue = next.valueOrNull;
      if (prevPremiumValue == nextPremiumValue) {
        return;
      }
      if (nextPremiumValue != null) {
        HomeWidgetDataSync.syncPremiumStatus(isPremium: nextPremiumValue);
      }
    });

    // 買い物リスト一覧の変更を検知して同期
    ref.listen(
        shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium),
        (prev, next) {
      final lists = next.valueOrNull;
      if (lists != null && lists.isNotEmpty) {
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
        final lists = shoppingListsAsync.valueOrNull ?? [];
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
