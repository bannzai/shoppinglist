import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';

void main() {
  group('isSafeGroupCategoryKeywordRegex', () {
    test('量指定子を含むグループに繰り返しの量指定子が付く入れ子は拒否する', () {
      for (final keyword in [
        r'^(a+)+$',
        r'(a*)*',
        r'(a+)*b',
        r'(?:ab+)+',
        r'(a?)+',
        r'(a+){2,}',
        r'((a+))+',
        r'((ab)+)+',
        r'(x|y(z+))+',
        r'(?<word>\w+)+',
      ]) {
        expect(
          isSafeGroupCategoryKeywordRegex(keyword: keyword),
          isFalse,
          reason: keyword,
        );
      }
    });

    test('入れ子にならない量指定子・文字クラス・エスケープされた括弧は許可する', () {
      for (final keyword in [
        r'^a+$',
        r'(ab)+',
        r'(a+)?',
        r'(a+)b+',
        r'[(+)]+',
        r'\(a+\)+',
        r'(a+)\+',
        r'(a+){x}',
        r'^(牛|豚|鶏)肉$',
        r'(?:りんご|みかん)\d*個',
      ]) {
        expect(
          isSafeGroupCategoryKeywordRegex(keyword: keyword),
          isTrue,
          reason: keyword,
        );
      }
    });

    test('上限の長さまでは許可し、上限を超えると拒否する', () {
      expect(
        isSafeGroupCategoryKeywordRegex(
          keyword: 'a' * groupCategoryKeywordRegexMaxLength,
        ),
        isTrue,
      );
      expect(
        isSafeGroupCategoryKeywordRegex(
          keyword: 'a' * (groupCategoryKeywordRegexMaxLength + 1),
        ),
        isFalse,
      );
    });
  });
}
