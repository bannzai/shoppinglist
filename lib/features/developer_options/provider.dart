import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/app_user_private.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/resolver/database.dart';

/// デバッグユーザーIDを生成する。
/// 形式: {realUID}_debug_{index}
String debugUserID({required String realUserID, required int index}) =>
    '${realUserID}_debug_$index';

/// デバッグユーザーの Firestore ドキュメントを作成する。
class DebugUserCreate {
  Future<void> call({required String debugUID}) async {
    final userDB = UserDatabase(userID: debugUID);
    final user = AppUser(id: debugUID, name: 'Debug User ($debugUID)');
    await userDB.userReference().set(user);
    debugPrint('[DebugUserCreate] ユーザー作成完了: $debugUID');
  }
}

/// デバッグユーザーをグループの memberUserIDs に追加し、プロフィールを作成する。
class DebugUserAddToGroup {
  Future<void> call({required String debugUID, required String groupID}) async {
    final groupDB = GroupDatabase(groupID: groupID);

    // memberUserIDs に arrayUnion で追加
    await groupDB.groupReference().update({
      'memberUserIDs': FieldValue.arrayUnion([debugUID]),
    });

    // プロフィール作成
    final profileDocID = GroupUserProfile.documentID(
      groupID: groupID,
      userID: debugUID,
    );
    final profile = GroupUserProfile(
      id: profileDocID,
      groupID: groupID,
      userID: debugUID,
      displayName: 'Debug User',
    );
    await groupDB.userProfileReference(userID: debugUID).set(profile);
    debugPrint('[DebugUserAddToGroup] グループ追加完了: $debugUID -> $groupID');
  }
}

/// この端末の FCM トークンをデバッグユーザーの privates ドキュメントに登録する。
///
/// グループ通知 (sendShoppingListUpdateNotification) は送信者以外のメンバーの
/// fcmTokens へ送るため、デバッグユーザーにこの端末のトークンを持たせることで、
/// 1台の端末だけでプッシュ通知の実受信 (Functions → FCM → APNs → 端末) を検証できる。
class DebugUserRegisterFcmToken {
  Future<void> call({required String debugUID}) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      throw StateError('FCMトークンを取得できませんでした');
    }
    // fcmTokens はこの端末のトークン1件で上書きする。デバッグ用途では過去トークンの
    // 蓄積が不要で、同じトークンなら結果が変わらないため冪等。
    await UserDatabase(userID: debugUID).privateReference().set(
      AppUserPrivate(
        id: AppUserPrivate.documentID(userID: debugUID),
        userID: debugUID,
        email: null,
        fcmTokens: [token],
      ),
      SetOptions(merge: true),
    );
    debugPrint('[DebugUserRegisterFcmToken] トークン登録完了: $debugUID');
  }
}

/// デバッグユーザー関連データをクリーンアップする。
/// memberUserIDs から除去、プロフィール削除、privates 削除、ユーザードキュメント削除。
class DebugUserCleanup {
  Future<void> call({required String debugUID, required String groupID}) async {
    final groupDB = GroupDatabase(groupID: groupID);

    // memberUserIDs から除去
    await groupDB.groupReference().update({
      'memberUserIDs': FieldValue.arrayRemove([debugUID]),
    });

    // プロフィール削除
    await groupDB.userProfileReference(userID: debugUID).delete();

    // ユーザードキュメント削除
    final userDB = UserDatabase(userID: debugUID);
    await userDB.privateReference().delete();
    await userDB.userReference().delete();
    debugPrint('[DebugUserCleanup] クリーンアップ完了: $debugUID');
  }
}
