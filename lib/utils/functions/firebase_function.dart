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

  /// URLからWebページを取得し、AIで買い物リストアイテムを生成する。
  Future<List<String>> generateShoppingListItemsFromURL({
    required String url,
  }) async {
    final result = await httpsCallable('generateShoppingListItemsFromURL').call(
      {
        'url': url,
      },
    );
    debugPrint('generateShoppingListItemsFromURL.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }

    final list = response['data']['shoppingListItems'] as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }

  Future<void> removeGroupMember({
    required String groupID,
    required String targetUserID,
  }) async {
    final result = await httpsCallable('removeGroupMember').call(
      {
        'groupID': groupID,
        'targetUserID': targetUserID,
      },
    );
    debugPrint('removeGroupMember.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  Future<void> sendShoppingListUpdateNotification({
    required String groupID,
    required String shoppingListID,
    required String? shoppingListName,
    required List<String> targetUserIDs,
  }) async {
    final result =
        await httpsCallable('sendShoppingListUpdateNotification').call(
      {
        'groupID': groupID,
        'shoppingListID': shoppingListID,
        'shoppingListName': shoppingListName,
        'targetUserIDs': targetUserIDs,
      },
    );
    debugPrint('sendShoppingListUpdateNotification.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  /// サーバー側で上限チェックを行った上で買い物リストを作成する。
  Future<String> createShoppingList({
    required String groupID,
    required String createUserID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) async {
    final result = await httpsCallable('createShoppingList').call(
      {
        'groupID': groupID,
        'createUserID': createUserID,
        'shoppingLocationID': shoppingLocationID,
        'duplicatedFromGroupShoppingListID': duplicatedFromGroupShoppingListID,
      },
    );
    debugPrint('createShoppingList.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
    return response['data']['shoppingListID'] as String;
  }

  /// サーバー側で上限チェックを行った上でグループを作成する。
  /// `iconName` は `design_handoff_shoppinglist/preview/screens-groups.jsx#GroupCreatePage`
  /// で許容される 6 種 (home/cart/fork/cookie/pets/bag) のいずれか。
  Future<void> createGroup({
    required String createUserID,
    required String? name,
    required bool setAsDefault,
    required String iconName,
  }) async {
    final result = await httpsCallable('createGroup').call(
      {
        'createUserID': createUserID,
        'name': name,
        'setAsDefault': setAsDefault,
        'iconName': iconName,
      },
    );
    debugPrint('createGroup.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  Future<void> updateGroupName({
    required String groupID,
    required String name,
  }) async {
    final result = await httpsCallable('updateGroupName').call(
      {
        'groupID': groupID,
        'name': name,
      },
    );
    debugPrint('updateGroupName.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  /// 商品写真をFirebase Storageにアップロードし、ダウンロードURLを返す。
  Future<String> uploadShoppingListItemImage({
    required String groupID,
    required String shoppingListID,
    required String itemID,
    required String mimeType,
    required String base64Image,
  }) async {
    final result = await httpsCallable('uploadShoppingListItemImage').call(
      {
        'groupID': groupID,
        'shoppingListID': shoppingListID,
        'itemID': itemID,
        'mimeType': mimeType,
        'base64Image': base64Image,
      },
    );
    // token付きURLを含む可能性があるためresult.dataはログ出力しない
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
    return response['data']['imageURL'] as String;
  }

  /// RevenueCat Promotions API経由でプレミアムEntitlementを付与する。
  /// 開発者オプションでのテスト用。
  Future<void> grantPromotionalPremium({
    required String duration,
  }) async {
    final result = await httpsCallable('grantPromotionalPremium').call(
      {
        'duration': duration,
      },
    );
    debugPrint('grantPromotionalPremium.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  /// RevenueCat Promotions API経由で付与済みのプレミアムEntitlementを取り消す。
  /// 開発者オプションでのテスト用（実購入由来のEntitlementには影響しない）。
  Future<void> revokePromotionalPremium() async {
    final result = await httpsCallable('revokePromotionalPremium').call();
    debugPrint('revokePromotionalPremium.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  /// カテゴリのロケーション別表示順序をテスト用に設定する。
  /// [firstCategoryName] の順序を 0、[secondCategoryName] の順序を 1 に設定する。
  /// 開発者オプションでのテスト用。
  Future<void> setupTestCategoryLocationOrder({
    required String groupID,
    required String locationName,
    required String firstCategoryName,
    required String secondCategoryName,
  }) async {
    final result = await httpsCallable('setupTestCategoryLocationOrder').call({
      'groupID': groupID,
      'locationName': locationName,
      'firstCategoryName': firstCategoryName,
      'secondCategoryName': secondCategoryName,
    });
    debugPrint('setupTestCategoryLocationOrder.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
  }

  /// 商品写真をFirebase Storageから削除する。
  Future<void> deleteShoppingListItemImage({
    required String groupID,
    required String shoppingListID,
    required String itemID,
  }) async {
    final result = await httpsCallable('deleteShoppingListItemImage').call(
      {
        'groupID': groupID,
        'shoppingListID': shoppingListID,
        'itemID': itemID,
      },
    );
    debugPrint('deleteShoppingListItemImage.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
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
