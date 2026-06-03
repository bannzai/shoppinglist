import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// ダイアログの外殻 (overlay + 上 32% から始まる card)。
/// `design_handoff_shopping_list/source/screens-list-settings.jsx` の DialogShell 相当。
///
/// - 背景 overlay: rgba(15,12,8,0.4) 相当 + 軽い blur 2px
/// - card: left/right margin 24, top 画面高さの 32%, radius 20
/// - card の内側は 20px の padding を持ち、利用側は [child] に任意の Column 等を渡す
///
/// `showDialog` の `builder` で `AppDialogShell(child: ...)` を返して使う。
class AppDialogShell extends StatelessWidget {
  /// card 内に配置する Widget。
  final Widget child;

  const AppDialogShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final size = MediaQuery.of(context).size;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        color: const Color(0x660F0C08),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, size.height * 0.32, 24, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                color: neutral.card,
                borderRadius: BorderRadius.circular(20),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
