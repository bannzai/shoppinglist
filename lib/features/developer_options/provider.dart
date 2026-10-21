import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/app_user_private.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

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

    await functions.updateDebugUserGroupMembership(
      groupID: groupID,
      debugUserID: debugUID,
      membership: 'join',
    );

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

/// カテゴリ共有E2E用に、デバッグユーザー所有のカテゴリ設定を冪等に作成する。
class DebugUserCategorySetup {
  static String categoryAxisID({required String debugUID}) =>
      'DebugGroupCategoryAxis_users_$debugUID';

  static String categoryID({required String debugUID}) =>
      'DebugGroupCategory_users_$debugUID';

  Future<void> call({required String debugUID, required String groupID}) async {
    final groupDB = GroupDatabase(groupID: groupID);
    final axisID = categoryAxisID(debugUID: debugUID);
    await groupDB
        .categoryAxisReference(categoryAxisID: axisID)
        .set(
          GroupCategoryAxis(
            id: axisID,
            groupID: groupID,
            userID: debugUID,
            name: 'デバッグ売り場',
            order: 0,
          ),
          SetOptions(merge: true),
        );
    final debugCategoryID = categoryID(debugUID: debugUID);
    await groupDB
        .categoryReference(categoryAxisID: axisID, categoryID: debugCategoryID)
        .set(
          GroupCategory(
            id: debugCategoryID,
            groupID: groupID,
            userID: debugUID,
            groupCategoryAxisID: axisID,
            name: '共有野菜',
            order: 0,
            locationOrders: const {},
            keywords: const [
              GroupCategoryKeyword(
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.exact,
              ),
            ],
            color: null,
            iconName: null,
          ),
          SetOptions(merge: true),
        );
    debugPrint('[DebugUserCategorySetup] カテゴリ設定作成完了: $debugUID -> $groupID');
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
/// memberUserIDs から除去、プロフィール・カテゴリ・privates・ユーザー文書を削除。
class DebugUserCleanup {
  Future<void> call({
    required String debugUID,
    required String destinationUserID,
    required String groupID,
  }) async {
    final groupDB = GroupDatabase(groupID: groupID);

    await functions.updateDebugUserGroupMembership(
      groupID: groupID,
      debugUserID: debugUID,
      membership: 'leave',
    );

    // プロフィール削除
    await groupDB.userProfileReference(userID: debugUID).delete();

    // 既存軸へ取り込んだコピーを含め、デバッグカテゴリ由来の決定的IDを削除する。
    // 文書が存在しない場合もdeleteは成功するため、クリーンアップは冪等である。
    final categoryAxisID = DebugUserCategorySetup.categoryAxisID(
      debugUID: debugUID,
    );
    final importedCategoryID = importedGroupCategoryDocumentID(
      sourceUserID: debugUID,
      sourceGroupCategoryAxisID: categoryAxisID,
      sourceGroupCategoryID: DebugUserCategorySetup.categoryID(
        debugUID: debugUID,
      ),
    );
    final destinationAxes =
        (await groupDB
                .categoryAxesReference()
                .where(
                  GroupCategoryAxisFirestoreKeys.userID,
                  isEqualTo: destinationUserID,
                )
                .get())
            .docs;
    for (final destinationAxis in destinationAxes) {
      await groupDB
          .categoryReference(
            categoryAxisID: destinationAxis.id,
            categoryID: importedCategoryID,
          )
          .delete();
    }
    final importedAxisID = importedGroupCategoryAxisDocumentID(
      destinationUserID: destinationUserID,
      sourceUserID: debugUID,
      sourceGroupCategoryAxisID: categoryAxisID,
    );
    if (destinationAxes.any((axis) => axis.id == importedAxisID)) {
      final remainingImportedAxisCategories =
          (await groupDB
                  .categoriesReference(categoryAxisID: importedAxisID)
                  .where(
                    GroupCategoryFirestoreKeys.userID,
                    isEqualTo: destinationUserID,
                  )
                  .limit(1)
                  .get())
              .docs;
      if (remainingImportedAxisCategories.isEmpty) {
        await groupDB
            .categoryAxisReference(categoryAxisID: importedAxisID)
            .delete();
      }
    }
    await groupDB
        .categoryReference(
          categoryAxisID: categoryAxisID,
          categoryID: DebugUserCategorySetup.categoryID(debugUID: debugUID),
        )
        .delete();
    await groupDB
        .categoryAxisReference(categoryAxisID: categoryAxisID)
        .delete();

    // ユーザードキュメント削除
    final userDB = UserDatabase(userID: debugUID);
    await userDB.privateReference().delete();
    await userDB.userReference().delete();
    debugPrint('[DebugUserCleanup] クリーンアップ完了: $debugUID');
  }
}
