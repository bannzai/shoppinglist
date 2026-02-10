import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/group_invitation.dart';

class GroupInvitationAcceptPage extends HookConsumerWidget {
  final String token;

  const GroupInvitationAcceptPage({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptGroupInvitation = ref.read(acceptGroupInvitationProvider);
    final isAccepting = useState(false);
    final errorMessage = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ招待'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.group_add,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'グループへの招待を受け取りました',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'このグループに参加しますか？',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage.value!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isAccepting.value
                      ? null
                      : () async {
                          isAccepting.value = true;
                          errorMessage.value = null;
                          try {
                            await acceptGroupInvitation.call(token: token);
                            if (context.mounted) {
                              // ホームへ遷移（スタックをクリア）
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          } catch (e) {
                            errorMessage.value = e.toString();
                          } finally {
                            isAccepting.value = false;
                          }
                        },
                  child: isAccepting.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '参加する',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: isAccepting.value
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
