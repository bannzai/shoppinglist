// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) =>
    _ShoppingList(
      id: json['id'] as String,
      createUserID: json['createUserID'] as String,
      groupID: json['groupID'] as String,
      name: json['name'] as String? ?? '',
      status:
          $enumDecodeNullable(_$ShoppingListStatusEnumMap, json['status']) ??
              ShoppingListStatus.active,
      shoppingLocationID: json['shoppingLocationID'] as String?,
      duplicatedFromID: json['duplicatedFromID'] as String?,
      ttlExpiresDateTime: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['ttlExpiresDateTime'], const TimestampConverter().fromJson),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$ShoppingListToJson(_ShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createUserID': instance.createUserID,
      'groupID': instance.groupID,
      'name': instance.name,
      'status': _$ShoppingListStatusEnumMap[instance.status]!,
      'shoppingLocationID': instance.shoppingLocationID,
      'duplicatedFromID': instance.duplicatedFromID,
      'ttlExpiresDateTime': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.ttlExpiresDateTime, const TimestampConverter().toJson),
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };

const _$ShoppingListStatusEnumMap = {
  ShoppingListStatus.active: 'active',
  ShoppingListStatus.done: 'done',
  ShoppingListStatus.archived: 'archived',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
