import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recently_added_shopping_list_item.g.dart';

/// 手入力で追加した行を強調する時間。
const recentlyAddedShoppingListItemHighlightDuration = Duration(seconds: 3);

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
@riverpod
class RecentlyAddedShoppingListItem extends _$RecentlyAddedShoppingListItem {
  Timer? _clearTimer;
  int _latestSubmissionSequence = 0;

  @override
  String? build(String shoppingListID) {
    ref.onDispose(() => _clearTimer?.cancel());
    return null;
  }

  /// 手入力の確定を開始し、その入力を識別する連番を返す。
  ///
  /// 入力イベントごとに新しい連番が必要なため、このメソッドは意図的に非冪等。
  int beginSubmission() {
    _latestSubmissionSequence++;
    clear();
    return _latestSubmissionSequence;
  }

  /// [submissionSequence] が最後の入力なら、追加された行を一定時間強調する。
  void highlightIfLatest({
    required int submissionSequence,
    required String shoppingListItemID,
  }) {
    if (submissionSequence != _latestSubmissionSequence ||
        state == shoppingListItemID) {
      return;
    }
    state = shoppingListItemID;
    _clearTimer?.cancel();
    _clearTimer = Timer(recentlyAddedShoppingListItemHighlightDuration, clear);
  }

  /// 強調表示を解除する。すでに解除済みでも安全に呼べる。
  void clear() {
    _clearTimer?.cancel();
    _clearTimer = null;
    if (state != null) {
      state = null;
    }
  }
}
