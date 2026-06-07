import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_composer_state.g.dart';

/// 買い物リストで現在コンポーザー(唯一の入力欄)が編集中のアイテムID。
/// null = 新規追加モード、非null = そのアイテムを編集中。
///
/// 表示行のタップで [edit] され、コンポーザーがこの値を購読して対象アイテムの
/// テキストを読み込む。保存・キャンセルで [clear] して追加モードへ戻す。
/// リスト/グループ切替で状態が残らないよう autoDispose(@riverpod 既定)にする。
@riverpod
class EditingShoppingListItemID extends _$EditingShoppingListItemID {
  @override
  String? build() => null;

  void edit(String itemID) => state = itemID;
  void clear() => state = null;
}

/// コンポーザーへフォーカスを要求するためのシグナル(カウンタ)。
/// FAB タップなど、コンポーザーの外からフォーカスを当てたい時に [request] で増やす。
/// コンポーザーはこの値の変化を useEffect で監視し、フォーカスを要求する。
/// (FocusNode はコンポーザー側の useFocusNode が保持するため、外部からは値の変化で伝える)
@riverpod
class ComposerFocusRequest extends _$ComposerFocusRequest {
  @override
  int build() => 0;

  void request() => state = state + 1;
}
