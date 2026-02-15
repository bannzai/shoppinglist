// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list_item_category_keyword.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupShoppingListItemCategoryKeyword
    _$GroupShoppingListItemCategoryKeywordFromJson(Map<String, dynamic> json) =>
        _GroupShoppingListItemCategoryKeyword(
          keyword: json['keyword'] as String,
          matchingType: $enumDecode(
              _$GroupShoppingListItemCategoryKeywordMatchingTypeEnumMap,
              json['matchingType']),
        );

Map<String, dynamic> _$GroupShoppingListItemCategoryKeywordToJson(
        _GroupShoppingListItemCategoryKeyword instance) =>
    <String, dynamic>{
      'keyword': instance.keyword,
      'matchingType': _$GroupShoppingListItemCategoryKeywordMatchingTypeEnumMap[
          instance.matchingType]!,
    };

const _$GroupShoppingListItemCategoryKeywordMatchingTypeEnumMap = {
  GroupShoppingListItemCategoryKeywordMatchingType.exact: 'exact',
  GroupShoppingListItemCategoryKeywordMatchingType.partial: 'partial',
};
