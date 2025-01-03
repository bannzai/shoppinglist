import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/alert/discard.dart';
import 'package:shoppinglist/components/button/buttons.dart';
import 'package:shoppinglist/components/error/alert.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/style/color.dart';

class DeleteUserButton extends HookConsumerWidget {
  const DeleteUserButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    return Stack(
      children: [
        OutlinedButton(
          onPressed: () async {
            if (isLoading.value) {
              return;
            }

            showDiscardDialog(
              context,
              title: 'ユーザー情報を削除します',
              message: 'アカウントを削除すると、ユーザー情報がすべて削除されます。',
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(
                      color: TextColor.darkGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (!isLoading.value) {
                      isLoading.value = true;
                      await _delete(context);
                      isLoading.value = false;
                    }
                  },
                  child: const Text('削除する', style: TextStyle(color: TextColor.danger, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
          child: const Text('アカウントを削除する'),
        ),
        if (isLoading.value)
          const Center(
            child: Loading(),
          ),
      ],
    );
  }

  Future<void> _delete(
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => const _CompletedDialog(),
        );
      }
    } catch (error) {
      if (context.mounted) {
        showErrorAlert(context, error);
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
          const Text(
            'アカウントを削除しました',
            style: TextStyle(
              color: TextColor.main,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'アプリを終了しますか？',
            style: TextStyle(
              color: TextColor.main,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: AlertButton(
              onPressed: () async {
                exit(0);
              },
              text: '終了する',
            ),
          ),
        ],
      ),
    );
  }
}
