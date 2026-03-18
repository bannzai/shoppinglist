import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/category_presets.dart';
import 'package:shoppinglist/style/color.dart';

class ShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final bool sortByCategory;

  const ShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.sortByCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListItems = ref
            .watch(textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
                showChecked: true))
            .valueOrNull ??
        [];
    final axesAsync = ref.watch(groupCategoryAxesProvider(groupID: groupID));

    return axesAsync.when(
      data: (axes) {
        if (axes.isEmpty || !sortByCategory) {
          return _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
          );
        }

        final axis = axes.first;
        return _CategorizedShoppingListItems(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingListItems: shoppingListItems,
          categoryAxisID: axis.id,
        );
      },
      error: (e, st) => Center(child: Text(e.toString())),
      loading: () => _FlatShoppingListItems(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListItems: shoppingListItems,
      ),
    );
  }
}

/// カテゴリが存在しない場合のフラット表示（従来の表示）
class _FlatShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const _FlatShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableList(
      onReorder: (oldIndex, newIndex) {
        // NOTE: ドラッグ時にリストから要素を一時的に削除するため、newIndex が1つずれるのを調整。
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        debugPrint('oldIndex: $oldIndex, newIndex: $newIndex');

        final changedItems = [...shoppingListItems];
        final movedItem = changedItems.removeAt(oldIndex);
        changedItems.insert(newIndex, movedItem);

        // 更新したリストに基づき order を再計算
        final orderedItems = changedItems
            .asMap()
            .entries
            .map((entry) => entry.value.copyWith(order: entry.key))
            .toList();

        ref.read(shoppingListItemBatchUpdateProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              shoppingListItems: orderedItems,
            );
      },
      itemCount: shoppingListItems.length,
      itemBuilder: (context, index) {
        final item = shoppingListItems[index];

        return TextShoppingListItemWidget(
          key: ValueKey(item.id),
          groupID: groupID,
          textShoppingListItem: item,
          shoppingListItems: shoppingListItems,
          reorderIndex: index,
        );
      },
    );
  }
}

/// カテゴリが存在する場合のグルーピング表示
class _CategorizedShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  final String categoryAxisID;

  const _CategorizedShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.categoryAxisID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupCategoriesProvider(
        groupID: groupID, categoryAxisID: categoryAxisID));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
          );
        }

        final grouped = groupItemsByCategory(
          items: shoppingListItems,
          categories: categories,
        );

        return _GroupedListView(
          groupID: groupID,
          shoppingListID: shoppingListID,
          categories: categories,
          grouped: grouped,
        );
      },
      error: (e, st) => Center(child: Text(e.toString())),
      loading: () => _FlatShoppingListItems(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListItems: shoppingListItems,
      ),
    );
  }
}

/// カテゴリヘッダー付きのグルーピング表示
/// グルーピング表示時はドラッグ&ドロップを無効にする
class _GroupedListView extends StatelessWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupCategory> categories;
  final Map<String, List<GroupShoppingListItem>> grouped;

  const _GroupedListView({
    required this.groupID,
    required this.shoppingListID,
    required this.categories,
    required this.grouped,
  });

  @override
  Widget build(BuildContext context) {
    final categoryMap = {for (final c in categories) c.id: c};

    // カテゴリ順に表示（orderが小さいものから）
    final sortedCategoryIDs = categories.map((c) => c.id).toList();

    final List<Widget> children = [];

    for (final categoryID in sortedCategoryIDs) {
      final items = grouped[categoryID];
      if (items == null || items.isEmpty) continue;

      final category = categoryMap[categoryID]!;
      children.add(_CategoryHeader(
        categoryName: category.name,
        color: category.color,
        iconName: category.iconName,
      ));

      for (final item in items) {
        children.add(TextShoppingListItemWidget(
          key: ValueKey(item.id),
          groupID: groupID,
          textShoppingListItem: item,
          shoppingListItems: items,
        ));
      }
    }

    // 未分類アイテム
    final uncategorizedItems = grouped[uncategorizedCategoryID];
    if (uncategorizedItems != null && uncategorizedItems.isNotEmpty) {
      children.add(const _CategoryHeader(categoryName: '未分類'));

      for (final item in uncategorizedItems) {
        children.add(TextShoppingListItemWidget(
          key: ValueKey(item.id),
          groupID: groupID,
          textShoppingListItem: item,
          shoppingListItems: uncategorizedItems,
        ));
      }
    }

    return ListView(children: children);
  }
}

class _CategoryHeader extends StatelessWidget {
  final String categoryName;
  final String? color;
  final String? iconName;

  const _CategoryHeader({
    required this.categoryName,
    this.color,
    this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = color != null ? colorFromHex(color!) : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: categoryColor?.withValues(alpha: 0.1) ??
            colorScheme.surfaceContainerHighest,
        border: Border(
          left: categoryColor != null
              ? BorderSide(color: categoryColor, width: 4)
              : BorderSide.none,
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (iconName != null) ...[
            Icon(
              categoryIconFromName(iconName),
              size: 18,
              color: categoryColor ?? colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            categoryName,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: categoryColor ?? colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
