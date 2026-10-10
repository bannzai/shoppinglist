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
    // シート自体を画面の上・左・右の safe area の内側に置く。false だとシートは
    // 画面幅いっぱいに置かれ、中身の SafeArea が左右の inset ぶんだけ内側に寄るため、
    // 左右に inset がある端末 (iPhone Duo の内側ディスプレイは右端にステータスバーの列が
    // あり、シートは最大幅 640 で中央に置かれる) でシートと中身の右端がずれて余白が残る
    // (issue #640)。true にすると SafeArea が消費した inset は中身の MediaQuery から
    // 除かれるため、各シートの SafeArea(top: false) は下端だけに効く。
    useSafeArea: true,
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
