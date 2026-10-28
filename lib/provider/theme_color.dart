import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/style/tokens.dart';

part 'theme_color.g.dart';

/// デフォルトテーマカラー（朱）の HEX。
/// `users/{uid}.themeColorHex` が未設定の新規ユーザーや、
/// 旧 10 色プリセット（`#673AB7` 等）の値を持つ既存ユーザーは
/// 読み取り時にこの色（`AccentPreset.shu`）にフォールバックする。
const defaultThemeColorHex = '#C2410C';

/// テーマカラー設定 UI で表示するプリセット一覧。
/// `AccentPreset` を `(hex, color)` 形式に変換した薄いビュー。
/// 表示名は BuildContext が要るため `AccentPresetL10n.label(context)` で解決する。
final themeColorPresets = <({String hex, Color color, AccentPreset preset})>[
  for (final preset in AccentPreset.values)
    (hex: preset.persistHex, color: preset.light, preset: preset),
];

/// HEX 文字列が現行 5 色プリセットのいずれかに完全一致するかを判定する。
/// 旧 10 色 HEX（`#673AB7` 等）は `false` を返す。
bool isSupportedThemeColorHex(String themeColorHex) {
  for (final preset in AccentPreset.values) {
    if (preset.persistHex == themeColorHex) {
      return true;
    }
  }
  return false;
}

/// HEX 文字列から `AccentPreset` を解決する。
/// `null` / 旧 10 色 HEX / 不正値はすべて `AccentPreset.shu` にフォールバックする。
/// 既存ユーザーが保存している旧プリセット値を朱に倒すための入口。
AccentPreset resolveAccentPreset(String? themeColorHex) {
  for (final preset in AccentPreset.values) {
    if (preset.persistHex == themeColorHex) {
      return preset;
    }
  }
  return AccentPreset.shu;
}

/// 旧 API 互換: HEX → Color。新規コードでは `resolveAccentPreset(...).light` を使う。
@Deprecated('Use resolveAccentPreset(themeColorHex).light instead.')
Color resolveThemeColor(String? themeColorHex) =>
    resolveAccentPreset(themeColorHex).light;

/// ユーザーのテーマカラーを Firestore に保存する。
/// 5 色プリセット以外の HEX は保存しない（現状 UI からは prefix を選んで保存するのみ）。
class ThemeColorUpdate {
  final UserDatabase userDatabase;
  ThemeColorUpdate({required this.userDatabase});

  /// `preset` で 5 色プリセットを指定して更新する。
  Future<void> call({required AccentPreset preset}) async {
    await userDatabase.userReference().update({
      'themeColorHex': preset.persistHex,
      'updatedDateTime': FieldValue.serverTimestamp(),
      'serverUpdatedDateTime': FieldValue.serverTimestamp(),
    });
  }
}

/// テーマカラー更新操作を提供するProvider。
@Riverpod(dependencies: [userDatabase])
ThemeColorUpdate themeColorUpdate(Ref ref) {
  return ThemeColorUpdate(userDatabase: ref.watch(userDatabaseProvider));
}
