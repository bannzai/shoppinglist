import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/memo_row.dart';

class LinkMemo extends StatelessWidget {
  final LinkMemoRow linkMemoRow;

  const LinkMemo({super.key, required this.linkMemoRow});

  @override
  Widget build(BuildContext context) {
    return Text(linkMemoRow.url);
  }
}
