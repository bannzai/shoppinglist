import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list.dart';

void main() {
  group('買い物リスト作成数上限', () {
    test('無料ユーザーのグループあたり上限は5個', () {
      expect(freeGroupActiveShoppingListLimit, 5);
    });

    test('ShoppingListLimitExceededException のメッセージが正しい', () {
      const exception = ShoppingListLimitExceededException(limit: 5);
      expect(
        exception.toString(),
        '無料プランでは1グループあたり5個までリストを作成できます。プレミアムにアップグレードすると無制限に作成できます',
      );
    });

    test('ShoppingListLimitExceededException は limit を保持する', () {
      const exception = ShoppingListLimitExceededException(limit: 5);
      expect(exception.limit, 5);
    });

    test('ShoppingListLimitExceededException は Exception を実装する', () {
      const exception = ShoppingListLimitExceededException(limit: 5);
      expect(exception, isA<Exception>());
    });
  });
}
