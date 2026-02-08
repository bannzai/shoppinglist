// ignore: implementation_imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/app_user.dart';

class AppUserCreate {
  final UserDatabase userDatabase;

  AppUserCreate({required this.userDatabase});

  Future<void> call() async {
    final document = await userDatabase.userReference().get();
    if (document.exists) {
      return;
    }
    await userDatabase.userReference().set(
          AppUser(id: userDatabase.userID),
          SetOptions(merge: true),
        );
  }
}

class AppUserCreateResolver extends HookConsumerWidget {
  final Widget Function(BuildContext) builder;

  const AppUserCreateResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    final appUserCreate =
        AppUserCreate(userDatabase: ref.watch(userDatabaseProvider));

    useEffect(() {
      appUserCreate();
      return null;
    }, []);

    return Retry(
      retry: () => ref.invalidate(appUserProvider),
      child: () {
        return appUser.when(
          data: (appUser) => builder(context),
          error: (e, st) => RetryPage(
            exception: e,
          ),
          loading: () => const Loading(),
        );
      }(),
    );
  }
}
