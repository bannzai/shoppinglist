// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIUsage _$AIUsageFromJson(Map<String, dynamic> json) => _AIUsage(
      id: json['id'] as String,
      userID: json['userID'] as String,
      imageRecognitionCount: (json['imageRecognitionCount'] as num).toInt(),
      urlRecognitionCount: (json['urlRecognitionCount'] as num?)?.toInt() ?? 0,
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$AIUsageToJson(_AIUsage instance) => <String, dynamic>{
      'id': instance.id,
      'userID': instance.userID,
      'imageRecognitionCount': instance.imageRecognitionCount,
      'urlRecognitionCount': instance.urlRecognitionCount,
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
