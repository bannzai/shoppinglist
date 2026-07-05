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

  /// 背景 overlay タップでダイアログを閉じるか。呼び出し元の
  /// `showGeneralDialog(barrierDismissible: ...)` と同じ値を渡す。
  ///
  /// 背景 overlay は画面全体を覆う `Container(color: ...)` を持つため常にヒットテストが
  /// 不透明になり、`showGeneralDialog` 自身が下に敷く `ModalBarrier` によるタップ dismiss
  /// までタップが届かない。そのため overlay 自身に `Navigator.pop` を持たせて代替する。
  final bool barrierDismissible;

  const AppDialogShell({
    super.key,
    required this.child,
    required this.barrierDismissible,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: barrierDismissible ? () => Navigator.pop(context) : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: const Color(0x660F0C08)),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, size.height * 0.32, 24, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                // card 内のタップは背景 overlay の onTap（dismiss）に伝播させず吸収する。
                behavior: HitTestBehavior.opaque,
                onTap: () {},
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
      ],
    );
  }
}
