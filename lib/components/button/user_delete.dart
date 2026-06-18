import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/alert/discard.dart';
import 'package:shoppinglist/components/error/alert.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/resolver/auth.dart';

import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/logger/error.dart';

class DeleteUserButton extends HookConsumerWidget {
  const DeleteUserButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final isAppleLinked = ref.watch(isAppleLinkedProvider);
    final isGoogleLinked = ref.watch(isGoogleLinkedProvider);
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: OutlinedButton(
            onPressed: () async {
              if (isLoading.value) {
                return;
              }
              analytics.logEvent(
                name: 'tap_show_delete_account',
                parameters: null,
              );

              showDiscardDialog(
                context,
                title: 'ユーザー情報を削除します',
                message: 'アカウントを削除すると、ユーザー情報がすべて削除されます。',
                actions: [
                  TextButton(
                    onPressed: () async {
                      analytics.logEvent(
                        name: 'cancel_delete_account',
                        parameters: null,
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'キャンセル',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!isLoading.value) {
                        analytics.logEvent(
                          name: 'tap_confirm_delete_account',
                          parameters: null,
                        );
                        isLoading.value = true;
                        await _delete(
                          context,
                          isAppleLinked: isAppleLinked,
                          isGoogleLinked: isGoogleLinked,
                        );
                        isLoading.value = false;
                      }
                    },
                    child: Text(
                      '削除する',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
            child: const Text('アカウントを削除する'),
          ),
        ),
        if (isLoading.value) const Center(child: Loading()),
      ],
    );
  }

  Future<void> _delete(
    BuildContext context, {
    required bool isAppleLinked,
    required bool isGoogleLinked,
  }) async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => const _CompletedDialog(),
        );
      }
    } on FirebaseAuthException catch (error, stackTrace) {
      if (error.code == 'requires-recent-login') {
        if (!context.mounted) {
          return;
        }
        showDiscardDialog(
          context,
          title: '再ログインしてください',
          message: 'アカウントを削除するには、再ログインしてください。',
          actions: [
            TextButton(
              onPressed: () async {
                analytics.logEvent(
                  name: 'cancel_reauth_for_delete',
                  parameters: null,
                );
                Navigator.of(context).pop();
              },
              child: Text(
                'キャンセル',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                analytics.logEvent(
                  name: 'tap_reauth_for_delete',
                  parameters: null,
                );
                final navigator = Navigator.of(context);
                if (isAppleLinked) {
                  await appleReauthentification();
                } else if (isGoogleLinked) {
                  await googleReauthentification();
                } else {
                  errorLogger.log('it is not cooperate account');
                  exit(1);
                }
                navigator.pop();
                // ignore: use_build_context_synchronously
                await _delete(
                  context,
                  isAppleLinked: isAppleLinked,
                  isGoogleLinked: isGoogleLinked,
                );
              },
              child: Text(
                '再ログインする',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      } else {
        if (context.mounted) {
          showErrorAlert(context, error, stackTrace);
        }
      }
    } catch (error, stackTrace) {
      if (context.mounted) {
        showErrorAlert(context, error, stackTrace);
      }
    }
  }
}

class _CompletedDialog extends StatelessWidget {
  const _CompletedDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'アカウントを削除しました',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'アプリを終了しますか？',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: TextButton(
              onPressed: () async {
                analytics.logEvent(
                  name: 'tap_exit_app_after_delete',
                  parameters: null,
                );
                exit(0);
              },
              child: Text(
                '終了する',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> appleReauthentification() async {
  try {
    final provider = AppleAuthProvider().addScope('email');
    await FirebaseAuth.instance.currentUser?.reauthenticateWithProvider(
      provider,
    );
  } on FirebaseAuthException catch (e) {
    // Googleのcodeとは違うので注意
    if (e.code == 'canceled') {
      return Future.value();
    }
    rethrow;
  }
}

Future<void> googleReauthentification() async {
  try {
    final provider = GoogleAuthProvider().addScope('email');
    await FirebaseAuth.instance.currentUser?.reauthenticateWithProvider(
      provider,
    );
  } on FirebaseAuthException catch (e) {
    // sign-in-failed という code で返ってくるが、コードを読んでると該当するエラーが多かったので実際にdumpしてみたメッセージでマッチしている
    // Appleのcodeとは違うので注意
    if (e.toString().contains('The interaction was cancelled by the user')) {
      return;
    }
    rethrow;
  }
}

bool isLinkedGoogleFor(User user) {
  return user.providerData
      .where((element) => element.providerId == GoogleAuthProvider.PROVIDER_ID)
      .isNotEmpty;
}

bool isLinkedAppleFor(User user) {
  return user.providerData
      .where((element) => element.providerId == AppleAuthProvider.PROVIDER_ID)
      .isNotEmpty;
}

final isAppleLinkedProvider = Provider((ref) {
  final user = ref.watch(firebaseUserChangesProvider);
  final userValue = user.valueOrNull;
  if (userValue == null) {
    return false;
  }
  return isLinkedAppleFor(userValue);
});

final isGoogleLinkedProvider = Provider((ref) {
  final user = ref.watch(firebaseUserChangesProvider);
  final userValue = user.valueOrNull;
  if (userValue == null) {
    return false;
  }
  return isLinkedGoogleFor(userValue);
});
