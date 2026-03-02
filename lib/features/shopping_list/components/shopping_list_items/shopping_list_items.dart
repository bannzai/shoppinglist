import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/provider/group_shopping_list_item_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

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
    final axesAsync =
        ref.watch(groupShoppingListItemCategoryAxesProvider(groupID: groupID));

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
    final categoriesAsync = ref.watch(groupShoppingListItemCategoriesProvider(
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
  final List<GroupShoppingListItemCategory> categories;
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

      children.add(_CategoryHeader(
        categoryName: categoryMap[categoryID]!.name,
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

  const _CategoryHeader({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        categoryName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
