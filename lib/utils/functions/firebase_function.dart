import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/entity/inquiry_category.dart';

// Functions は asia-northeast1(東京) にデプロイしている。
// Firestore / Storage と同一リージョンに揃え、クロスリージョン往復を排除する。
final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');

/// Functions呼び出しがバックエンドから `result: "NG"` を受け取った場合に投げる例外。
/// [message] はバックエンドが返した `error.message` をそのまま保持する。
/// 素の `Exception` は `toString()` が `"Exception: $message"` になり、
/// 規約（エラーメッセージは加工しない）に反して余分なプレフィックスが
/// 画面に表示されてしまうため、代わりにこの例外を使う。
class FunctionsCallException implements Exception {
  FunctionsCallException(this.message);

  /// バックエンドが返したエラーメッセージ。
  final String message;

  @override
  String toString() => message;
}

/// Functions呼び出しの [response] が NG の場合、[FunctionsCallException] を投げる。
void _throwIfNotOK(Map<String, dynamic> response) {
  if (response['result'] != 'OK') {
    throw FunctionsCallException(response['error']['message'] as String);
  }
}

extension FirebaseFunctionsExt on FirebaseFunctions {
  /// 招待コードと有効期限を Functions から取得する。
  /// 戻り値の `expiresDateTime` は `Functions` が ISO8601 文字列で返したものを
  /// `DateTime.parse` した値。
  Future<({String invitationCode, DateTime expiresDateTime})>
  createGroupInvitation({required String groupID}) async {
    final result = await httpsCallable(
      'createGroupInvitation',
    ).call({'groupID': groupID});
    debugPrint('createGroupInvitation.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
    return (
      invitationCode: response['data']['invitationCode'] as String,
      expiresDateTime: DateTime.parse(
        response['data']['expiresDateTime'] as String,
      ),
    );
  }

  /// 招待コードを使ってグループに参加する。
  /// 戻り値は参加したグループの ID (Firestore doc ID)。
  Future<String> acceptGroupInvitation({required String invitationCode}) async {
    final result = await httpsCallable(
      'acceptGroupInvitation',
    ).call({'invitationCode': invitationCode});
    debugPrint('acceptGroupInvitation.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
    return response['data']['groupID'] as String;
  }

  /// base64エンコードした画像をAIで解析し、買い物リストアイテムを生成する。
  /// 戻り値は生成されたアイテム名のリスト。
  /// 生成に使った元画像はサーバー側で [groupID] / [shoppingListID] の買い物リストに
  /// 保存される（最大5枚。超過分は古い順に削除。Issue #530）。
  Future<List<String>> generateShoppingListItemsFromImage({
    required String mimeType,
    required String base64Image,
    required String groupID,
    required String shoppingListID,
  }) async {
    final result = await httpsCallable(
      'generateShoppingListItemsFromImage',
    ).call({
      'mimeType': mimeType,
      'base64Image': base64Image,
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });
    debugPrint('generateShoppingListItemsFromImage.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);

    // as List<String> に直接変換するとExceptionが発生するため、一旦List<dynamic>に変換してからStringに変換する
    final list = response['data']['shoppingListItems'] as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }

  /// URLからWebページを取得し、AIで買い物リストアイテムを生成する。
  Future<List<String>> generateShoppingListItemsFromURL({
    required String url,
  }) async {
    final result = await httpsCallable(
      'generateShoppingListItemsFromURL',
    ).call({'url': url});
    debugPrint('generateShoppingListItemsFromURL.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);

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
    final result = await httpsCallable('categorizeShoppingListItems').call({
      'itemNames': itemNames,
      'existingCategoryNames': existingCategoryNames,
    });
    debugPrint('categorizeShoppingListItems.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);

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
    final result = await httpsCallable(
      'removeGroupMember',
    ).call({'groupID': groupID, 'targetUserID': targetUserID});
    debugPrint('removeGroupMember.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
  }

  /// 買い物リストの更新を、指定したグループメンバーにプッシュ通知で知らせる。
  Future<void> sendShoppingListUpdateNotification({
    required String groupID,
    required String shoppingListID,
    required String? shoppingListName,
    required List<String> targetUserIDs,
  }) async {
    final result = await httpsCallable(
      'sendShoppingListUpdateNotification',
    ).call({
      'groupID': groupID,
      'shoppingListID': shoppingListID,
      'shoppingListName': shoppingListName,
      'targetUserIDs': targetUserIDs,
    });
    debugPrint('sendShoppingListUpdateNotification.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
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
    final result = await httpsCallable('createGroup').call({
      'createUserID': createUserID,
      'name': name,
      'setAsDefault': setAsDefault,
      'iconName': iconName,
    });
    debugPrint('createGroup.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
    return response['data']['groupID'] as String;
  }

  /// グループ名を更新する。
  Future<void> updateGroupName({
    required String groupID,
    required String name,
  }) async {
    final result = await httpsCallable(
      'updateGroupName',
    ).call({'groupID': groupID, 'name': name});
    debugPrint('updateGroupName.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
  }

  /// 商品写真をFirebase Storageにアップロードし、ダウンロードURLを返す。
  Future<String> uploadShoppingListItemImage({
    required String groupID,
    required String shoppingListID,
    required String itemID,
    required String mimeType,
    required String base64Image,
  }) async {
    final result = await httpsCallable('uploadShoppingListItemImage').call({
      'groupID': groupID,
      'shoppingListID': shoppingListID,
      'itemID': itemID,
      'mimeType': mimeType,
      'base64Image': base64Image,
    });
    // token付きURLを含む可能性があるためresult.dataはログ出力しない
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
    return response['data']['imageURL'] as String;
  }

  /// RevenueCat Promotions API経由でプレミアムEntitlementを付与する。
  /// 開発者オプションでのテスト用。
  Future<void> grantPromotionalPremium({required String duration}) async {
    final result = await httpsCallable(
      'grantPromotionalPremium',
    ).call({'duration': duration});
    debugPrint('grantPromotionalPremium.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
  }

  /// RevenueCat Promotions API経由で付与済みのプレミアムEntitlementを取り消す。
  /// 開発者オプションでのテスト用（実購入由来のEntitlementには影響しない）。
  Future<void> revokePromotionalPremium() async {
    // 引数なし call() は data が null になり、GenKit の inputSchema
    // z.object({}) の検証が INTERNAL で落ちるため空オブジェクトを渡す。
    final result = await httpsCallable(
      'revokePromotionalPremium',
    ).call(<String, dynamic>{});
    debugPrint('revokePromotionalPremium.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
  }

  /// お問い合わせを送信する。Firestore へのスナップショット保存と Slack 通知は
  /// Functions 側で行う。戻り値は作成された問い合わせの ID。
  Future<String> submitInquiry({
    required String email,
    required InquiryCategory categoryType,
    required String content,
    required String platform,
    required String appVersion,
  }) async {
    final result = await httpsCallable('submitInquiry').call({
      'email': email,
      'categoryType': categoryType.wireValue,
      'content': content,
      'platform': platform,
      'appVersion': appVersion,
    });
    debugPrint('submitInquiry.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
    return response['data']['inquiryID'] as String;
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
    _throwIfNotOK(response);
  }

  /// 商品写真をFirebase Storageから削除する。
  Future<void> deleteShoppingListItemImage({
    required String groupID,
    required String shoppingListID,
    required String itemID,
  }) async {
    final result = await httpsCallable('deleteShoppingListItemImage').call({
      'groupID': groupID,
      'shoppingListID': shoppingListID,
      'itemID': itemID,
    });
    debugPrint('deleteShoppingListItemImage.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
  }

  /// 買い物リストを削除する。
  /// Firestore は親ドキュメント削除でサブコレクションを自動削除しないため、
  /// リスト本体に加えて items / receipts サブコレクションと Storage 上の画像
  /// （レシート画像・商品写真）も Functions の Admin SDK で再帰削除する（Issue #421）。
  Future<void> deleteShoppingList({
    required String groupID,
    required String shoppingListID,
  }) async {
    final result = await httpsCallable(
      'deleteShoppingList',
    ).call({'groupID': groupID, 'shoppingListID': shoppingListID});
    debugPrint('deleteShoppingList.result: ${result.data}');
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
  }

  /// レシート画像をFirebase Storageにアップロードし、ダウンロードURLを返す。
  Future<String> uploadReceiptImage({
    required String groupID,
    required String shoppingListID,
    required String receiptID,
    required String base64Image,
  }) async {
    final result = await httpsCallable('uploadReceiptImage').call({
      'groupID': groupID,
      'shoppingListID': shoppingListID,
      'receiptID': receiptID,
      'base64Image': base64Image,
    });
    final response = mapToJSON(result.data);
    _throwIfNotOK(response);
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
      map[key] =
          map[key].map((e) {
            if (e is Map) {
              return mapToJSON(e);
            }
            return e;
          }).toList();
    }
  }
  return Map<String, dynamic>.from(map);
}
