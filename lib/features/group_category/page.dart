import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/error_view.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/group_category/category_empty_state.dart';
import 'package:shoppinglist/features/group_category_edit/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/category_presets.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

class GroupCategoryPage extends ConsumerWidget {
  final String groupID;

  /// 非nullのとき「カテゴリ選択モード」。指定アイテムを既存カテゴリへ
  /// 割り当てる目的で開かれており、行タップでアイテム名をそのカテゴリの
  /// キーワードに追記してpopする。nullのときは従来どおり閲覧・管理のみ。
  final GroupShoppingListItem? selectionForItem;

  const GroupCategoryPage({
    super.key,
    required this.groupID,
    this.selectionForItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final axesAsync = ref.watch(groupCategoryAxesProvider(groupID: groupID));
    final currentUserID = ref.watch(currentUserIDProvider);
    final groupCategoryAxisAdd = ref.watch(
      groupCategoryAxisAddProvider(groupID: groupID),
    );
    final groupCategoryAdd = ref.watch(
      groupCategoryAddProvider(groupID: groupID),
    );
    final title = selectionForItem != null ? 'カテゴリを選択' : 'カテゴリ';

    // ログアウト・ユーザー切替直後は uid が null になる。このページが Navigator 上に
    // 残ったまま追加操作されると null 例外で落ちるため、uid が取れるまで
    // ローディング表示にして操作させない。
    if (currentUserID == null) {
      return _CategoryScaffold(
        title: title,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return axesAsync.when(
      data: (axes) {
        if (axes.isEmpty) {
          return _CategoryScaffold(
            title: title,
            child: CategoryEmptyState(
              onAddCategory: () {
                analytics.logEvent(
                  name: 'tap_add_first_category',
                  parameters: {'groupID': groupID},
                );
                _addCategoryWithAutoAxis(
                  context: context,
                  userID: currentUserID,
                  groupCategoryAxisAdd: groupCategoryAxisAdd,
                  groupCategoryAdd: groupCategoryAdd,
                  existingAxes: axes,
                );
              },
            ),
          );
        }

        // 最初の軸のカテゴリを表示
        final axis = axes.first;
        return _CategoryListBody(
          groupID: groupID,
          axis: axis,
          axes: axes,
          selectionForItem: selectionForItem,
        );
      },
      error:
          (e, st) => _CategoryScaffold(
            title: title,
            child: ErrorView(error: e, stackTrace: st),
          ),
      loading:
          () => _CategoryScaffold(
            title: title,
            child: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _addCategoryWithAutoAxis({
    required BuildContext context,
    required String userID,
    required GroupCategoryAxisAdd groupCategoryAxisAdd,
    required GroupCategoryAdd groupCategoryAdd,
    required List<GroupCategoryAxis> existingAxes,
  }) async {
    // Axisがなければ自動作成
    GroupCategoryAxis axis;
    if (existingAxes.isEmpty) {
      axis = await groupCategoryAxisAdd.call(
        groupID: groupID,
        userID: userID,
        name: 'デフォルト',
        order: 0,
      );
    } else {
      axis = existingAxes.first;
    }

    if (context.mounted) {
      await _addCategoryAndNavigateToEdit(
        context: context,
        groupCategoryAdd: groupCategoryAdd,
        userID: userID,
        groupID: groupID,
        categoryAxisID: axis.id,
        order: 0,
      );
    }
  }
}

/// カテゴリを空名で即座に作成し、編集画面へ遷移する。
///
/// カテゴリ追加時に名前入力ダイアログを挟まず、編集画面の TextField で
/// 名前・色・アイコン・キーワードをまとめて設定させる。作成直後は name が空のため、
/// 編集画面の TextField には hint（カテゴリ名を入力）のみが表示される。
Future<void> _addCategoryAndNavigateToEdit({
  required BuildContext context,
  required GroupCategoryAdd groupCategoryAdd,
  required String userID,
  required String groupID,
  required String categoryAxisID,
  required int order,
}) async {
  try {
    final category = await groupCategoryAdd.call(
      groupID: groupID,
      userID: userID,
      categoryAxisID: categoryAxisID,
      name: '',
      order: order,
    );
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GroupCategoryEditPage(
                groupID: groupID,
                categoryAxisID: categoryAxisID,
                categoryID: category.id,
              ),
        ),
      );
    }
  } catch (e, st) {
    if (context.mounted) {
      showErrorSnackBar(context, e, st);
    }
  }
}

/// カテゴリ画面用の paper bg Scaffold（loading/error/empty 用）。
class _CategoryScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  const _CategoryScaffold({required this.child, this.title = 'カテゴリ'});
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(title: Text(title), backgroundColor: tokens.neutral.paper),
      body: child,
    );
  }
}

class _CategoryListBody extends HookConsumerWidget {
  final String groupID;
  final GroupCategoryAxis axis;
  final List<GroupCategoryAxis> axes;
  final GroupShoppingListItem? selectionForItem;

  const _CategoryListBody({
    required this.groupID,
    required this.axis,
    required this.axes,
    required this.selectionForItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(
      groupCategoriesProvider(groupID: groupID, categoryAxisID: axis.id),
    );
    // 店舗ごとの並び順はファーストリリースでは非表示 (issue #465)。
    // flag が false の間は provider を watch せず、Firestore への不要なクエリを発生させない。
    // 条件はコンパイル時定数のため、rebuild 間で watch の有無が変わることはない。
    final locationsAsync =
        shoppingLocationFeatureEnabled
            ? ref.watch(shoppingLocationsProvider(groupID: groupID))
            : const AsyncValue<List<GroupShoppingLocation>>.data([]);
    final selectedLocationID = useState<String?>(null);
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final currentUserID = ref.watch(currentUserIDProvider);
    final groupCategoryAdd = ref.watch(
      groupCategoryAddProvider(groupID: groupID),
    );

    // ログアウト・ユーザー切替直後の uid=null の間に FAB から追加操作されると
    // null 例外で落ちるため、uid が取れるまでローディング表示にして操作させない。
    // hook (useState) の後に置くことで build 間の hook 呼び出し順を変えない。
    if (currentUserID == null) {
      return _CategoryScaffold(
        title: selectionForItem != null ? 'カテゴリを選択' : 'カテゴリ',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final tokens = context.appTheme;
    return categoriesAsync.when(
      data:
          (categories) => Scaffold(
            backgroundColor: tokens.neutral.paper,
            appBar: AppBar(
              title: Text(selectionForItem != null ? 'カテゴリを選択' : 'カテゴリ'),
              backgroundColor: tokens.neutral.paper,
            ),
            // カテゴリ0件時も価値訴求カードを表示する。追加導線は Scaffold の
            // FloatingActionButton が担うため onAddCategory は null（カード内ボタンは出さない）。
            body:
                categories.isEmpty
                    ? const CategoryEmptyState(onAddCategory: null)
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
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: DropdownButtonFormField<String?>(
                                initialValue: selectedLocationID.value,
                                decoration: InputDecoration(
                                  labelText: '買い物する場所の並び順',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  suffixIcon:
                                      !isPremium
                                          ? Icon(
                                            Icons.lock,
                                            size: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          )
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
                                        persist: false,
                                        content: const Text(
                                          '買い物場所ごとのカテゴリ並び替えはプレミアム機能です',
                                        ),
                                        action: SnackBarAction(
                                          label: 'アップグレード',
                                          onPressed:
                                              () =>
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
                            selectedShoppingLocationID:
                                selectedLocationID.value,
                            isPremium: isPremium,
                            selectionForItem: selectionForItem,
                          ),
                        ),
                      ],
                    ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                analytics.logEvent(
                  name: 'tap_add_category',
                  parameters: {'groupID': groupID},
                );
                _addCategoryAndNavigateToEdit(
                  context: context,
                  groupCategoryAdd: groupCategoryAdd,
                  userID: currentUserID,
                  groupID: groupID,
                  categoryAxisID: axis.id,
                  order: categories.length,
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
      error:
          (e, st) => _CategoryScaffold(
            title: selectionForItem != null ? 'カテゴリを選択' : 'カテゴリ',
            child: ErrorView(error: e, stackTrace: st),
          ),
      loading:
          () => _CategoryScaffold(
            title: selectionForItem != null ? 'カテゴリを選択' : 'カテゴリ',
            child: const Center(child: CircularProgressIndicator()),
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
  final GroupShoppingListItem? selectionForItem;

  const _CategoryReorderableList({
    required this.groupID,
    required this.categoryAxisID,
    required this.categories,
    required this.selectedShoppingLocationID,
    required this.isPremium,
    required this.selectionForItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupCategoryBatchUpdate = ref.watch(
      groupCategoryBatchUpdateProvider(groupID: groupID),
    );
    final moveItemCategoryKeyword = ref.watch(
      moveItemCategoryKeywordProvider(groupID: groupID),
    );
    final groupCategoryDelete = ref.watch(
      groupCategoryDeleteProvider(groupID: groupID),
    );
    // ロケーション別にソートしたカテゴリリストを表示
    final sortedCategories = sortCategoriesByLocation(
      categories: categories,
      shoppingLocationID: selectedShoppingLocationID,
    );

    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        analytics.logEvent(
          name: 'reorder_category',
          parameters: {'groupID': groupID},
        );
        if (selectedShoppingLocationID != null) {
          if (!isPremium) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                persist: false,
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
          final orderedCategories =
              reordered
                  .asMap()
                  .entries
                  .map((entry) => entry.value.copyWith(order: entry.key))
                  .toList();

          groupCategoryBatchUpdate.call(
            categoryAxisID: categoryAxisID,
            categories: orderedCategories,
          );
        } else {
          // ロケーション別順序の更新（locationOrdersマップ）
          final orderedCategories =
              reordered.asMap().entries.map((entry) {
                final updatedLocationOrders = Map<String, int>.from(
                  entry.value.locationOrders,
                );
                updatedLocationOrders[selectedShoppingLocationID!] = entry.key;
                return entry.value.copyWith(
                  locationOrders: updatedLocationOrders,
                );
              }).toList();

          groupCategoryBatchUpdate.call(
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
          // 選択モード(selectionForItem != null)のときだけ行タップを有効化し、
          // アイテムを選んだカテゴリへ移してpopする。非選択モードでは null のままで、
          // 従来どおり編集/削除ボタンのみ反応する。
          onTap:
              selectionForItem == null
                  ? null
                  : () async {
                    analytics.logEvent(
                      name: 'select_category_for_item',
                      parameters: {
                        'groupID': groupID,
                        'categoryID': category.id,
                      },
                    );
                    try {
                      // アイテムはカテゴリIDを持たず message とキーワードのマッチで
                      // 分類されるため、「選んだカテゴリへ変更」は移動先へ完全一致
                      // キーワードを追加し、他カテゴリから同名の完全一致キーワードを
                      // 削除する(= カテゴリ間 D&D と同じ付け替え)。これにより既に別
                      // カテゴリへ分類済みのアイテムでも選んだカテゴリへ正しく移動する。
                      await moveItemCategoryKeyword.call(
                        categoryAxisID: categoryAxisID,
                        itemMessage: selectionForItem!.message,
                        destinationCategoryID: category.id,
                        categories: categories,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e, st) {
                      if (context.mounted) {
                        showErrorSnackBar(context, e, st);
                      }
                    }
                  },
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
                  analytics.logEvent(
                    name: 'tap_edit_category',
                    parameters: {'groupID': groupID, 'categoryID': category.id},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GroupCategoryEditPage(
                            groupID: groupID,
                            categoryAxisID: categoryAxisID,
                            categoryID: category.id,
                          ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: context.appTheme.neutral.danger,
                ),
                onPressed: () {
                  analytics.logEvent(
                    name: 'tap_delete_category',
                    parameters: {'groupID': groupID, 'categoryID': category.id},
                  );
                  _showDeleteDialog(
                    context: context,
                    groupCategoryDelete: groupCategoryDelete,
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
    required GroupCategoryDelete groupCategoryDelete,
    required GroupCategory category,
  }) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('「${category.name}」を削除しますか？'),
            content: const Text('このカテゴリに設定されたキーワードも削除されます'),
            actions: [
              TextButton(
                onPressed: () async {
                  analytics.logEvent(
                    name: 'tap_confirm_del_category',
                    parameters: {'groupID': groupID, 'categoryID': category.id},
                  );
                  Navigator.pop(dialogContext);
                  try {
                    await groupCategoryDelete.call(
                      categoryAxisID: categoryAxisID,
                      categoryID: category.id,
                    );
                  } catch (e, st) {
                    if (context.mounted) {
                      showErrorSnackBar(context, e, st);
                    }
                  }
                },
                child: Text(
                  '削除',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.neutral.danger,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  analytics.logEvent(
                    name: 'cancel_del_category',
                    parameters: {'groupID': groupID, 'categoryID': category.id},
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('キャンセル'),
              ),
            ],
          ),
    );
  }
}
