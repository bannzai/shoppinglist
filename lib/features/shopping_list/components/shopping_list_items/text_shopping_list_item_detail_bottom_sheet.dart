import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// アイテム詳細シート。カテゴリの確認・変更とアイテムの削除を行う。
///
/// NOTE(#464): 以前あった説明(description)・写真(imageURL)・カラー(color)の編集機能は
/// 一旦削除した。名前マッチによる自動付与での再設計は #463 を参照。
class TextShoppingListItemDetailBottomSheet extends ConsumerWidget {
  final String groupID;
  final GroupShoppingListItem textShoppingListItem;

  const TextShoppingListItemDetailBottomSheet({
    super.key,
    required this.groupID,
    required this.textShoppingListItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupDatabase = ref.watch(groupDatabaseProvider(groupID: groupID));

    // カテゴリは先頭軸(axes.first)のキーワードマッチで動的に決まる(アイテムはカテゴリIDを持たない)。
    // appShowModalBottomSheet は AppResolvers でラップされているため build 内の ref.watch が機能する。
    // 遷移時の ref.read だと AsyncLoading(null) になり得るので、ここで watch して値を確定させる。
    final categoryAxes =
        ref.watch(groupCategoryAxesProvider(groupID: groupID)).valueOrNull ??
        const <GroupCategoryAxis>[];
    final categoryAxis = categoryAxes.firstOrNull;
    final categories =
        categoryAxis == null
            ? const <GroupCategory>[]
            : ref
                    .watch(
                      groupCategoriesProvider(
                        groupID: groupID,
                        categoryAxisID: categoryAxis.id,
                      ),
                    )
                    .valueOrNull ??
                const <GroupCategory>[];
    final matchedCategory =
        categoryAxis == null
            ? null
            : categories.firstWhereOrNull(
              (category) =>
                  category.id ==
                  findMatchingCategoryID(
                    item: textShoppingListItem,
                    categories: categories,
                  ),
            );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル行: 中央にアイテム名、右上に削除(ゴミ箱)アイコンを置く。
            // 左に IconButton と同じ幅の余白を入れてタイトルを視覚的に中央へ寄せる。
            Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    textShoppingListItem.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.shoppingListItemDeleteTooltip,
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () {
                    analytics.logEvent(
                      name: 'tap_delete_item',
                      parameters: {
                        'groupID': groupID,
                        'itemID': textShoppingListItem.id,
                      },
                    );
                    showDialog(
                      context: context,
                      builder:
                          (dialogContext) => AlertDialog(
                            title: Text(
                              context.l10n.shoppingListItemDeleteConfirm,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  analytics.logEvent(
                                    name: 'tap_confirm_delete_item',
                                    parameters: {
                                      'groupID': groupID,
                                      'itemID': textShoppingListItem.id,
                                    },
                                  );
                                  groupDatabase
                                      .shoppingListItemsReference(
                                        shoppingListID:
                                            textShoppingListItem.shoppingListID,
                                      )
                                      .doc(textShoppingListItem.id)
                                      .delete();
                                  Navigator.pop(dialogContext);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  context.l10n.commonDelete,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: colorScheme.error),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text(context.l10n.commonCancel),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // カテゴリセクション。軸が無い(カテゴリ機能未使用)ときは表示しない。
            if (categoryAxis != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.commonCategory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      matchedCategory?.name ?? context.l10n.commonUncategorized,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      analytics.logEvent(
                        name:
                            matchedCategory != null
                                ? 'tap_change_category_from_item'
                                : 'tap_select_category_from_item',
                        parameters: {
                          'groupID': groupID,
                          'itemID': textShoppingListItem.id,
                        },
                      );
                      // マッチ済み・未分類のどちらもカテゴリ選択モードの一覧へ誘導する。
                      // 一覧で行をタップするとこのアイテムを選んだカテゴリへ移し(アイテム名の
                      // 完全一致キーワードを付け替える)、一覧で新規カテゴリを追加してそのまま
                      // 選ぶこともできる。シートは閉じずに push する。
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GroupCategoryPage(
                                groupID: groupID,
                                selectionForItem: textShoppingListItem,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      matchedCategory != null
                          ? context.l10n.shoppingListCategoryChange
                          : context.l10n.shoppingListCategorySelect,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
