// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupCategory _$GroupCategoryFromJson(Map<String, dynamic> json) =>
    _GroupCategory(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      userID: json['userID'] as String,
      groupCategoryAxisID: json['groupCategoryAxisID'] as String,
      name: json['name'] as String,
      order: (json['order'] as num).toInt(),
      locationOrders: Map<String, int>.from(json['locationOrders'] as Map),
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => GroupCategoryKeyword.fromJson(e as Map<String, dynamic>))
          .toList(),
      color: json['color'] as String?,
      iconName: json['iconName'] as String?,
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$GroupCategoryToJson(_GroupCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'userID': instance.userID,
      'groupCategoryAxisID': instance.groupCategoryAxisID,
      'name': instance.name,
      'order': instance.order,
      'locationOrders': instance.locationOrders,
      'keywords': instance.keywords.map((e) => e.toJson()).toList(),
      'color': instance.color,
      'iconName': instance.iconName,
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
