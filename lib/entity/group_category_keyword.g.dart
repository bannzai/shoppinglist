// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_category_keyword.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupCategoryKeyword _$GroupCategoryKeywordFromJson(
  Map<String, dynamic> json,
) => _GroupCategoryKeyword(
  keyword: json['keyword'] as String,
  matchingType: $enumDecode(
    _$GroupCategoryKeywordMatchingTypeEnumMap,
    json['matchingType'],
  ),
);

Map<String, dynamic> _$GroupCategoryKeywordToJson(
  _GroupCategoryKeyword instance,
) => <String, dynamic>{
  'keyword': instance.keyword,
  'matchingType':
      _$GroupCategoryKeywordMatchingTypeEnumMap[instance.matchingType]!,
};

const _$GroupCategoryKeywordMatchingTypeEnumMap = {
  GroupCategoryKeywordMatchingType.exact: 'exact',
  GroupCategoryKeywordMatchingType.partial: 'partial',
  GroupCategoryKeywordMatchingType.regex: 'regex',
};
