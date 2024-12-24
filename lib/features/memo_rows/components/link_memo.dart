import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/memo_row.dart';

class LinkMemo extends StatelessWidget {
  final LinkMemoRow linkMemoRow;
  final ValueNotifier<List<MemoRow>> memoRows;

  const LinkMemo({super.key, required this.linkMemoRow, required this.memoRows});

  @override
  Widget build(BuildContext context) {
    return Text(linkMemoRow.url);
  }
}
