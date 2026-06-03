import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';

/// ShoppingListPage のプレビュー。
/// currentGroupID / currentShoppingListID は previewProviderOverrides で mock 値に
/// override されるため、ここでは引数なしで生成する。
class ShoppingListPreview extends StatelessWidget {
  const ShoppingListPreview({super.key});

  @override
  Widget build(BuildContext context) => const ShoppingListPage();
}
