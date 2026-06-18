import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  group('resolveAccentPreset', () {
    test('null は AccentPreset.shu にフォールバックする', () {
      expect(resolveAccentPreset(null), AccentPreset.shu);
    });

    test('不正値は AccentPreset.shu にフォールバックする', () {
      expect(resolveAccentPreset('#INVALID'), AccentPreset.shu);
    });

    test('空文字は AccentPreset.shu にフォールバックする', () {
      expect(resolveAccentPreset(''), AccentPreset.shu);
    });

    test('旧10色プリセット(#673AB7 等)は AccentPreset.shu にフォールバックする', () {
      expect(resolveAccentPreset('#673AB7'), AccentPreset.shu);
      expect(resolveAccentPreset('#F44336'), AccentPreset.shu);
      expect(resolveAccentPreset('#E91E63'), AccentPreset.shu);
      expect(resolveAccentPreset('#2196F3'), AccentPreset.shu);
      expect(resolveAccentPreset('#607D8B'), AccentPreset.shu);
    });

    test('新5色プリセットHEXが正しく解決される', () {
      expect(resolveAccentPreset('#C2410C'), AccentPreset.shu);
      expect(resolveAccentPreset('#1F6B4E'), AccentPreset.matcha);
      expect(resolveAccentPreset('#0F4C81'), AccentPreset.ai);
      expect(resolveAccentPreset('#1B1B1B'), AccentPreset.sumi);
      expect(resolveAccentPreset('#B45309'), AccentPreset.kuchiba);
    });
  });

  group('isSupportedThemeColorHex', () {
    test('現行5色プリセットはサポート対象', () {
      for (final preset in AccentPreset.values) {
        expect(isSupportedThemeColorHex(preset.persistHex), isTrue);
      }
    });

    test('旧10色プリセットHEXはサポート対象外', () {
      expect(isSupportedThemeColorHex('#673AB7'), isFalse);
      expect(isSupportedThemeColorHex('#F44336'), isFalse);
      expect(isSupportedThemeColorHex('#E91E63'), isFalse);
      expect(isSupportedThemeColorHex('#FF9800'), isFalse);
    });

    test('プリセットにない任意のHEXはサポート対象外', () {
      expect(isSupportedThemeColorHex('#000000'), isFalse);
      expect(isSupportedThemeColorHex('#FFFFFF'), isFalse);
      expect(isSupportedThemeColorHex('invalid'), isFalse);
    });
  });

  group('themeColorPresets', () {
    test('デフォルトカラー(朱)が先頭にある', () {
      expect(themeColorPresets.first.hex, defaultThemeColorHex);
      expect(themeColorPresets.first.preset, AccentPreset.shu);
    });

    test('全5色のHEX値がユニーク', () {
      final hexValues = themeColorPresets.map((p) => p.hex).toSet();
      expect(hexValues.length, themeColorPresets.length);
      expect(themeColorPresets.length, AccentPreset.values.length);
    });

    test('和の伝統色名が表示用ラベルに含まれる', () {
      final labels = themeColorPresets.map((p) => p.label).toList();
      expect(labels, containsAll(['朱', '抹茶', '藍', '墨', '朽葉']));
    });
  });

  group('AccentPreset.persistHex', () {
    test('LIGHT 色の HEX を #RRGGBB 大文字で返す', () {
      expect(AccentPreset.shu.persistHex, '#C2410C');
      expect(AccentPreset.matcha.persistHex, '#1F6B4E');
      expect(AccentPreset.ai.persistHex, '#0F4C81');
      expect(AccentPreset.sumi.persistHex, '#1B1B1B');
      expect(AccentPreset.kuchiba.persistHex, '#B45309');
    });
  });

  group('AppUser themeColorHex フィールド', () {
    test('themeColorHex が null の場合に正しくシリアライズされる', () {
      const appUser = AppUser(id: 'test-user');
      final json = appUser.toJson();
      expect(json['themeColorHex'], isNull);
    });

    test('themeColorHex が設定された場合に正しくシリアライズされる', () {
      const appUser = AppUser(id: 'test-user', themeColorHex: '#C2410C');
      final json = appUser.toJson();
      expect(json['themeColorHex'], '#C2410C');
    });

    test('themeColorHex 付きの JSON から正しくデシリアライズされる', () {
      final json = {'id': 'test-user', 'themeColorHex': '#1F6B4E'};
      final appUser = AppUser.fromJson(json);
      expect(appUser.themeColorHex, '#1F6B4E');
    });

    test('themeColorHex なしの JSON から正しくデシリアライズされる（後方互換性）', () {
      final json = {'id': 'test-user'};
      final appUser = AppUser.fromJson(json);
      expect(appUser.themeColorHex, isNull);
    });
  });
}
