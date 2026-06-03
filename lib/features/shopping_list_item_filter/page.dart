import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_setting_section.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 表示の絞り込みページ。SwitchListTile 2 つの単純な構造。
/// `design_handoff_shopping_list/source/screens-list-settings.jsx#FilterPage` 相当。
/// カテゴリ未定義時は「カテゴリ順で表示」を disabled にする。
class ShoppingListItemFilterPage extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> sortByCategory;

  const ShoppingListItemFilterPage({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.showChecked,
    required this.sortByCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final hasCategories = ref
        .watch(groupCategoryAxesProvider(groupID: groupID))
        .maybeWhen(data: (axes) => axes.isNotEmpty, orElse: () => false);

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('フィルター'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            AppSettingSection(
              title: '表示',
              children: [
                SwitchListTile(
                  title: const Text('チェック済みを表示する'),
                  value: showChecked.value,
                  onChanged: (value) {
                    analytics.logEvent(
                      name: 'toggle_show_checked',
                      parameters: {
                        'groupID': groupID,
                        'shoppingListID': shoppingListID,
                        'value': value.toString(),
                      },
                    );
                    showChecked.value = value;
                  },
                ),
                SwitchListTile(
                  title: const Text('カテゴリ順で表示する'),
                  subtitle: hasCategories
                      ? null
                      : Text(
                          'カテゴリを 1 つ以上登録すると有効になります',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: neutral.ink3),
                        ),
                  value: sortByCategory.value,
                  onChanged: hasCategories
                      ? (value) {
                          analytics.logEvent(
                            name: 'toggle_sort_by_category',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID,
                              'value': value.toString(),
                            },
                          );
                          sortByCategory.value = value;
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'チェック済みを非表示にすると、買い物中のリストがコンパクトに見えます。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: neutral.ink3,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
