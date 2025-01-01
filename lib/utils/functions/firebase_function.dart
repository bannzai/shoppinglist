import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');

extension FirebaseFunctionsExt on FirebaseFunctions {
  Future<List<String>> generateMemoRowsFromImage({required String imageBase64}) async {
    final result = await httpsCallable('generateMemoRowsFromImage').call(
      {
        'imageBase64': imageBase64,
      },
    );
    debugPrint('generateMemoRowsFromImage.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }

    return response['data']['memoRows'] as List<String>;
  }
}

// Map<String, dynamic>.fromだけだとネストした子要素が_Map<Object? Object?>のままになる
// 以下のエラーを回避する _TypeError (type '_Map<Object?, Object?>' is not a subtype of type 'Map<String, dynamic>' in type cast)
Map<String, dynamic> mapToJSON(Map<dynamic, dynamic> map) {
  for (var key in map.keys) {
    if (map[key] is Map) {
      map[key] = mapToJSON(map[key]);
    } else if (map[key] is List) {
      map[key] = map[key].map((e) {
        if (e is Map) {
          return mapToJSON(e);
        }
        return e;
      }).toList();
    }
  }
  return Map<String, dynamic>.from(map);
}
