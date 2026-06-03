import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';

/// SharedPreferences をモック初期化し、sharedPreferencesProvider を override した
/// ProviderContainer を返す。
Future<ProviderContainer> _container(Map<String, Object> initialValues) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues(initialValues);
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('boolSharedPreferences family のインスタンス同一性', () {
    test('同じ key は同一の Notifier インスタンスを返す', () async {
      final container = await _container({});

      final first =
          container.read(boolSharedPreferencesProvider(key: 'foo').notifier);
      final second =
          container.read(boolSharedPreferencesProvider(key: 'foo').notifier);

      // 同一 key → family キャッシュにより同じインスタンス。
      expect(identical(first, second), isTrue);
      // provider オブジェクト自体も == で等価。
      expect(boolSharedPreferencesProvider(key: 'foo'),
          boolSharedPreferencesProvider(key: 'foo'));
    });

    test('異なる key は別の Notifier インスタンスを返す', () async {
      final container = await _container({});

      final foo =
          container.read(boolSharedPreferencesProvider(key: 'foo').notifier);
      final bar =
          container.read(boolSharedPreferencesProvider(key: 'bar').notifier);

      expect(identical(foo, bar), isFalse);
      expect(boolSharedPreferencesProvider(key: 'foo'),
          isNot(boolSharedPreferencesProvider(key: 'bar')));
    });
  });

  group('boolSharedPreferences family の値の読み書き', () {
    test('既定値は false、保存済みの値はそのまま反映する', () async {
      final container = await _container({'foo': true});

      expect(container.read(boolSharedPreferencesProvider(key: 'foo')), isTrue);
      expect(
          container.read(boolSharedPreferencesProvider(key: 'unset')), isFalse);
    });

    test('set は値を保存し、key ごとに独立している', () async {
      final container = await _container({});

      await container
          .read(boolSharedPreferencesProvider(key: 'foo').notifier)
          .set(value: true);

      expect(container.read(boolSharedPreferencesProvider(key: 'foo')), isTrue);
      // 別 key は影響を受けない。
      expect(
          container.read(boolSharedPreferencesProvider(key: 'bar')), isFalse);
    });

    test('toggle は現在値を反転する', () async {
      final container = await _container({'foo': false});
      final notifier =
          container.read(boolSharedPreferencesProvider(key: 'foo').notifier);

      await notifier.toggle();
      expect(container.read(boolSharedPreferencesProvider(key: 'foo')), isTrue);

      await notifier.toggle();
      expect(
          container.read(boolSharedPreferencesProvider(key: 'foo')), isFalse);
    });
  });
}
