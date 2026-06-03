import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';

part 'bool_shared_preferences.g.dart';

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
class BoolSharedPreferences extends _$BoolSharedPreferences {
  @override
  bool build({required String key}) {
    return ref.watch(sharedPreferencesProvider).getBool(key) ?? false;
  }

  /// [value] を SharedPreferences に保存して state を更新する。
  Future<void> set({required bool value}) async {
    await ref.read(sharedPreferencesProvider).setBool(key, value);
    state = value;
  }

  /// 現在値を反転して保存する。内部で [set] を呼ぶ。
  /// 反転操作なので冪等ではない（呼ぶたびに値が変わる）。固定値にしたい場合は [set] を使う。
  Future<void> toggle() => set(value: !state);
}
