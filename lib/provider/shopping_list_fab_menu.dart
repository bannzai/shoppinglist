import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_fab_menu.g.dart';

/// アイテム追加 FAB（`ExpandableFab`）の展開メニューの開閉を管理する Notifier。
///
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。
@riverpod
class ShoppingListFabMenu extends _$ShoppingListFabMenu {
  /// 開いてから一定時間で自動クローズするためのタイマー。開くたびに貼り直す。
  Timer? _autoCloseTimer;

  @override
  bool build() {
    // Provider 破棄時にタイマーを止め、破棄後の state 書き込み（例外）を防ぐ。
    ref.onDispose(() => _autoCloseTimer?.cancel());
    return false;
  }

  /// メニューを開く。開いた時点から 3 秒後に自動クローズするタイマーを貼り直す。
  void open() {
    state = true;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 3), close);
  }

  /// メニューを閉じる。既に閉じていても安全（冪等）。自動クローズタイマーも止める。
  void close() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    if (state) {
      state = false;
    }
  }
}
