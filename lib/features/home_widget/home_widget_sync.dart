import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/current_group_id.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/provider/user_groups.dart';

/// RootPage の Resolver パターンに倣い、builder で子ウィジェットをラップする。
/// 表示中グループ/リストは currentGroupIDProvider / currentShoppingListIDProvider から内部で
/// 読み取り、ref.listen でデータ変更を検知してウィジェットストレージへ同期する。
/// 表示ツリーの深さに依存しないよう Resolver chain に置く。
class HomeWidgetSync extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const HomeWidgetSync({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CurrentGroupResolver 配下のため groupID はこの時点で常に非null。
    // 生存中も Notifier が非nullしか入れないため、以下の早期 return は防御。
    final groupID = ref.watch(currentGroupIDProvider);
    if (groupID == null) {
      return builder(context);
    }

    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final themeColorHex =
        ref.watch(appUserProvider).valueOrNull?.themeColorHex ??
        defaultThemeColorHex;
    final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
    final shoppingListsAsync = ref.watch(
      shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium),
    );
    final resolvedShoppingListID = resolveShoppingListID(
      selected: ref.watch(currentShoppingListIDProvider),
      shoppingLists: shoppingListsAsync.valueOrNull ?? [],
    );

    // 初回マウント時にテーマカラーとプレミアム状態を同期する。
    // 以降の変更は ref.listen で検知して同期するため、依存配列は空にしている。
    useEffect(() {
      HomeWidgetDataSync.syncThemeColor(themeColorHex: themeColorHex);
      HomeWidgetDataSync.syncPremiumStatus(isPremium: firestoreIsPremium);
      return null;
    }, const []);

    // テーマカラーの変更を検知して同期
    ref.listen(appUserProvider, (prev, next) {
      final prevThemeColorHex =
          prev?.valueOrNull?.themeColorHex ?? defaultThemeColorHex;
      final nextThemeColorHex =
          next.valueOrNull?.themeColorHex ?? defaultThemeColorHex;
      if (prevThemeColorHex == nextThemeColorHex) {
        return;
      }
      HomeWidgetDataSync.syncThemeColor(themeColorHex: nextThemeColorHex);
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
      },
    );

    // 現在の買い物リストアイテムの同期は、resolvedShoppingListID が確定している時のみ行う。
    // Riverpod の ref.listen を条件分岐内で呼ぶことを避けるため、非null時のみマウントされる
    // _HomeWidgetItemSync に切り出し、その中で無条件に ref.listen する。
    if (resolvedShoppingListID == null) {
      return builder(context);
    }
    return _HomeWidgetItemSync(
      groupID: groupID,
      shoppingListID: resolvedShoppingListID,
      shoppingLists: shoppingListsAsync.valueOrNull ?? [],
      builder: builder,
    );
  }
}

/// resolvedShoppingListID が非nullの時だけマウントされ、現在の買い物リストアイテムの変更を
/// 検知してウィジェットストレージへ同期する。条件分岐なしで ref.listen するための子 Widget。
class _HomeWidgetItemSync extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final Widget Function(BuildContext context) builder;

  const _HomeWidgetItemSync({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      textShoppingListItemsProvider(
        groupID: groupID,
        shoppingListID: shoppingListID,
      ),
      (prev, next) {
        final items = next.valueOrNull;
        if (items != null) {
          final list = shoppingLists.firstWhereOrNull(
            (sl) => sl.id == shoppingListID,
          );
          HomeWidgetDataSync.syncCurrentShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListName: list?.name ?? '',
            items: items,
          );
        }
      },
    );

    return builder(context);
  }
}
