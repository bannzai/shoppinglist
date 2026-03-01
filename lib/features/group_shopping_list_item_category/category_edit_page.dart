import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category_keyword.dart';
import 'package:shoppinglist/provider/group_shopping_list_item_category.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupShoppingListItemCategoryEditPage extends ConsumerWidget {
  final String groupID;
  final String categoryAxisID;
  final String categoryID;

  const GroupShoppingListItemCategoryEditPage({
    super.key,
    required this.groupID,
    required this.categoryAxisID,
    required this.categoryID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupShoppingListItemCategoriesProvider(
        groupID: groupID, categoryAxisID: categoryAxisID));

    return categoriesAsync.when(
      data: (categories) {
        final category =
            categories.where((c) => c.id == categoryID).firstOrNull;
        if (category == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('カテゴリ編集')),
            body: const Center(child: Text('カテゴリが見つかりません')),
          );
        }
        return _CategoryEditBody(
          groupID: groupID,
          categoryAxisID: categoryAxisID,
          category: category,
        );
      },
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ編集')),
        body: Center(child: Text(e.toString())),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('カテゴリ編集')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _CategoryEditBody extends HookConsumerWidget {
  final String groupID;
  final String categoryAxisID;
  final GroupShoppingListItemCategory category;

  const _CategoryEditBody({
    required this.groupID,
    required this.categoryAxisID,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: category.name);
    final isSaving = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリ編集'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('カテゴリ名',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'カテゴリ名を入力',
                  ),
                  onSubmitted: (String value) async {
                    final name = value.trim();
                    if (name.isEmpty || name == category.name) return;
                    analytics.logEvent(
                        name: 'submit_category_name',
                        parameters: {
                          'groupID': groupID,
                          'categoryID': category.id
                        });
                    isSaving.value = true;
                    try {
                      await ref
                          .read(groupShoppingListItemCategoryUpdateProvider(
                              groupID: groupID))
                          .call(
                            categoryAxisID: categoryAxisID,
                            categoryID: category.id,
                            category: category.copyWith(name: name),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('保存しました')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      isSaving.value = false;
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('キーワード',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_add_keyword',
                            parameters: {
                              'groupID': groupID,
                              'categoryID': category.id
                            });
                        _showAddKeywordDialog(
                          context: context,
                          ref: ref,
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (category.keywords.isEmpty)
                  const Text('キーワードがまだありません',
                      style: TextStyle(color: Colors.grey))
                else
                  ...category.keywords.asMap().entries.map((entry) {
                    final index = entry.key;
                    final keyword = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(keyword.keyword),
                      subtitle: Text(
                        keyword.matchingType ==
                                GroupShoppingListItemCategoryKeywordMatchingType
                                    .exact
                            ? '完全一致'
                            : '部分一致',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: TextColor.danger),
                        onPressed: () => _deleteKeyword(
                          context: context,
                          ref: ref,
                          index: index,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddKeywordDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final keywordController = TextEditingController();
    var selectedMatchingType =
        GroupShoppingListItemCategoryKeywordMatchingType.partial;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('キーワードを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keywordController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'キーワードを入力',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('マッチング: '),
                  ChoiceChip(
                    label: const Text('部分一致'),
                    selected: selectedMatchingType ==
                        GroupShoppingListItemCategoryKeywordMatchingType
                            .partial,
                    onSelected: (selected) {
                      if (selected) {
                        analytics.logEvent(
                            name: 'select_match_partial',
                            parameters: {
                              'groupID': groupID,
                              'categoryID': category.id
                            });
                        setState(() {
                          selectedMatchingType =
                              GroupShoppingListItemCategoryKeywordMatchingType
                                  .partial;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('完全一致'),
                    selected: selectedMatchingType ==
                        GroupShoppingListItemCategoryKeywordMatchingType.exact,
                    onSelected: (selected) {
                      if (selected) {
                        analytics.logEvent(
                            name: 'select_match_exact',
                            parameters: {
                              'groupID': groupID,
                              'categoryID': category.id
                            });
                        setState(() {
                          selectedMatchingType =
                              GroupShoppingListItemCategoryKeywordMatchingType
                                  .exact;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final keyword = keywordController.text.trim();
                if (keyword.isEmpty) return;
                analytics.logEvent(
                    name: 'tap_confirm_add_keyword',
                    parameters: {
                      'groupID': groupID,
                      'categoryID': category.id
                    });
                Navigator.pop(dialogContext);

                final newKeyword = GroupShoppingListItemCategoryKeyword(
                  keyword: keyword,
                  matchingType: selectedMatchingType,
                );
                final updatedCategory = category.copyWith(
                  keywords: [...category.keywords, newKeyword],
                );

                try {
                  await ref
                      .read(groupShoppingListItemCategoryUpdateProvider(
                          groupID: groupID))
                      .call(
                        categoryAxisID: categoryAxisID,
                        categoryID: category.id,
                        category: updatedCategory,
                      );
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
                analytics.logEvent(name: 'cancel_add_keyword', parameters: {
                  'groupID': groupID,
                  'categoryID': category.id
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteKeyword({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
  }) async {
    analytics.logEvent(
        name: 'tap_delete_keyword',
        parameters: {'groupID': groupID, 'categoryID': category.id});
    final updatedKeywords = [...category.keywords]..removeAt(index);
    final updatedCategory = category.copyWith(keywords: updatedKeywords);

    try {
      await ref
          .read(groupShoppingListItemCategoryUpdateProvider(groupID: groupID))
          .call(
            categoryAxisID: categoryAxisID,
            categoryID: category.id,
            category: updatedCategory,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
