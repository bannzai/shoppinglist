import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

// Genkitはus-central1にしか対応していない
final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

extension FirebaseFunctionsExt on FirebaseFunctions {
  Future<String> createGroupInvitation({
    required String groupID,
  }) async {
    final result = await httpsCallable('createGroupInvitation').call(
      {
        'groupID': groupID,
      },
    );
    debugPrint('createGroupInvitation.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
    return response['data']['invitationCode'] as String;
  }

  Future<String> acceptGroupInvitation({
    required String invitationCode,
  }) async {
    final result = await httpsCallable('acceptGroupInvitation').call(
      {
        'invitationCode': invitationCode,
      },
    );
    debugPrint('acceptGroupInvitation.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
    return response['data']['groupID'] as String;
  }

  Future<List<String>> generateShoppingListItemsFromImage({
    required String mimeType,
    required String base64Image,
  }) async {
    final result =
        await httpsCallable('generateShoppingListItemsFromImage').call(
      {
        'mimeType': mimeType,
        'base64Image': base64Image,
      },
    );
    debugPrint('generateShoppingListItemsFromImage.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }

    // as List<String> に直接変換するとExceptionが発生するため、一旦List<dynamic>に変換してからStringに変換する
    final list = response['data']['shoppingListItems'] as List<dynamic>;
    return list.map((e) => e.toString()).toList();
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
