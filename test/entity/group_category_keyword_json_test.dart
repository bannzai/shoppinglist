import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';

void main() {
  group('GroupCategoryKeyword JSON', () {
    test('matchingType.regex のラウンドトリップ', () {
      const keyword = GroupCategoryKeyword(
        keyword: r'^肉|魚介$',
        matchingType: GroupCategoryKeywordMatchingType.regex,
      );
      final json = keyword.toJson();
      expect(json['matchingType'], 'regex');
      expect(
        GroupCategoryKeyword.fromJson(json).matchingType,
        GroupCategoryKeywordMatchingType.regex,
      );
    });

    test('3 種類すべての matchingType がデシリアライズできる', () {
      for (final entry
          in const {
            'exact': GroupCategoryKeywordMatchingType.exact,
            'partial': GroupCategoryKeywordMatchingType.partial,
            'regex': GroupCategoryKeywordMatchingType.regex,
          }.entries) {
        final keyword = GroupCategoryKeyword.fromJson({
          'keyword': 'にんじん',
          'matchingType': entry.key,
        });
        expect(keyword.matchingType, entry.value);
      }
    });
  });
}
