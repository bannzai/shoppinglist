// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupShoppingLocation _$GroupShoppingLocationFromJson(
        Map<String, dynamic> json) =>
    _GroupShoppingLocation(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geofenceRadiusMeters: (json['geofenceRadiusMeters'] as num?)?.toDouble(),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$GroupShoppingLocationToJson(
        _GroupShoppingLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'geofenceRadiusMeters': instance.geofenceRadiusMeters,
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
