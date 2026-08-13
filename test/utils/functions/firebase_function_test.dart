import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

void main() {
  group('FunctionsCallException', () {
    test('toString はプレフィックスなしでメッセージをそのまま返す', () {
      final exception = FunctionsCallException('有効な招待が見つかりません');
      expect(exception.toString(), '有効な招待が見つかりません');
    });

    test('describeError で表示しても Exception: プレフィックスが付かない', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ja'));
      final result = describeError(
        l10n,
        FunctionsCallException('有効な招待が見つかりません'),
      );
      expect(result.title, isNull);
      expect(result.message, '有効な招待が見つかりません');
    });
  });
}
