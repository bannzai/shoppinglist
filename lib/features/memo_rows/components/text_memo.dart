import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/memo_row.dart';

class TextMemo extends StatelessWidget {
  final TextMemoRow textMemoRow;

  const TextMemo({super.key, required this.textMemoRow});

  @override
  Widget build(BuildContext context) {
    return Text(textMemoRow.message);
  }
}
