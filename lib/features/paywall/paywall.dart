import 'package:flutter/material.dart';
import 'package:shoppinglist/features/paywall/paywall_page.dart';

/// 各 premium gate から呼び出すペイウォール画面遷移関数。
///
/// `fullscreenDialog: true` で画面下から迫り出す UX を与え、
/// close ボタン（AppBar の leading close アイコン）で閉じられるようにする。
Future<void> showPaywall({required BuildContext context}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PaywallPage(),
      fullscreenDialog: true,
    ),
  );
}
