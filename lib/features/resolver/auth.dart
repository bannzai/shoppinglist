import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

    useEffect(() {
      final user = firebaseUserChanges.asData?.valueOrNull;
      if (user != null) {
        
      }
      return null;
    }, [firebaseUserChanges.asData?.valueOrNull]);

    return Retry(
      retry: () => ref.invalidate(firebaseUserChangesProvider),
      child: () {
        return firebaseUserChanges.when(
          data: (user) {
            debugPrint('user.uid: ${user?.uid}');
            if (user == null) {
              return SignInResolver(
                builder: (context, user) => builder(context, user),
              );
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

class SignInResolver extends HookConsumerWidget {
  final Widget Function(BuildContext, User) builder;

  const SignInResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = useState(FirebaseAuth.instance.currentUser);
    final userValue = user.value;

    useEffect(() {
      void f() async {
        if (userValue == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      }

      f();
      return null;
    }, [user.value]);

    if (userValue == null) {
      return const Loading();
    } else {
      return builder(context, userValue);
    }
  }
}
