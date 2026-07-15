import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';

part 'string_shared_preferences.g.dart';

/// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
///
/// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
/// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
///
/// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
/// (この Provider は文字列の生の read/write に徹する)。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
class StringSharedPreferences extends _$StringSharedPreferences {
  @override
  String? build({required String key}) {
    return ref.watch(sharedPreferencesProvider).getString(key);
  }

  /// [value] を SharedPreferences に保存して state を更新する。
  Future<void> set({required String value}) async {
    await ref.read(sharedPreferencesProvider).setString(key, value);
    state = value;
  }

  /// [key] を SharedPreferences から削除して state を null に戻す。
  Future<void> remove() async {
    await ref.read(sharedPreferencesProvider).remove(key);
    state = null;
  }
}
