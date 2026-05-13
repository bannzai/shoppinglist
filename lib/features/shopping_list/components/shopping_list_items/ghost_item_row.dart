import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/app_checkbox.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 空リストヒント内に並べる「次に追加されそう」な行のプレースホルダ。
/// `design_handoff_shopping_list/source/screens-list.jsx` の `ItemRow(ghost)` 相当。
/// 入力できない（`onChanged: null` で disabled）。
class GhostItemRow extends StatelessWidget {
  /// プレースホルダとして表示する例文。デフォルトは「新しいアイテム…」。
  final String hint;

  const GhostItemRow({super.key, this.hint = '新しいアイテム…'});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Opacity(
      opacity: 0.5,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppCheckbox(checked: false, onChanged: null),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: tokens.neutral.ink3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
