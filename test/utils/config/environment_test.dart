import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/utils/config/environment.dart';

void main() {
  tearDown(() {
    Environment.flavor = null;
  });

  group('Environment.useRCTestStore', () {
    test('returns false when flavor is PRODUCTION', () {
      Environment.flavor = Flavor.PRODUCTION;
      expect(Environment.useRCTestStore, isFalse);
    });

    test('returns false when flavor is DEVELOP and no --dart-define passed',
        () {
      Environment.flavor = Flavor.DEVELOP;
      expect(Environment.useRCTestStore, isFalse);
    });

    test('returns false when flavor is LOCAL and no --dart-define passed', () {
      Environment.flavor = Flavor.LOCAL;
      expect(Environment.useRCTestStore, isFalse);
    });
  });
}
