import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

void main() {
  group('FunctionsCallException', () {
    test('toString はプレフィックスなしでメッセージをそのまま返す', () {
      final exception = FunctionsCallException('有効な招待が見つかりません');
      expect(exception.toString(), '有効な招待が見つかりません');
    });

    test('describeError で表示しても Exception: プレフィックスが付かない', () {
      final result = describeError(FunctionsCallException('有効な招待が見つかりません'));
      expect(result.title, isNull);
      expect(result.message, '有効な招待が見つかりません');
    });
  });
}
