import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

// Genkitはus-central1にしか対応していない
final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

extension FirebaseFunctionsExt on FirebaseFunctions {
  /// 招待コードと有効期限を Functions から取得する。
  /// 戻り値の `expiresDateTime` は `Functions` が ISO8601 文字列で返したものを
  /// `DateTime.parse` した値。
  Future<({String invitationCode, DateTime expiresDateTime})>
      createGroupInvitation({
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
    return (
      invitationCode: response['data']['invitationCode'] as String,
      expiresDateTime:
          DateTime.parse(response['data']['expiresDateTime'] as String),
    );
  }

  /// 招待コードを使ってグループに参加する。
  /// 戻り値は参加したグループの ID (Firestore doc ID)。
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

  /// base64エンコードした画像をAIで解析し、買い物リストアイテムを生成する。
  /// 戻り値は生成されたアイテム名のリスト。
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

  /// 未分類の買い物アイテムを AI でカテゴリに分類する。
  /// アイテムにカテゴリIDは持たせず、(アイテム名, カテゴリ名) の対応のみを返す。
  /// 永続化（キーワード追記・カテゴリ作成）はクライアント側で行う。
  Future<List<({String name, String categoryName})>>
      categorizeShoppingListItems({
    required List<String> itemNames,
    required List<String> existingCategoryNames,
  }) async {
    final result = await httpsCallable('categorizeShoppingListItems').call(
      {
        'itemNames': itemNames,
        'existingCategoryNames': existingCategoryNames,
      },
    );
    debugPrint('categorizeShoppingListItems.result: ${result.data}');
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }

    final list = response['data']['categorizedItems'] as List<dynamic>;
    return list.map((e) {
      final map = mapToJSON(e as Map);
      return (
        name: map['name'].toString(),
        categoryName: map['categoryName'].toString(),
      );
    }).toList();
  }

  /// グループから指定したメンバーを削除する。
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

  /// 買い物リストの更新を、指定したグループメンバーにプッシュ通知で知らせる。
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

  /// サーバー側で上限チェックを行った上でグループを作成する。
  /// `iconName` は `design_handoff_shoppinglist/preview/screens-groups.jsx#GroupCreatePage`
  /// で許容される 6 種 (home/cart/fork/cookie/pets/bag) のいずれか。
  /// 戻り値は作成されたグループの ID (Firestore doc ID)。
  Future<String> createGroup({
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
    return response['data']['groupID'] as String;
  }

  /// グループ名を更新する。
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
    // 引数なし call() は data が null になり、GenKit の inputSchema
    // z.object({}) の検証が INTERNAL で落ちるため空オブジェクトを渡す。
    final result = await httpsCallable('revokePromotionalPremium').call(
      <String, dynamic>{},
    );
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

  /// レシート画像をFirebase Storageにアップロードし、ダウンロードURLを返す。
  Future<String> uploadReceiptImage({
    required String groupID,
    required String shoppingListID,
    required String receiptID,
    required String base64Image,
  }) async {
    final result = await httpsCallable('uploadReceiptImage').call(
      {
        'groupID': groupID,
        'shoppingListID': shoppingListID,
        'receiptID': receiptID,
        'base64Image': base64Image,
      },
    );
    final response = mapToJSON(result.data);
    if (response['result'] != 'OK') {
      throw Exception(response['error']['message']);
    }
    // Storage path を返す（download URL は Firestore に保存しない）。
    return response['data']['storagePath'] as String;
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
