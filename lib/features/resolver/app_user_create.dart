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
      ),
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}

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
    final appUser = ref.watch(appUserProvider);
    final appUserCreate =
        AppUserCreate(userDatabase: ref.watch(userDatabaseProvider));

    useEffect(() {
      appUserCreate(firebaseUser: firebaseUser);
      return null;
    }, []);

    return Retry(
      retry: () => ref.invalidate(appUserProvider),
      child: () {
        return appUser.when(
          data: (appUser) => builder(context),
          error: (e, st) => RetryPage(
            exception: e,
            stackTrace: st,
          ),
          loading: () => const Loading(),
        );
      }(),
    );
  }
}
