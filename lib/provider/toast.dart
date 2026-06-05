import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toast.g.dart';

/// 画面最前面（モーダルより上）に出すグローバルトーストの表示状態。
/// `null` のとき非表示。値が入っているとその Widget を描画する。
/// 表示中に再度 `show` されたら即座に置き換える（単一表示）。
///
/// keepAlive: アプリ全体で 1 インスタンスを共有し、`appProviderContainer`
/// 経由のグローバル関数と `ToastOverlay` が同じ状態を参照するため。
@Riverpod(keepAlive: true)
class Toast extends _$Toast {
  Timer? _dismissTimer;

  /// 現在表示中トーストの同一性キー。同一内容の再 show を無視する判定に使う。
  Object? _currentIdentity;

  @override
  Widget? build() {
    ref.onDispose(() => _dismissTimer?.cancel());
    return null;
  }

  /// `content` を `duration` の間だけ表示する。
  /// `identity` が現在表示中のものと同一なら、再 show を無視してタイマーをリセットしない。
  /// 同一通知が高頻度で再発行されても、最初の表示から `duration` 後に必ず消すため。
  void show(Widget content,
      {Duration duration = const Duration(seconds: 5), Object? identity}) {
    if (state != null && identity != null && identity == _currentIdentity) {
      return;
    }
    _dismissTimer?.cancel();
    _currentIdentity = identity;
    state = content;
    _dismissTimer = Timer(duration, dismiss);
  }

  /// 表示中のトーストを即座に消す。
  void dismiss() {
    _dismissTimer?.cancel();
    _currentIdentity = null;
    state = null;
  }
}
