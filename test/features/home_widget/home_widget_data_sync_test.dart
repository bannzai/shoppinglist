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

  group('syncThemeColor', () {
    test('正常なHEX値を保存してWidget更新する', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#F44336');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#F44336'),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('不正HEXはデフォルトにフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: 'invalid');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#673AB7'),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('小文字HEXは大文字に正規化される', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#abcdef');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#ABCDEF'),
        isTrue,
      );
    });

    test('8桁HEX（アルファ付き）も正常に保存する', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#FF673AB7');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#FF673AB7'),
        isTrue,
      );
    });

    test('空文字はデフォルトにフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '');

      expect(
        calls.any((c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_theme_color_hex' &&
            c.arguments['data'] == '#673AB7'),
        isTrue,
      );
    });
  });

  group('syncPremiumStatus', () {
    test('プレミアム状態trueを保存してWidget更新する', () async {
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

    test('プレミアム状態falseを保存してWidget更新する', () async {
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
