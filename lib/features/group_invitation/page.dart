import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/invitation_code_validator.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

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

    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final hasError = errorMessage.value != null;
    final borderColor = hasError
        ? neutral.danger
        : (isValidCode.value ? tokens.accent : neutral.divider);

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('招待コードで参加'),
        backgroundColor: neutral.paper,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.group_add, size: 32, color: tokens.accent),
              ),
              const SizedBox(height: 24),
              Text(
                '招待コードを入力してください',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'グループのメンバーから共有された8桁のコードを入力してください',
                style:
                    TextStyle(fontSize: 13, color: neutral.ink2, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: monoTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: neutral.ink,
                ).copyWith(letterSpacing: 6),
                decoration: InputDecoration(
                  hintText: 'ABCD3456',
                  hintStyle: monoTextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: neutral.ink4,
                  ).copyWith(letterSpacing: 6),
                  counterText: '',
                  filled: true,
                  fillColor: neutral.card,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  errorMessage.value = null;
                  isValidCode.value = isValidInvitationCode(value);
                },
              ),
              if (hasError) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage.value!,
                  style: TextStyle(color: neutral.danger, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                  label: isAccepting.value ? '参加中...' : '参加する',
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed: isAccepting.value || !isValidCode.value
                      ? null
                      : () async {
                          analytics.logEvent(name: 'tap_join_group');
                          isAccepting.value = true;
                          errorMessage.value = null;
                          try {
                            await ref.read(acceptGroupInvitationProvider).call(
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
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                  label: 'キャンセル',
                  variant: AppPillVariant.ghost,
                  large: true,
                  expanded: true,
                  onPressed: isAccepting.value
                      ? null
                      : () {
                          analytics.logEvent(name: 'cancel_join_group');
                          Navigator.pop(context);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
