import 'package:flutter/material.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_color.g.dart';

/// テーマカラーのプリセット一覧。
const themeColorPresets = <({String hex, String label, Color color})>[
  (hex: '#673AB7', label: 'パープル', color: Colors.deepPurple),
  (hex: '#F44336', label: 'レッド', color: Color(0xFFF44336)),
  (hex: '#E91E63', label: 'ピンク', color: Color(0xFFE91E63)),
  (hex: '#FF9800', label: 'オレンジ', color: Color(0xFFFF9800)),
  (hex: '#4CAF50', label: 'グリーン', color: Color(0xFF4CAF50)),
  (hex: '#009688', label: 'ティール', color: Color(0xFF009688)),
  (hex: '#2196F3', label: 'ブルー', color: Color(0xFF2196F3)),
  (hex: '#3F51B5', label: 'インディゴ', color: Color(0xFF3F51B5)),
  (hex: '#795548', label: 'ブラウン', color: Color(0xFF795548)),
  (hex: '#607D8B', label: 'ブルーグレー', color: Color(0xFF607D8B)),
];

/// デフォルトテーマカラー（deepPurple）のHEX値。
const defaultThemeColorHex = '#673AB7';

/// サポート対象のテーマカラーか判定する。
bool isSupportedThemeColorHex(String themeColorHex) {
  for (final preset in themeColorPresets) {
    if (preset.hex == themeColorHex) {
      return true;
    }
  }
  return false;
}

/// テーマカラーHEXからColorを解決する。null/不正値はデフォルトへフォールバック。
Color resolveThemeColor(String? themeColorHex) {
  for (final preset in themeColorPresets) {
    if (preset.hex == themeColorHex) {
      return preset.color;
    }
  }
  return Colors.deepPurple;
}

/// ユーザーのテーマカラーをFirestoreに保存する。
class ThemeColorUpdate {
  final UserDatabase userDatabase;
  ThemeColorUpdate({required this.userDatabase});

  /// [themeColorHex] にHEX文字列を渡してテーマカラーを更新する。
  Future<void> call({required String themeColorHex}) async {
    if (!isSupportedThemeColorHex(themeColorHex)) {
      throw const FormatException('サポート対象外のテーマカラーです');
    }
    await userDatabase.userReference().update({
      'themeColorHex': themeColorHex,
    });
  }
}

/// テーマカラー更新操作を提供するProvider。
@Riverpod(dependencies: [userDatabase])
ThemeColorUpdate themeColorUpdate(Ref ref) {
  return ThemeColorUpdate(userDatabase: ref.read(userDatabaseProvider));
}
