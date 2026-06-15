import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/category_presets.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/hooks/use_on_disappear.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupCategoryEditPage extends ConsumerWidget {
  final String groupID;
  final String categoryAxisID;
  final String categoryID;

  const GroupCategoryEditPage({
    super.key,
    required this.groupID,
    required this.categoryAxisID,
    required this.categoryID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupCategoriesProvider(
        groupID: groupID, categoryAxisID: categoryAxisID));

    return categoriesAsync.when(
      data: (categories) {
        final category =
            categories.where((c) => c.id == categoryID).firstOrNull;
        if (category == null) {
          return _EditScaffold(
            child: const Center(child: Text('カテゴリが見つかりません')),
          );
        }
        return _CategoryEditBody(
          groupID: groupID,
          categoryAxisID: categoryAxisID,
          category: category,
        );
      },
      error: (e, st) => _EditScaffold(child: Center(child: Text(e.toString()))),
      loading: () => const _EditScaffold(
          child: Center(child: CircularProgressIndicator())),
    );
  }
}

/// カテゴリ編集画面の loading/error/not-found 用 paper bg Scaffold。
class _EditScaffold extends StatelessWidget {
  final Widget child;
  const _EditScaffold({required this.child});
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('カテゴリ編集'),
        backgroundColor: tokens.neutral.paper,
      ),
      body: child,
    );
  }
}

class _CategoryEditBody extends HookConsumerWidget {
  final String groupID;
  final String categoryAxisID;
  final GroupCategory category;

  const _CategoryEditBody({
    required this.groupID,
    required this.categoryAxisID,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: category.name);

    // disappear 時に未保存のカテゴリ名を保存するための更新オブジェクトを build 時にキャプチャする。
    // useOnDisappear の closure は Widget unmount 後にも呼ばれ ref を使えないため、ここで掴む。
    final update = ref.watch(groupCategoryUpdateProvider(groupID: groupID));

    // 画面離脱・アプリの background 移行時に、未保存のカテゴリ名を保存する。
    // 名前以外(色/アイコン/キーワード)は操作時に即時保存されるため、ここでは名前のみ扱う。
    // category は毎 build 最新が closure に渡る(useOnDisappear が最新版を呼ぶ)ため、
    // copyWith(name:) は直近で永続化された色/アイコンを保持したまま名前だけ差し替える。
    useOnDisappear(() {
      final name = nameController.text.trim();
      if (name.isEmpty || name == category.name) {
        return;
      }
      analytics.logEvent(
        name: 'auto_save_category_name',
        parameters: {'groupID': groupID, 'categoryID': category.id},
      );
      unawaited(
        update.call(
          categoryAxisID: categoryAxisID,
          categoryID: category.id,
          category: category.copyWith(name: name),
        ),
      );
    });

    final tokens = context.appTheme;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('カテゴリ編集'),
        backgroundColor: tokens.neutral.paper,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('カテゴリ名',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'カテゴリ名を入力',
                  ),
                ),
                const SizedBox(height: 24),
                Text('カテゴリカラー',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _CategoryColorPicker(
                  selectedColor: category.color,
                  onColorSelected: (color) async {
                    analytics
                        .logEvent(name: 'select_category_color', parameters: {
                      'groupID': groupID,
                      'categoryID': category.id,
                    });
                    try {
                      await ref
                          .read(groupCategoryUpdateProvider(groupID: groupID))
                          .call(
                            categoryAxisID: categoryAxisID,
                            categoryID: category.id,
                            category: category.copyWith(color: color),
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                Text('カテゴリアイコン',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _CategoryIconPicker(
                  selectedIconName: category.iconName,
                  selectedColor: category.color,
                  onIconSelected: (iconName) async {
                    analytics
                        .logEvent(name: 'select_category_icon', parameters: {
                      'groupID': groupID,
                      'categoryID': category.id,
                    });
                    try {
                      await ref
                          .read(groupCategoryUpdateProvider(groupID: groupID))
                          .call(
                            categoryAxisID: categoryAxisID,
                            categoryID: category.id,
                            category: category.copyWith(iconName: iconName),
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('キーワード',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                      tooltip: 'キーワードを追加',
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
                if (kDebugMode && category.locationOrders.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '[DEBUG] locationOrders: ${category.locationOrders}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.appTheme.neutral.ink3,
                          fontFamily: 'monospace',
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (category.keywords.isEmpty)
                  Text('キーワードがまだありません',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey))
                else
                  ...category.keywords.asMap().entries.map((entry) {
                    final index = entry.key;
                    final keyword = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(keyword.keyword),
                      subtitle: Text(
                        switch (keyword.matchingType) {
                          GroupCategoryKeywordMatchingType.exact => '完全一致',
                          GroupCategoryKeywordMatchingType.partial => '部分一致',
                          GroupCategoryKeywordMatchingType.regex => '正規表現',
                        },
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: context.appTheme.neutral.danger),
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
    var selectedMatchingType = GroupCategoryKeywordMatchingType.partial;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('キーワードを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: keywordController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'キーワードを入力',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'マッチング',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              // 部分一致/完全一致/正規表現は排他的な3択なので、関連選択肢を
              // 1コントロールにまとめた SegmentedButton で均等配置する。
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<GroupCategoryKeywordMatchingType>(
                  segments: const [
                    ButtonSegment(
                      value: GroupCategoryKeywordMatchingType.partial,
                      label: Text('部分一致'),
                    ),
                    ButtonSegment(
                      value: GroupCategoryKeywordMatchingType.exact,
                      label: Text('完全一致'),
                    ),
                    ButtonSegment(
                      value: GroupCategoryKeywordMatchingType.regex,
                      label: Text('正規表現'),
                    ),
                  ],
                  selected: {selectedMatchingType},
                  showSelectedIcon: false,
                  onSelectionChanged: (selected) {
                    final matchingType = selected.first;
                    analytics.logEvent(
                      name: switch (matchingType) {
                        GroupCategoryKeywordMatchingType.partial =>
                          'select_match_partial',
                        GroupCategoryKeywordMatchingType.exact =>
                          'select_match_exact',
                        GroupCategoryKeywordMatchingType.regex =>
                          'select_match_regex',
                      },
                      parameters: {
                        'groupID': groupID,
                        'categoryID': category.id,
                      },
                    );
                    setState(() {
                      selectedMatchingType = matchingType;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final keyword = keywordController.text.trim();
                if (keyword.isEmpty) {
                  return;
                }
                analytics.logEvent(
                    name: 'tap_confirm_add_keyword',
                    parameters: {
                      'groupID': groupID,
                      'categoryID': category.id
                    });
                Navigator.pop(dialogContext);

                final newKeyword = GroupCategoryKeyword(
                  keyword: keyword,
                  matchingType: selectedMatchingType,
                );
                final updatedCategory = category.copyWith(
                  keywords: [...category.keywords, newKeyword],
                );

                try {
                  await ref
                      .read(groupCategoryUpdateProvider(groupID: groupID))
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
      await ref.read(groupCategoryUpdateProvider(groupID: groupID)).call(
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

class _CategoryColorPicker extends StatelessWidget {
  final String? selectedColor;
  final void Function(String?) onColorSelected;

  const _CategoryColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // 色なしオプション
        GestureDetector(
          onTap: () => onColorSelected(null),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == null
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: selectedColor == null ? 3 : 1,
              ),
            ),
            child: Icon(Icons.block,
                size: 20, color: colorScheme.onSurfaceVariant),
          ),
        ),
        ...categoryPresetColors.map((hex) {
          final isSelected = selectedColor == hex;
          final color = colorFromHex(hex);
          return GestureDetector(
            onTap: () => onColorSelected(hex),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 3)
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _CategoryIconPicker extends StatelessWidget {
  final String? selectedIconName;
  final String? selectedColor;
  final void Function(String?) onIconSelected;

  const _CategoryIconPicker({
    required this.selectedIconName,
    required this.selectedColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor =
        selectedColor != null ? colorFromHex(selectedColor!) : null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // アイコンなしオプション
        GestureDetector(
          onTap: () => onIconSelected(null),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedIconName == null
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: selectedIconName == null ? 2 : 1,
              ),
            ),
            child: Icon(Icons.block,
                size: 20, color: colorScheme.onSurfaceVariant),
          ),
        ),
        ...categoryIconMap.entries.map((entry) {
          final isSelected = selectedIconName == entry.key;
          return GestureDetector(
            onTap: () => onIconSelected(entry.key),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? (accentColor ?? colorScheme.primary)
                        .withValues(alpha: 0.15)
                    : null,
                border: Border.all(
                  color: isSelected
                      ? (accentColor ?? colorScheme.primary)
                      : colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                entry.value,
                size: 24,
                color: isSelected
                    ? (accentColor ?? colorScheme.primary)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }),
      ],
    );
  }
}
