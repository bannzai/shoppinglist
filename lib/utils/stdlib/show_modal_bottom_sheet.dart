import 'package:flutter/material.dart';
import 'package:shoppinglist/features/resolver/app.dart';

/// アプリ共通のモーダルボトムシート。builder を [AppResolvers] でラップするため、
/// シート内の build で ref.watch が機能する。
///
/// [fitContentHeight] が true のときは画面高 90% 固定ではなくコンテンツの高さに
/// フィットさせる（アイテム詳細シートのような項目の少ないシート向け。Issue #464 で
/// シートの中身が減り、固定高だと空白が目立つため追加した）。
Future<T?> appShowModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool fitContentHeight = false,
}) {
  final height = MediaQuery.of(context).size.height;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final content = AppResolvers(
        builder: (context, user) => builder(context),
      );
      if (fitContentHeight) {
        // ホームインジケータとの重なりは SafeArea で避ける（固定高側はシート内の
        // 余白設計に任せている既存挙動を変えない）。
        return SafeArea(child: content);
      }
      return SizedBox(height: height * 0.9, child: content);
    },
  );
}
