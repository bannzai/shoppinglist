import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// ソフトキーボードの直上に表示する入力補助ツールバー（Issue #488）。
///
/// アイテム入力の TextField は Enter 連打でキーボードが閉じ開きしないよう
/// textInputAction を newline にしている（text_shopping_list_item.dart）ため、
/// キーボードに done ボタンが出ず閉じる手段がわからない。そこでキーボード表示中だけ
/// このツールバーを出し、「閉じる」でフォーカスを外してキーボードを閉じられるようにする。
class KeyboardCloseToolbar extends StatelessWidget {
  /// ツールバーの固定高。キーボード表示中は FAB を隠さない(Issue #498)ため、
  /// page.dart がこの分だけ FAB を持ち上げて右端の閉じるボタンとの重なりを避ける。
  /// レイアウト計算に使えるよう固定値にしている(TextButton の既定タップ領域 48px)。
  static const double height = 48;

  final String groupID;
  final String shoppingListID;

  const KeyboardCloseToolbar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: tokens.neutral.surface,
        border: Border(top: BorderSide(color: tokens.neutral.divider2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {
              analytics.logEvent(
                name: 'tap_keyboard_toolbar_close',
                parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                },
              );
              // フォーカスを外すとソフトキーボードが閉じる。入力途中テキストの確定保存・
              // 空の入力行の削除はフォーカス喪失を検知する FocusNode listener
              // (text_shopping_list_item.dart) 側が担うため、ここでは unfocus のみ行う。
              FocusManager.instance.primaryFocus?.unfocus();
            },
            icon: Icon(
              Icons.keyboard_hide_outlined,
              size: 18,
              color: tokens.neutral.ink2,
            ),
            label: Text(
              '閉じる',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.neutral.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
