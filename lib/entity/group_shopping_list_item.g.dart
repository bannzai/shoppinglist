// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupShoppingListItem _$GroupShoppingListItemFromJson(
        Map<String, dynamic> json) =>
    _GroupShoppingListItem(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      shoppingListID: json['shoppingListID'] as String,
      userID: json['userID'] as String,
      message: json['message'] as String,
      order: (json['order'] as num).toInt(),
      status: $enumDecodeNullable(
              _$GroupShoppingListItemStatusEnumMap, json['status']) ??
          GroupShoppingListItemStatus.unchecked,
      description: json['description'] as String?,
      color: json['color'] as String?,
      reminderDateTime: const NullableTimestampConverter()
          .fromJson(json['reminderDateTime'] as Timestamp?),
      checkedByUserID: json['checkedByUserID'] as String?,
      lastCheckedDateTime: const NullableTimestampConverter()
          .fromJson(json['lastCheckedDateTime'] as Timestamp?),
      lastEditedByUserID: json['lastEditedByUserID'] as String?,
      lastEditedDateTime: const NullableTimestampConverter()
          .fromJson(json['lastEditedDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$GroupShoppingListItemToJson(
        _GroupShoppingListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'shoppingListID': instance.shoppingListID,
      'userID': instance.userID,
      'message': instance.message,
      'order': instance.order,
      'status': _$GroupShoppingListItemStatusEnumMap[instance.status]!,
      'description': instance.description,
      'color': instance.color,
      'reminderDateTime':
          const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'checkedByUserID': instance.checkedByUserID,
      'lastCheckedDateTime': const NullableTimestampConverter()
          .toJson(instance.lastCheckedDateTime),
      'lastEditedByUserID': instance.lastEditedByUserID,
      'lastEditedDateTime': const NullableTimestampConverter()
          .toJson(instance.lastEditedDateTime),
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
