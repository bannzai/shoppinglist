import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_fab_menu.g.dart';

/// アイテム一覧画面の右下ダブル FAB のうち、どちらの展開メニューが開いているか。
/// 2 つの FAB（リスト作成 / アイテム追加）で開閉状態を共有し、同時に 1 つだけ開くようにする。
enum ShoppingListFabMenuKind {
  /// リスト作成 FAB（`CreateListFab`）のメニュー。
  createList,

  /// アイテム追加 FAB（`ExpandableFab`）のメニュー。
  addItem,
}

/// ダブル FAB の展開メニューの開閉を一元管理する Notifier。
///
/// 開閉状態を 2 つの FAB で共有することで以下を満たす:
/// - もう一方の FAB を開くと、単一状態の置き換えにより前のメニューが自動的に閉じる。
/// - 開くたびに 3 秒の自動クローズタイマーを貼り直す（放置時は自動で閉じる）。
/// - スクロール等の外部イベントからは `close()` を呼んで閉じる。
@riverpod
class ShoppingListFabMenu extends _$ShoppingListFabMenu {
  /// 開いてから一定時間で自動クローズするためのタイマー。開くたびに貼り直す。
  Timer? _autoCloseTimer;

  @override
  ShoppingListFabMenuKind? build() {
    // Provider 破棄時にタイマーを止め、破棄後の state 書き込み（例外）を防ぐ。
    ref.onDispose(() => _autoCloseTimer?.cancel());
    return null;
  }

  /// 指定した FAB のメニューを開く。もう一方が開いていても単一状態で置き換わるため、
  /// 前のメニューは自動的に閉じる。開いた時点から 3 秒後に自動クローズするタイマーを貼り直す。
  void open(ShoppingListFabMenuKind kind) {
    state = kind;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 3), close);
  }

  /// メニューを閉じる。既に閉じていても安全（冪等）。自動クローズタイマーも止める。
  void close() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    if (state != null) {
      state = null;
    }
  }
}
