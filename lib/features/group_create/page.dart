import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_create.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final isCreating = useState(false);
    final errorMessage = useState<String?>(null);

    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('グループ作成'),
        backgroundColor: neutral.paper,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'グループ名',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: neutral.ink2,
                  letterSpacing: 0.04,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: neutral.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: neutral.divider, width: 0.5),
                ),
                child: TextField(
                  controller: nameController,
                  autofocus: true,
                  cursorColor: tokens.accent,
                  decoration: InputDecoration(
                    hintText: 'グループ名を入力',
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: neutral.divider2, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: tokens.accent, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: neutral.dangerSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    errorMessage.value!,
                    style: TextStyle(color: neutral.danger, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                  label: isCreating.value ? '作成中...' : '作成する',
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed: isCreating.value
                      ? null
                      : () async {
                          analytics.logEvent(name: 'tap_create_group');
                          isCreating.value = true;
                          errorMessage.value = null;
                          try {
                            final appUser =
                                ref.read(appUserProvider).asData?.value;
                            if (appUser == null) {
                              throw StateError('AppUser is not available');
                            }
                            await ref.read(createGroupProvider).call(
                                  appUser: appUser,
                                  name: nameController.text.trim().isNotEmpty
                                      ? nameController.text.trim()
                                      : null,
                                  setAsDefault: false,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            errorMessage.value = e.toString();
                          } finally {
                            isCreating.value = false;
                          }
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
