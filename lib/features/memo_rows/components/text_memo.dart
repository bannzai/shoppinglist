import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/memo_row.dart';

class TextMemo extends StatelessWidget {
  final TextMemoRow textMemoRow;

  const TextMemo({super.key, required this.textMemoRow});

  @override
  Widget build(BuildContext context) {
    final createdDateTime = textMemoRow.createdDateTime;
    return Row(
      children: [
        Column(
          children: [
            Text(textMemoRow.message),
            if (createdDateTime != null)
              Text(
                DateFormat('yyyy/MM/dd HH:mm').format(createdDateTime),
                style: TextStyle(color: Colors.black54),
              ),
          ],
        ),
      ],
    );
  }
}
