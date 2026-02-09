// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextShoppingListItem _$TextShoppingListItemFromJson(
        Map<String, dynamic> json) =>
    TextShoppingListItem(
      id: json['id'] as String,
      shoppingListID: json['shoppingListID'] as String,
      message: json['message'] as String,
      order: (json['order'] as num).toInt(),
      status: $enumDecodeNullable(
              _$ShoppingListItemStatusEnumMap, json['status']) ??
          ShoppingListItemStatus.unchecked,
      description: json['description'] as String?,
      color: json['color'] as String?,
      categoryID: json['categoryID'] as String?,
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
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TextShoppingListItemToJson(
        TextShoppingListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shoppingListID': instance.shoppingListID,
      'message': instance.message,
      'order': instance.order,
      'status': _$ShoppingListItemStatusEnumMap[instance.status]!,
      'description': instance.description,
      'color': instance.color,
      'categoryID': instance.categoryID,
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
      'type': instance.$type,
    };

const _$ShoppingListItemStatusEnumMap = {
  ShoppingListItemStatus.checked: 'checked',
  ShoppingListItemStatus.unchecked: 'unchecked',
};

LinkShoppingListItem _$LinkShoppingListItemFromJson(
        Map<String, dynamic> json) =>
    LinkShoppingListItem(
      id: json['id'] as String,
      shoppingListID: json['shoppingListID'] as String,
      url: json['url'] as String,
      order: (json['order'] as num).toInt(),
      metadataTitle: json['metadataTitle'] as String?,
      metadataDescription: json['metadataDescription'] as String?,
      metadataImageURL: json['metadataImageURL'] as String?,
      status: $enumDecodeNullable(
              _$ShoppingListItemStatusEnumMap, json['status']) ??
          ShoppingListItemStatus.unchecked,
      description: json['description'] as String?,
      color: json['color'] as String?,
      categoryID: json['categoryID'] as String?,
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
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$LinkShoppingListItemToJson(
        LinkShoppingListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shoppingListID': instance.shoppingListID,
      'url': instance.url,
      'order': instance.order,
      'metadataTitle': instance.metadataTitle,
      'metadataDescription': instance.metadataDescription,
      'metadataImageURL': instance.metadataImageURL,
      'status': _$ShoppingListItemStatusEnumMap[instance.status]!,
      'description': instance.description,
      'color': instance.color,
      'categoryID': instance.categoryID,
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
      'type': instance.$type,
    };
