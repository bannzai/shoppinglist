import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/features/group_category/category_edit_page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/category_presets.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

class GroupCategoryPage extends ConsumerWidget {
  final String groupID;

  const GroupCategoryPage({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final axesAsync = ref.watch(groupCategoryAxesProvider(groupID: groupID));

    return axesAsync.when(
      data: (axes) {
        if (axes.isEmpty) {
          return _CategoryScaffold(
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  analytics.logEvent(
                      name: 'tap_add_first_category',
                      parameters: {'groupID': groupID});
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
      error: (e, st) =>
          _CategoryScaffold(child: Center(child: Text(e.toString()))),
      loading: () => const _CategoryScaffold(
          child: Center(child: CircularProgressIndicator())),
    );
  }

  void _addCategoryWithAutoAxis({
    required BuildContext context,
    required WidgetRef ref,
    required List<GroupCategoryAxis> existingAxes,
  }) async {
    // Axisがなければ自動作成
    GroupCategoryAxis axis;
    if (existingAxes.isEmpty) {
      final userID = ref.read(userDatabaseProvider).userID;
      axis = await ref
          .read(groupCategoryAxisAddProvider(groupID: groupID))
          .call(groupID: groupID, userID: userID, name: 'デフォルト', order: 0);
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
              if (name.isEmpty) {
                return;
              }
              analytics.logEvent(
                  name: 'tap_confirm_add_category',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
              try {
                final userID = ref.read(userDatabaseProvider).userID;
                final category = await ref
                    .read(groupCategoryAddProvider(groupID: groupID))
                    .call(
                      groupID: groupID,
                      userID: userID,
                      categoryAxisID: categoryAxisID,
                      name: name,
                      order: 0,
                    );
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCategoryEditPage(
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
              analytics.logEvent(
                  name: 'cancel_add_category',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

/// カテゴリ画面用の paper bg Scaffold（loading/error/empty 用）。
class _CategoryScaffold extends StatelessWidget {
  final Widget child;
  const _CategoryScaffold({required this.child});
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('カテゴリ'),
        backgroundColor: tokens.neutral.paper,
      ),
      body: child,
    );
  }
}

class _CategoryListBody extends HookConsumerWidget {
  final String groupID;
  final GroupCategoryAxis axis;
  final List<GroupCategoryAxis> axes;

  const _CategoryListBody({
    required this.groupID,
    required this.axis,
    required this.axes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(
        groupCategoriesProvider(groupID: groupID, categoryAxisID: axis.id));
    final locationsAsync =
        ref.watch(shoppingLocationsProvider(groupID: groupID));
    final selectedLocationID = useState<String?>(null);
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    final tokens = context.tokens;
    return categoriesAsync.when(
      data: (categories) => Scaffold(
        backgroundColor: tokens.neutral.paper,
        appBar: AppBar(
          title: const Text('カテゴリ'),
          backgroundColor: tokens.neutral.paper,
        ),
        body: categories.isEmpty
            ? const Center(child: Text('カテゴリがまだありません'))
            : Column(
                children: [
                  // ロケーション選択ドロップダウン
                  locationsAsync.when(
                    data: (locations) {
                      if (locations.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: DropdownButtonFormField<String?>(
                          initialValue: selectedLocationID.value,
                          decoration: InputDecoration(
                            labelText: '買い物する場所の並び順',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            suffixIcon: !isPremium
                                ? Icon(Icons.lock,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)
                                : null,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('デフォルト'),
                            ),
                            ...locations.map(
                              (location) => DropdownMenuItem<String?>(
                                value: location.id,
                                child: Text(location.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            analytics.logEvent(
                              name: 'select_category_location_order',
                              parameters: {'groupID': groupID},
                            );
                            if (value != null && !isPremium) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('買い物場所ごとのカテゴリ並び替えはプレミアム機能です'),
                                  action: SnackBarAction(
                                    label: 'アップグレード',
                                    onPressed: () =>
                                        showPaywall(context: context),
                                  ),
                                ),
                              );
                              return;
                            }
                            selectedLocationID.value = value;
                          },
                        ),
                      );
                    },
                    error: (e, st) => const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: _CategoryReorderableList(
                      groupID: groupID,
                      categoryAxisID: axis.id,
                      categories: categories,
                      selectedShoppingLocationID: selectedLocationID.value,
                      isPremium: isPremium,
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            analytics.logEvent(
                name: 'tap_add_category', parameters: {'groupID': groupID});
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
      error: (e, st) =>
          _CategoryScaffold(child: Center(child: Text(e.toString()))),
      loading: () => const _CategoryScaffold(
          child: Center(child: CircularProgressIndicator())),
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
              if (name.isEmpty) {
                return;
              }
              analytics.logEvent(
                  name: 'tap_confirm_add_category',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
              try {
                final userID = ref.read(userDatabaseProvider).userID;
                final category = await ref
                    .read(groupCategoryAddProvider(groupID: groupID))
                    .call(
                      groupID: groupID,
                      userID: userID,
                      categoryAxisID: categoryAxisID,
                      name: name,
                      order: currentCategoryCount,
                    );
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCategoryEditPage(
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
              analytics.logEvent(
                  name: 'cancel_add_category',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

class _CategoryReorderableList extends ConsumerWidget {
  final String groupID;
  final String categoryAxisID;
  final List<GroupCategory> categories;
  final String? selectedShoppingLocationID;
  final bool isPremium;

  const _CategoryReorderableList({
    required this.groupID,
    required this.categoryAxisID,
    required this.categories,
    required this.selectedShoppingLocationID,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ロケーション別にソートしたカテゴリリストを表示
    final sortedCategories = sortCategoriesByLocation(
      categories: categories,
      shoppingLocationID: selectedShoppingLocationID,
    );

    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        analytics.logEvent(
            name: 'reorder_category', parameters: {'groupID': groupID});
        if (selectedShoppingLocationID != null) {
          if (!isPremium) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('買い物場所ごとのカテゴリ並び替えはプレミアム機能です'),
                action: SnackBarAction(
                  label: 'アップグレード',
                  onPressed: () => showPaywall(context: context),
                ),
              ),
            );
            return;
          }
        }
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final reordered = [...sortedCategories];
        final movedItem = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, movedItem);

        if (selectedShoppingLocationID == null) {
          // デフォルト順序の更新（既存のorderフィールド）
          final orderedCategories = reordered
              .asMap()
              .entries
              .map((entry) => entry.value.copyWith(order: entry.key))
              .toList();

          ref.read(groupCategoryBatchUpdateProvider(groupID: groupID)).call(
                categoryAxisID: categoryAxisID,
                categories: orderedCategories,
              );
        } else {
          // ロケーション別順序の更新（locationOrdersマップ）
          final orderedCategories = reordered.asMap().entries.map((entry) {
            final updatedLocationOrders =
                Map<String, int>.from(entry.value.locationOrders);
            updatedLocationOrders[selectedShoppingLocationID!] = entry.key;
            return entry.value.copyWith(locationOrders: updatedLocationOrders);
          }).toList();

          ref.read(groupCategoryBatchUpdateProvider(groupID: groupID)).call(
                categoryAxisID: categoryAxisID,
                categories: orderedCategories,
              );
        }
      },
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryColor =
            category.color != null ? colorFromHex(category.color!) : null;
        return ListTile(
          key: ValueKey(category.id),
          leading: Icon(
            categoryIconFromName(category.iconName),
            color: categoryColor,
          ),
          title: Text(category.name),
          subtitle: Text('キーワード: ${category.keywords.length}件'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  analytics.logEvent(name: 'tap_edit_category', parameters: {
                    'groupID': groupID,
                    'categoryID': category.id
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCategoryEditPage(
                        groupID: groupID,
                        categoryAxisID: categoryAxisID,
                        categoryID: category.id,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: context.tokens.neutral.danger),
                onPressed: () {
                  analytics.logEvent(name: 'tap_delete_category', parameters: {
                    'groupID': groupID,
                    'categoryID': category.id
                  });
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
    required GroupCategory category,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('「${category.name}」を削除しますか？'),
        content: const Text('このカテゴリに設定されたキーワードも削除されます'),
        actions: [
          TextButton(
            onPressed: () async {
              analytics.logEvent(
                  name: 'tap_confirm_del_category',
                  parameters: {'groupID': groupID, 'categoryID': category.id});
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(groupCategoryDeleteProvider(groupID: groupID))
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
            child: Text(
              '削除',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.tokens.neutral.danger),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_del_category',
                  parameters: {'groupID': groupID, 'categoryID': category.id});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
