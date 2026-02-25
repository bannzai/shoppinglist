import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/group_shopping_list_item_category.dart';

class ShoppingListItemFilterPage extends HookConsumerWidget {
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
    final axesAsync =
        ref.watch(groupShoppingListItemCategoryAxesProvider(groupID: groupID));
    final showChecked = useState(this.showChecked.value);
    final sortByCategory = useState(this.sortByCategory.value);
    final hasCategories = axesAsync.maybeWhen(
        data: (axes) => axes.isNotEmpty, orElse: () => false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('フィルター'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: 32.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text('チェック済みを表示する'),
                    value: showChecked.value,
                    onChanged: (value) {
                      showChecked.value = value;
                    },
                  ),
                  SwitchListTile(
                    title: const Text('カテゴリ順で表示する'),
                    value: sortByCategory.value,
                    onChanged: hasCategories
                        ? (value) {
                            sortByCategory.value = value;
                          }
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.showChecked.value = showChecked.value;
                  this.sortByCategory.value = sortByCategory.value;
                },
                child: const Text('適用'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
