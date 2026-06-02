import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/auth/page.dart';
import 'package:shoppinglist/features/onboarding/page.dart';
import 'package:shoppinglist/provider/onboarding.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

part 'auth.g.dart';

@Riverpod(keepAlive: true, dependencies: [])
Stream<User?> firebaseUserChanges(Ref ref) {
  return FirebaseAuth.instance.userChanges();
}

class AuthResolver extends HookConsumerWidget {
  final Widget Function(BuildContext, User) builder;

  const AuthResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUserChanges = ref.watch(firebaseUserChangesProvider);
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

    useEffect(() {
      final userID = firebaseUserChanges.asData?.valueOrNull?.uid;
      if (userID != null) {
        sharedPreferences.setString(
            StringKey.lastSignInFirebaseAuthUserID, userID);

        unawaited(Purchases.logIn(userID));
        unawaited(FirebaseCrashlytics.instance.setUserIdentifier(userID));
        unawaited(FirebaseAnalytics.instance.setUserId(id: userID));
      }
      return null;
    }, [firebaseUserChanges.asData?.valueOrNull?.uid]);

    return Retry(
      retry: () => ref.invalidate(firebaseUserChangesProvider),
      child: () {
        return firebaseUserChanges.when(
          data: (user) {
            debugPrint('user.uid: ${user?.uid}');

            // kDebugMode時は匿名ユーザーでも認証済みとして通過させる（自動テスト用）
            if (user == null || (!kDebugMode && user.isAnonymous)) {
              if (!hasSeenOnboarding) {
                return const OnboardingPage();
              }
              return const AuthPage();
            } else {
              return builder(context, user);
            }
          },
          error: (e, st) => RetryPage(exception: e, stackTrace: st),
          loading: () => Loading(key: resolverChainLoadingKey),
        );
      }(),
    );
  }
}
