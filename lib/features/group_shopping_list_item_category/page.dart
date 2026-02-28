import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category_axis.dart';
import 'package:shoppinglist/features/group_shopping_list_item_category/category_edit_page.dart';
import 'package:shoppinglist/provider/group_shopping_list_item_category.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupShoppingListItemCategoryPage extends HookConsumerWidget {
  final String groupID;

  const GroupShoppingListItemCategoryPage({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final axesAsync =
        ref.watch(groupShoppingListItemCategoryAxesProvider(groupID: groupID));

    return axesAsync.when(
      data: (axes) {
        if (axes.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('カテゴリ')),
            body: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  analytics.logEvent(name: 'tap_add_first_category', parameters: {'groupID': groupID});
                  _addCategoryWithAutoAxis(
                    context: context,
                    ref: ref,
                    existingAxes: axes,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('カテゴリを追加'),
              ),
            ),
          );
        }

        // 最初の軸のカテゴリを表示
        final axis = axes.first;
        return _CategoryListBody(
          groupID: groupID,
          axis: axis,
          axes: axes,
        );
      },
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ')),
        body: Center(child: Text(e.toString())),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _addCategoryWithAutoAxis({
    required BuildContext context,
    required WidgetRef ref,
    required List<GroupShoppingListItemCategoryAxis> existingAxes,
  }) async {
    // Axisがなければ自動作成
    GroupShoppingListItemCategoryAxis axis;
    if (existingAxes.isEmpty) {
      axis = await ref
          .read(groupShoppingListItemCategoryAxisAddProvider(groupID: groupID))
          .call(groupID: groupID, name: 'デフォルト', order: 0);
    } else {
      axis = existingAxes.first;
    }

    if (context.mounted) {
      _showAddCategoryDialog(
        context: context,
        ref: ref,
        categoryAxisID: axis.id,
      );
    }
  }

  void _showAddCategoryDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String categoryAxisID,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('カテゴリを追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'カテゴリ名（例: 野菜）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              analytics.logEvent(name: 'tap_confirm_add_category', parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
              try {
                final category = await ref
                    .read(groupShoppingListItemCategoryAddProvider(
                        groupID: groupID))
                    .call(
                      groupID: groupID,
                      categoryAxisID: categoryAxisID,
                      name: name,
                      order: 0,
                    );
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupShoppingListItemCategoryEditPage(
                        groupID: groupID,
                        categoryAxisID: categoryAxisID,
                        categoryID: category.id,
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
            child: const Text('追加'),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(name: 'cancel_add_category', parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

class _CategoryListBody extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingListItemCategoryAxis axis;
  final List<GroupShoppingListItemCategoryAxis> axes;

  const _CategoryListBody({
    required this.groupID,
    required this.axis,
    required this.axes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupShoppingListItemCategoriesProvider(
        groupID: groupID, categoryAxisID: axis.id));

    return categoriesAsync.when(
      data: (categories) => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ')),
        body: categories.isEmpty
            ? const Center(child: Text('カテゴリがまだありません'))
            : _CategoryReorderableList(
                groupID: groupID,
                categoryAxisID: axis.id,
                categories: categories,
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            analytics.logEvent(name: 'tap_add_category', parameters: {'groupID': groupID});
            _showAddCategoryDialog(
              context: context,
              ref: ref,
              categoryAxisID: axis.id,
              currentCategoryCount: categories.length,
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ')),
        body: Center(child: Text(e.toString())),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showAddCategoryDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String categoryAxisID,
    required int currentCategoryCount,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('カテゴリを追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'カテゴリ名（例: 野菜）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              analytics.logEvent(name: 'tap_confirm_add_category', parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
              try {
                final category = await ref
                    .read(groupShoppingListItemCategoryAddProvider(
                        groupID: groupID))
                    .call(
                      groupID: groupID,
                      categoryAxisID: categoryAxisID,
                      name: name,
                      order: currentCategoryCount,
                    );
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupShoppingListItemCategoryEditPage(
                        groupID: groupID,
                        categoryAxisID: categoryAxisID,
                        categoryID: category.id,
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
            child: const Text('追加'),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(name: 'cancel_add_category', parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

class _CategoryReorderableList extends HookConsumerWidget {
  final String groupID;
  final String categoryAxisID;
  final List<GroupShoppingListItemCategory> categories;

  const _CategoryReorderableList({
    required this.groupID,
    required this.categoryAxisID,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        analytics.logEvent(name: 'reorder_category', parameters: {'groupID': groupID});
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final reordered = [...categories];
        final movedItem = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, movedItem);

        final orderedCategories = reordered
            .asMap()
            .entries
            .map((entry) => entry.value.copyWith(order: entry.key))
            .toList();

        ref
            .read(groupShoppingListItemCategoryBatchUpdateProvider(
                groupID: groupID))
            .call(
              categoryAxisID: categoryAxisID,
              categories: orderedCategories,
            );
      },
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          key: ValueKey(category.id),
          leading: const Icon(Icons.category),
          title: Text(category.name),
          subtitle: Text('キーワード: ${category.keywords.length}件'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  analytics.logEvent(name: 'tap_edit_category', parameters: {'groupID': groupID, 'categoryID': category.id});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupShoppingListItemCategoryEditPage(
                        groupID: groupID,
                        categoryAxisID: categoryAxisID,
                        categoryID: category.id,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: TextColor.danger),
                onPressed: () {
                  analytics.logEvent(name: 'tap_delete_category', parameters: {'groupID': groupID, 'categoryID': category.id});
                  _showDeleteDialog(
                    context: context,
                    ref: ref,
                    category: category,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupShoppingListItemCategory category,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('「${category.name}」を削除しますか？'),
        content: const Text('このカテゴリに設定されたキーワードも削除されます'),
        actions: [
          TextButton(
            onPressed: () async {
              analytics.logEvent(name: 'tap_confirm_del_category', parameters: {'groupID': groupID, 'categoryID': category.id});
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(groupShoppingListItemCategoryDeleteProvider(
                        groupID: groupID))
                    .call(
                      categoryAxisID: categoryAxisID,
                      categoryID: category.id,
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text(
              '削除',
              style: TextStyle(color: TextColor.danger),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(name: 'cancel_del_category', parameters: {'groupID': groupID, 'categoryID': category.id});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
