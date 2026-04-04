// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserAIUsage _$UserAIUsageFromJson(Map<String, dynamic> json) => _UserAIUsage(
      id: json['id'] as String,
      userID: json['userID'] as String,
      imageRecognitionCount: (json['imageRecognitionCount'] as num).toInt(),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$UserAIUsageToJson(_UserAIUsage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userID': instance.userID,
      'imageRecognitionCount': instance.imageRecognitionCount,
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
