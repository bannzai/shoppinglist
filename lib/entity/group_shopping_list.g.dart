// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupShoppingList _$GroupShoppingListFromJson(Map<String, dynamic> json) =>
    _GroupShoppingList(
      id: json['id'] as String,
      createUserID: json['createUserID'] as String,
      groupID: json['groupID'] as String,
      name: json['name'] as String? ?? '',
      status:
          $enumDecodeNullable(
            _$GroupShoppingListStatusEnumMap,
            json['status'],
          ) ??
          GroupShoppingListStatus.active,
      autoNotifyEnabled: json['autoNotifyEnabled'] as bool? ?? false,
      shoppingLocationID: json['shoppingLocationID'] as String?,
      duplicatedFromGroupShoppingListID:
          json['duplicatedFromGroupShoppingListID'] as String?,
      ttlExpiresDateTime: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['ttlExpiresDateTime'],
        const TimestampConverter().fromJson,
      ),
      createdDateTime: const ClientCreatedTimestamp().fromJson(
        json['createdDateTime'] as Timestamp?,
      ),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(
        json['updatedDateTime'] as Timestamp?,
      ),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(
        json['serverCreatedDateTime'],
      ),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(
        json['serverUpdatedDateTime'],
      ),
    );

Map<String, dynamic> _$GroupShoppingListToJson(_GroupShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createUserID': instance.createUserID,
      'groupID': instance.groupID,
      'name': instance.name,
      'status': _$GroupShoppingListStatusEnumMap[instance.status]!,
      'autoNotifyEnabled': instance.autoNotifyEnabled,
      'shoppingLocationID': instance.shoppingLocationID,
      'duplicatedFromGroupShoppingListID':
          instance.duplicatedFromGroupShoppingListID,
      'ttlExpiresDateTime': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.ttlExpiresDateTime,
        const TimestampConverter().toJson,
      ),
      'createdDateTime': const ClientCreatedTimestamp().toJson(
        instance.createdDateTime,
      ),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(
        instance.updatedDateTime,
      ),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(
        instance.serverCreatedDateTime,
      ),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(
        instance.serverUpdatedDateTime,
      ),
    };

const _$GroupShoppingListStatusEnumMap = {
  GroupShoppingListStatus.active: 'active',
  GroupShoppingListStatus.done: 'done',
  GroupShoppingListStatus.archived: 'archived',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
