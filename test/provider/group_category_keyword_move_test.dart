import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/provider/group_category.dart';

void main() {
  GroupCategory category(String id, List<GroupCategoryKeyword> keywords) =>
      GroupCategory(
        id: id,
        groupID: 'group1',
        userID: 'user1',
        groupCategoryAxisID: 'axis1',
        name: id,
        order: 0,
        locationOrders: {},
        keywords: keywords,
        color: null,
        iconName: null,
      );
  GroupCategoryKeyword exact(String keyword) => GroupCategoryKeyword(
    keyword: keyword,
    matchingType: GroupCategoryKeywordMatchingType.exact,
  );
  GroupCategoryKeyword partial(String keyword) => GroupCategoryKeyword(
    keyword: keyword,
    matchingType: GroupCategoryKeywordMatchingType.partial,
  );

  group('keywordsAfterItemMove', () {
    test('移動先カテゴリには message を exact キーワードとして追加する', () {
      final result = keywordsAfterItemMove(
        category: category('dest', [exact('牛乳')]),
        itemMessage: 'パン',
        destinationCategoryID: 'dest',
      );
      expect(result, isNotNull);
      expect(result!.map((keyword) => keyword.keyword), ['牛乳', 'パン']);
      expect(
        result.firstWhere((keyword) => keyword.keyword == 'パン').matchingType,
        GroupCategoryKeywordMatchingType.exact,
      );
    });

    test('移動先に同じ exact が既にあれば変更なし(null)', () {
      final result = keywordsAfterItemMove(
        category: category('dest', [exact('パン')]),
        itemMessage: 'パン',
        destinationCategoryID: 'dest',
      );
      expect(result, isNull);
    });

    test('移動元(移動先以外)からは message の exact を削除する', () {
      final result = keywordsAfterItemMove(
        category: category('src', [exact('パン'), exact('牛乳')]),
        itemMessage: 'パン',
        destinationCategoryID: 'dest',
      );
      expect(result, isNotNull);
      expect(result!.map((keyword) => keyword.keyword), ['牛乳']);
    });

    test('partial キーワードは削除しない(削除対象は exact のみ)', () {
      final result = keywordsAfterItemMove(
        category: category('src', [partial('パン')]),
        itemMessage: 'パン',
        destinationCategoryID: 'dest',
      );
      // partial は残すため変更なし(null)。元カテゴリの partial は他アイテムにも効くため消さない。
      // それでも移動が成立するのは、分類エンジン findMatchingCategoryID が移動先の exact を
      // 元カテゴリの partial より優先するため(category_matcher_test の exact 優先テスト参照)。
      expect(result, isNull);
    });

    test('未分類へ移動(destination=null)時、元カテゴリから exact を削除する', () {
      final result = keywordsAfterItemMove(
        category: category('src', [exact('パン')]),
        itemMessage: 'パン',
        destinationCategoryID: null,
      );
      expect(result, isNotNull);
      expect(result, isEmpty);
    });
  });
}
