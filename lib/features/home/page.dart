import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';

/// アプリのホーム画面。
///
/// 表示中グループ/リストの状態は currentGroupIDProvider / currentShoppingListIDProvider に、
/// グループ確定は CurrentGroupResolver に、画面本体は ShoppingListPage に分解済み。
/// そのため HomePage はルーティング上の入口名を保つだけの薄いラッパに留める。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const ShoppingListPage();
}
