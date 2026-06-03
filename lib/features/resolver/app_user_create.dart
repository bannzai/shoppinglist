// ignore: implementation_imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/app_user_private.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/user_developer_token_sync.dart';

class AppUserCreate {
  final UserDatabase userDatabase;

  AppUserCreate({required this.userDatabase});

  Future<void> call({required User firebaseUser}) async {
    final document = await userDatabase.userReference().get();
    if (document.exists) {
      return;
    }
    final batch = FirebaseFirestore.instance.batch();
    batch.set(
      userDatabase.userReference(),
      AppUser(
        id: userDatabase.userID,
        name: firebaseUser.displayName,
        iconImageURL: firebaseUser.photoURL,
      ),
      SetOptions(merge: true),
    );
    batch.set(
      userDatabase.privateReference(),
      AppUserPrivate(
        id: AppUserPrivate.documentID(userID: userDatabase.userID),
        userID: userDatabase.userID,
        email: firebaseUser.email,
        fcmTokens: [],
      ),
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}

/// AppUserドキュメントの作成を担当するResolver。
/// appUserProvider（data()!）はここでは使用しない。初回ログイン時にドキュメントが
/// まだ存在しない状態でストリームが発火すると Null check エラーになるため、
/// optionalAppUserProvider（data()、nullable）を使用する。
class AppUserCreateResolver extends HookConsumerWidget {
  final User firebaseUser;
  final Widget Function(BuildContext) builder;

  const AppUserCreateResolver({
    super.key,
    required this.firebaseUser,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionalAppUser = ref.watch(optionalAppUserProvider);
    final appUserCreate =
        AppUserCreate(userDatabase: ref.watch(userDatabaseProvider));
    final userDeveloperTokenSync = ref.watch(userDeveloperTokenSyncProvider);

    // 初回ログイン時にFirestoreにAppUserドキュメントが存在しない場合、ここで作成する。
    // 続けて dart-define SHOPPINGLIST_DEVELOPER_TOKEN を users/{uid}.developerToken に upsert する。
    // この処理はユーザーごとに一度だけ実行されればよいため、依存配列は空にする。
    useEffect(() {
      () async {
        await appUserCreate(firebaseUser: firebaseUser);
        await userDeveloperTokenSync();
      }();
      return null;
    }, []);

    return optionalAppUser.when(
      data: (appUser) {
        if (appUser == null) {
          return LaunchLoading(key: resolverChainLoadingKey);
        }
        return builder(context);
      },
      error: (e, st) => RetryPage(exception: e, stackTrace: st),
      loading: () => LaunchLoading(key: resolverChainLoadingKey),
    );
  }
}
