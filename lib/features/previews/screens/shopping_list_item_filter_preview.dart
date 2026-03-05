import 'package:flutter/material.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/shopping_list_item_filter/page.dart';

class ShoppingListItemFilterPreview extends StatelessWidget {
  const ShoppingListItemFilterPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final showChecked = ValueNotifier<bool>(true);
    final sortByCategory = ValueNotifier<bool>(true);
    return ShoppingListItemFilterPage(
      groupID: mockGroupID,
      shoppingListID: mockShoppingListID,
      showChecked: showChecked,
      sortByCategory: sortByCategory,
    );
  }
}
