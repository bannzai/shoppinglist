import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_section_header.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

class ShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final bool sortByCategory;
  final String? shoppingLocationID;

  const ShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.sortByCategory,
    required this.shoppingLocationID,
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
          shoppingLocationID: shoppingLocationID,
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
      // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      onReorder: (oldIndex, newIndex) {
        // ドラッグ時にリストから要素を一時的に削除するため newIndex がずれるのを調整
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final changedItems = [...shoppingListItems];
        final movedItem = changedItems.removeAt(oldIndex);
        changedItems.insert(newIndex, movedItem);
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
  final String? shoppingLocationID;

  const _CategorizedShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.categoryAxisID,
    required this.shoppingLocationID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
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
          shoppingLocationID: isPremium ? shoppingLocationID : null,
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

/// カテゴリヘッダー付きのグルーピング表示。グルーピング表示時はドラッグ&ドロップを無効にする。
class _GroupedListView extends StatelessWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupCategory> categories;
  final Map<String, List<GroupShoppingListItem>> grouped;
  final String? shoppingLocationID;

  const _GroupedListView({
    required this.groupID,
    required this.shoppingListID,
    required this.categories,
    required this.grouped,
    required this.shoppingLocationID,
  });

  @override
  Widget build(BuildContext context) {
    final categoryMap = {for (final c in categories) c.id: c};
    final sortedCategories = sortCategoriesByLocation(
      categories: categories,
      shoppingLocationID: shoppingLocationID,
    );
    final sortedCategoryIDs = sortedCategories.map((c) => c.id).toList();

    final List<Widget> children = [];

    for (final categoryID in sortedCategoryIDs) {
      final items = grouped[categoryID];
      if (items == null || items.isEmpty) {
        continue;
      }

      final category = categoryMap[categoryID]!;
      final metrics = ShoppingListItemMetrics.fromItems(items);
      if (metrics.totalCount > 0) {
        children.add(CategorySectionHeader(
          name: category.name,
          colorHex: category.color,
          doneCount: metrics.checkedCount,
          totalCount: metrics.totalCount,
        ));
      }

      for (final item in items) {
        children.add(TextShoppingListItemWidget(
            key: ValueKey(item.id),
            groupID: groupID,
            textShoppingListItem: item,
            shoppingListItems: items,
            reorderIndex: null));
      }
    }

    final uncategorizedItems = grouped[uncategorizedCategoryID];
    if (uncategorizedItems != null && uncategorizedItems.isNotEmpty) {
      final metrics = ShoppingListItemMetrics.fromItems(uncategorizedItems);
      if (metrics.totalCount > 0) {
        children.add(CategorySectionHeader(
          name: '未分類',
          colorHex: null,
          doneCount: metrics.checkedCount,
          totalCount: metrics.totalCount,
        ));
      }
      for (final item in uncategorizedItems) {
        children.add(TextShoppingListItemWidget(
            key: ValueKey(item.id),
            groupID: groupID,
            textShoppingListItem: item,
            shoppingListItems: uncategorizedItems,
            reorderIndex: null));
      }
    }

    return ListView(
      // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: children,
    );
  }
}
