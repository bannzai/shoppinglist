import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/utils/export_text_formatter.dart';

void main() {
  group('buildShoppingListExportText', () {
    test('未チェックアイテムは「・」、チェック済みは「✓」で表示される', () {
      final items = [
        GroupShoppingListItem(
          id: '1',
          groupID: 'g1',
          shoppingListID: 's1',
          userID: 'u1',
          message: '牛乳',
          order: 0,
          status: GroupShoppingListItemStatus.unchecked,
        ),
        GroupShoppingListItem(
          id: '2',
          groupID: 'g1',
          shoppingListID: 's1',
          userID: 'u1',
          message: 'パン',
          order: 1,
          status: GroupShoppingListItemStatus.checked,
        ),
      ];

      expect(
        buildShoppingListExportText(
          shoppingListName: '週末の買い物',
          shoppingListItems: items,
        ),
        '週末の買い物\n---\n・ 牛乳\n✓ パン',
      );
    });

    test('空のリストはリスト名と区切り線のみ', () {
      expect(
        buildShoppingListExportText(
          shoppingListName: '空のリスト',
          shoppingListItems: [],
        ),
        '空のリスト\n---',
      );
    });

    test('改行やタブを含む入力は1行にサニタイズされる', () {
      final items = [
        GroupShoppingListItem(
          id: '1',
          groupID: 'g1',
          shoppingListID: 's1',
          userID: 'u1',
          message: '牛乳\n2本\t特売',
          order: 0,
          status: GroupShoppingListItemStatus.unchecked,
        ),
      ];

      expect(
        buildShoppingListExportText(
          shoppingListName: '週末\nの買い物',
          shoppingListItems: items,
        ),
        '週末 の買い物\n---\n・ 牛乳 2本 特売',
      );
    });
  });
}
