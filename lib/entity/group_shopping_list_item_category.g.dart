// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list_item_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupShoppingListItemCategory _$GroupShoppingListItemCategoryFromJson(
        Map<String, dynamic> json) =>
    _GroupShoppingListItemCategory(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      groupShoppingListItemCategoryAxisID:
          json['groupShoppingListItemCategoryAxisID'] as String,
      name: json['name'] as String,
      order: (json['order'] as num).toInt(),
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => GroupShoppingListItemCategoryKeyword.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$GroupShoppingListItemCategoryToJson(
        _GroupShoppingListItemCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'groupShoppingListItemCategoryAxisID':
          instance.groupShoppingListItemCategoryAxisID,
      'name': instance.name,
      'order': instance.order,
      'keywords': instance.keywords.map((e) => e.toJson()).toList(),
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
