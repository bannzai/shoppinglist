import 'package:flutter/material.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';

class ShoppingListPreview extends StatelessWidget {
  const ShoppingListPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final currentShoppingListID = ValueNotifier<String?>(mockShoppingListID);
    return ShoppingListPage(
      groupID: mockGroupID,
      currentShoppingListID: currentShoppingListID,
      onGroupChanged: (_) {},
    );
  }
}
