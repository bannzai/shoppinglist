import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';

class LinkShoppingListItemWidget extends StatelessWidget {
  final LinkShoppingListItem linkShoppingListItem;
  final List<ShoppingListItem> shoppingListItems;

  const LinkShoppingListItemWidget(
      {super.key,
      required this.linkShoppingListItem,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            height: 100,
            child: Image.network(
                linkShoppingListItem.metadataImageURL ?? '',
                fit: BoxFit.cover)),
        Text(linkShoppingListItem.metadataTitle ?? ''),
      ],
    );
  }
}
