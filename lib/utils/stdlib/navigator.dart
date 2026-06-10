import 'package:flutter/widgets.dart';

/// await を跨いで遅延実行される「自ルートを閉じる」操作を、対象ルートに限定して行う。
///
/// `Navigator.pop` は対象を指定せずスタック最上位を 1 枚剥がすため、await 中に
/// ユーザーがシートやダイアログを先に閉じていると、遅延した pop が残った唯一の
/// ページルート(ホーム)まで剥がして真っ黒な画面になる (#372)。
/// 閉じたい [route] がまだスタックに残っている場合のみ閉じることで pop のし過ぎを防ぐ。
/// 呼び出し側は await の前に `Navigator.of(context)` と `ModalRoute.of(context)` を束ねておくこと。
void popRouteSafely({
  required NavigatorState navigator,
  required Route<dynamic>? route,
}) {
  if (route == null) {
    return;
  }
  if (route.isCurrent) {
    navigator.pop();
  } else if (route.isActive) {
    // 上に別ルートが乗っている場合は自ルートだけを取り除く(遷移アニメーションなし)。
    navigator.removeRoute(route);
  }
  // isActive=false は既に閉じられているため何もしない。
}
