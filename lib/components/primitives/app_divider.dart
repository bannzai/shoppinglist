import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// inset 付き 0.5px 区切り線。
/// `design_handoff_shopping_list/source/frame.jsx#Divider` 相当。
/// 設定画面で Cell 間を区切る用途。左 inset の既定値 60 は icon tile (32) + spacing (12)
/// + section padding (16) を吸収するための値。
class AppDivider extends StatelessWidget {
  /// 左 inset の幅 (px)。
  final double inset;

  const AppDivider({super.key, this.inset = 60});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: inset),
      child: Container(
        height: 0.5,
        color: context.appTheme.neutral.divider,
      ),
    );
  }
}
