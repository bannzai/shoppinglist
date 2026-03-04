import 'package:flutter/material.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';

class ShoppingListSettingPreview extends StatelessWidget {
  const ShoppingListSettingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ShoppingListSettingPage(
      groupID: mockGroupID,
      shoppingListID: mockShoppingListID,
      shoppingList: mockShoppingLists().first,
      onDelete: () => Navigator.pop(context),
    );
  }
}
