// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_category_axis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupCategoryAxis _$GroupCategoryAxisFromJson(Map<String, dynamic> json) =>
    _GroupCategoryAxis(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      userID: json['userID'] as String,
      name: json['name'] as String,
      order: (json['order'] as num).toInt(),
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

Map<String, dynamic> _$GroupCategoryAxisToJson(_GroupCategoryAxis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'userID': instance.userID,
      'name': instance.name,
      'order': instance.order,
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
