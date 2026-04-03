import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/provider/theme_color.dart';

void main() {
  group('resolveThemeColor', () {
    test('null の場合は deepPurple にフォールバックする', () {
      expect(resolveThemeColor(null), Colors.deepPurple);
    });

    test('不正値の場合は deepPurple にフォールバックする', () {
      expect(resolveThemeColor('#INVALID'), Colors.deepPurple);
    });

    test('空文字の場合は deepPurple にフォールバックする', () {
      expect(resolveThemeColor(''), Colors.deepPurple);
    });

    test('プリセットのHEX値で正しい色が返る', () {
      expect(resolveThemeColor('#673AB7'), Colors.deepPurple);
      expect(resolveThemeColor('#F44336'), const Color(0xFFF44336));
      expect(resolveThemeColor('#2196F3'), const Color(0xFF2196F3));
    });
  });

  group('isSupportedThemeColorHex', () {
    test('プリセットのHEX値はサポート対象', () {
      for (final preset in themeColorPresets) {
        expect(isSupportedThemeColorHex(preset.hex), isTrue);
      }
    });

    test('プリセットにないHEX値はサポート対象外', () {
      expect(isSupportedThemeColorHex('#000000'), isFalse);
      expect(isSupportedThemeColorHex('#FFFFFF'), isFalse);
      expect(isSupportedThemeColorHex('invalid'), isFalse);
    });
  });

  group('themeColorPresets', () {
    test('デフォルトカラーがプリセットに含まれている', () {
      expect(
        themeColorPresets.any((p) => p.hex == defaultThemeColorHex),
        isTrue,
      );
    });

    test('全プリセットのHEX値がユニーク', () {
      final hexValues = themeColorPresets.map((p) => p.hex).toSet();
      expect(hexValues.length, themeColorPresets.length);
    });
  });

  group('AppUser themeColorHex フィールド', () {
    test('themeColorHex が null の場合に正しくシリアライズされる', () {
      const appUser = AppUser(id: 'test-user');
      final json = appUser.toJson();
      expect(json['themeColorHex'], isNull);
    });

    test('themeColorHex が設定された場合に正しくシリアライズされる', () {
      const appUser = AppUser(id: 'test-user', themeColorHex: '#F44336');
      final json = appUser.toJson();
      expect(json['themeColorHex'], '#F44336');
    });

    test('themeColorHex 付きの JSON から正しくデシリアライズされる', () {
      final json = {
        'id': 'test-user',
        'themeColorHex': '#2196F3',
      };
      final appUser = AppUser.fromJson(json);
      expect(appUser.themeColorHex, '#2196F3');
    });

    test('themeColorHex なしの JSON から正しくデシリアライズされる（後方互換性）', () {
      final json = {
        'id': 'test-user',
      };
      final appUser = AppUser.fromJson(json);
      expect(appUser.themeColorHex, isNull);
    });
  });
}
