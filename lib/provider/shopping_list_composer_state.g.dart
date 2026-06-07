// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_composer_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editingShoppingListItemIDHash() =>
    r'310beeadefad759f56ce0c76898b26de4895f4f8';

/// 買い物リストで現在コンポーザー(唯一の入力欄)が編集中のアイテムID。
/// null = 新規追加モード、非null = そのアイテムを編集中。
///
/// 表示行のタップで [edit] され、コンポーザーがこの値を購読して対象アイテムの
/// テキストを読み込む。保存・キャンセルで [clear] して追加モードへ戻す。
/// リスト/グループ切替で状態が残らないよう autoDispose(@riverpod 既定)にする。
///
/// Copied from [EditingShoppingListItemID].
@ProviderFor(EditingShoppingListItemID)
final editingShoppingListItemIDProvider =
    AutoDisposeNotifierProvider<EditingShoppingListItemID, String?>.internal(
  EditingShoppingListItemID.new,
  name: r'editingShoppingListItemIDProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$editingShoppingListItemIDHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EditingShoppingListItemID = AutoDisposeNotifier<String?>;
String _$composerFocusRequestHash() =>
    r'a0efe72cf597c4391989f49c5da732b4a4cbf3c5';

/// コンポーザーへフォーカスを要求するためのシグナル(カウンタ)。
/// FAB タップなど、コンポーザーの外からフォーカスを当てたい時に [request] で増やす。
/// コンポーザーはこの値の変化を useEffect で監視し、フォーカスを要求する。
/// (FocusNode はコンポーザー側の useFocusNode が保持するため、外部からは値の変化で伝える)
///
/// Copied from [ComposerFocusRequest].
@ProviderFor(ComposerFocusRequest)
final composerFocusRequestProvider =
    AutoDisposeNotifierProvider<ComposerFocusRequest, int>.internal(
  ComposerFocusRequest.new,
  name: r'composerFocusRequestProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$composerFocusRequestHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ComposerFocusRequest = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
