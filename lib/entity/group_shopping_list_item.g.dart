// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextGroupShoppingListItem _$TextGroupShoppingListItemFromJson(
        Map<String, dynamic> json) =>
    TextGroupShoppingListItem(
      id: json['id'] as String,
      shoppingListID: json['shoppingListID'] as String,
      message: json['message'] as String,
      order: (json['order'] as num).toInt(),
      status: $enumDecodeNullable(
              _$GroupShoppingListItemStatusEnumMap, json['status']) ??
          GroupShoppingListItemStatus.unchecked,
      description: json['description'] as String?,
      color: json['color'] as String?,
      groupShoppingListItemCategoryID:
          json['groupShoppingListItemCategoryID'] as String?,
      reminderDateTime: const NullableTimestampConverter()
          .fromJson(json['reminderDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$TextGroupShoppingListItemToJson(
        TextGroupShoppingListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shoppingListID': instance.shoppingListID,
      'message': instance.message,
      'order': instance.order,
      'status': _$GroupShoppingListItemStatusEnumMap[instance.status]!,
      'description': instance.description,
      'color': instance.color,
      'groupShoppingListItemCategoryID':
          instance.groupShoppingListItemCategoryID,
      'reminderDateTime':
          const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };

const _$GroupShoppingListItemStatusEnumMap = {
  GroupShoppingListItemStatus.checked: 'checked',
  GroupShoppingListItemStatus.unchecked: 'unchecked',
};
