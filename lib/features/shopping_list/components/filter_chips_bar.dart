import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_chip.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 買い物リストの絞り込みチップ群（高さ 44）。
/// `design_handoff_shopping_list/source/screens-list.jsx#FilterChips` 相当。
/// 「チェック済み表示」「カテゴリ順」の 2 チップを左寄せで並べる。
/// カテゴリ未定義時は「カテゴリ順」を disabled にする。
class FilterChipsBar extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> sortByCategory;

  const FilterChipsBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.showChecked,
    required this.sortByCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCategories = ref
        .watch(groupCategoryAxesProvider(groupID: groupID))
        .maybeWhen(data: (axes) => axes.isNotEmpty, orElse: () => false);

    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AppChip(
                label: showChecked.value ? 'チェック済み表示' : 'チェック済み非表示',
                icon: Icons.check,
                soft: true,
                active: !showChecked.value,
                onTap: () {
                  final next = !showChecked.value;
                  analytics.logEvent(
                    name: 'toggle_show_checked',
                    parameters: {
                      'groupID': groupID,
                      'shoppingListID': shoppingListID,
                      'value': next.toString(),
                    },
                  );
                  showChecked.value = next;
                },
                dotColor: null),
            const SizedBox(width: 6),
            AppChip(
                label: sortByCategory.value ? 'カテゴリ順' : 'リスト順',
                icon: Icons.sell_outlined,
                soft: true,
                active: sortByCategory.value,
                onTap: hasCategories
                    ? () {
                        final next = !sortByCategory.value;
                        analytics.logEvent(
                          name: 'toggle_sort_by_category',
                          parameters: {
                            'groupID': groupID,
                            'shoppingListID': shoppingListID,
                            'value': next.toString(),
                          },
                        );
                        sortByCategory.value = next;
                      }
                    : null,
                dotColor: null),
          ],
        ),
      ),
    );
  }
}
