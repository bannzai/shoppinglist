import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/utils/invitation_code_validator.dart';

class GroupInvitationAcceptPage extends HookConsumerWidget {
  const GroupInvitationAcceptPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAccepting = useState(false);
    final errorMessage = useState<String?>(null);
    final codeController = useTextEditingController();
    final isValidCode = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('招待コードで参加'),
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
                '招待コードを入力してください',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'グループのメンバーから共有された8桁のコードを入力してください',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'ABCD3456',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  isValidCode.value = isValidInvitationCode(value);
                },
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
                  onPressed: isAccepting.value || !isValidCode.value
                      ? null
                      : () async {
                          isAccepting.value = true;
                          errorMessage.value = null;
                          try {
                            await ref
                                .read(acceptGroupInvitationProvider)
                                .call(
                                    invitationCode:
                                        codeController.text.toUpperCase());
                            if (context.mounted) {
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
