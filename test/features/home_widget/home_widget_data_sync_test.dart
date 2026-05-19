import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('syncThemeColor (5 色プリセット)', () {
    test('5 色プリセットの HEX はそのまま保存される', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#1F6B4E');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#1F6B4E'),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('朱（デフォルト）はそのまま保存される', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#C2410C');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#C2410C'),
        isTrue,
      );
    });

    test('小文字 HEX は大文字に正規化される', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#0f4c81');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#0F4C81'),
        isTrue,
      );
    });

    test('旧 10 色プリセットの HEX は朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#673AB7');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#C2410C'),
        isTrue,
      );
    });

    test('5 色プリセット外の正常 HEX も朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#F44336');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#C2410C'),
        isTrue,
      );
    });

    test('不正 HEX は朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: 'invalid');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#C2410C'),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('空文字は朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#C2410C'),
        isTrue,
      );
    });
  });

  group('syncPremiumStatus', () {
    test('プレミアム状態 true を保存して Widget 更新する', () async {
      await HomeWidgetDataSync.syncPremiumStatus(isPremium: true);

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_is_premium' &&
            c.arguments['data'] == true),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('プレミアム状態 false を保存して Widget 更新する', () async {
      await HomeWidgetDataSync.syncPremiumStatus(isPremium: false);

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_is_premium' &&
            c.arguments['data'] == false),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });
  });
}
