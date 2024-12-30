import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/memo_row.dart';

class LinkMemo extends StatelessWidget {
  final LinkMemoRow linkMemoRow;
  final List<MemoRow> memoRows;

  const LinkMemo({super.key, required this.linkMemoRow, required this.memoRows});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 100, height: 100, child: Image.network(linkMemoRow.metadataImageURL ?? '', fit: BoxFit.cover)),
        Text(linkMemoRow.metadataTitle ?? ''),
      ],
    );
  }
}
