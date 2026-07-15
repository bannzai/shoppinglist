import 'package:flutter/foundation.dart';
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
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#1F6B4E',
        ),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('朱（デフォルト）はそのまま保存される', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#C2410C');

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#C2410C',
        ),
        isTrue,
      );
    });

    test('小文字 HEX は大文字に正規化される', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#0f4c81');

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#0F4C81',
        ),
        isTrue,
      );
    });

    test('旧 10 色プリセットの HEX は朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#673AB7');

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#C2410C',
        ),
        isTrue,
      );
    });

    test('5 色プリセット外の正常 HEX も朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '#F44336');

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#C2410C',
        ),
        isTrue,
      );
    });

    test('不正 HEX は朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: 'invalid');

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#C2410C',
        ),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('空文字は朱にフォールバックする', () async {
      await HomeWidgetDataSync.syncThemeColor(themeColorHex: '');

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_theme_color_hex' &&
              c.arguments['data'] == '#C2410C',
        ),
        isTrue,
      );
    });
  });

  group('syncPremiumStatus', () {
    test('プレミアム状態 true を保存して Widget 更新する', () async {
      await HomeWidgetDataSync.syncPremiumStatus(isPremium: true);

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_is_premium' &&
              c.arguments['data'] == true,
        ),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('プレミアム状態 false を保存して Widget 更新する', () async {
      await HomeWidgetDataSync.syncPremiumStatus(isPremium: false);

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_is_premium' &&
              c.arguments['data'] == false,
        ),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });
  });

  group('syncShoppingLists', () {
    test('買い物リスト一覧・グループIDを保存して Widget 更新する', () async {
      await HomeWidgetDataSync.syncShoppingLists(
        shoppingLists: const [],
        groupID: 'group-1',
        groupName: 'テストグループ',
      );

      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_shopping_lists',
        ),
        isTrue,
      );
      expect(
        calls.any(
          (c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'widget_current_group_id' &&
              c.arguments['data'] == 'group-1',
        ),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });
  });

  // Issue #475 Root Cause 2: iOS では updateWidget が AppDelegate の
  // reload チャンネル経由で reloadAllTimelines() を追加で呼ぶ。
  group('updateWidget (iOS reloadAllTimelines)', () {
    const reloadChannel = MethodChannel(
      'com.bannzai.shoppinglist/home_widget_reload',
    );

    // defaultTargetPlatform をテスト内で iOS に固定する。tearDown で必ず null に戻し、
    // 後続テストの既定プラットフォーム (android) に影響を残さないようにする。
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(reloadChannel, null);
    });

    test('iOS では reload チャンネルに reloadAllTimelines が invoke される', () async {
      final reloadCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(reloadChannel, (call) async {
            reloadCalls.add(call);
            return null;
          });

      await HomeWidgetDataSync.updateWidget();

      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
      expect(reloadCalls.any((c) => c.method == 'reloadAllTimelines'), isTrue);
    });

    test('reload チャンネル未登録 (MissingPluginException) でも例外を投げず完了する', () async {
      // reloadChannel のモックを登録しない = ネイティブ側ハンドラが無い状態を再現。
      await expectLater(HomeWidgetDataSync.updateWidget(), completes);
      expect(calls.any((c) => c.method == 'updateWidget'), isTrue);
    });
  });
}
