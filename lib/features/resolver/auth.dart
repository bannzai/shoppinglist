import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/auth/page.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

part 'auth.g.dart';

@Riverpod(keepAlive: true, dependencies: [])
Stream<User?> firebaseUserChanges(FirebaseUserChangesRef ref) {
  return FirebaseAuth.instance.userChanges();
}

class AuthResolver extends HookConsumerWidget {
  final Widget Function(BuildContext, User) builder;

  const AuthResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUserChanges = ref.watch(firebaseUserChangesProvider);
    final sharedPreferences = ref.watch(sharedPreferencesProvider);

    useEffect(() {
      final uid = firebaseUserChanges.asData?.valueOrNull?.uid;
      if (uid != null) {
        sharedPreferences.setString(StringKey.lastSignInFirebaseAuthUserID, uid);

        Purchases.logIn(uid);
      }
      return null;
    }, [firebaseUserChanges.asData?.valueOrNull?.uid]);

    return Retry(
      retry: () => ref.invalidate(firebaseUserChangesProvider),
      child: () {
        return firebaseUserChanges.when(
          data: (user) {
            debugPrint('user.uid: ${user?.uid}');

            if (user == null || user.isAnonymous) {
              return const AuthPage();
            } else {
              return builder(context, user);
            }
          },
          error: (e, st) => RetryPage(exception: e),
          loading: () => const Loading(),
        );
      }(),
    );
  }
}
