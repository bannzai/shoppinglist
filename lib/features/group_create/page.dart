import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_create.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// グループ作成成功後に招待コードを表示する dialog。
/// `design_handoff_shoppinglist/preview/screens-groups.jsx` 準拠。
/// コピー / 共有 / 閉じる の 3 アクションを提供する。
class _PostCreateInvitationDialog extends StatelessWidget {
  final String invitationCode;
  const _PostCreateInvitationDialog({required this.invitationCode});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return AlertDialog(
      backgroundColor: neutral.card,
      title: const Text('メンバーを招待'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('招待コードを家族と共有してください'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              invitationCode,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: tokens.accent,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            analytics.logEvent(name: 'tap_copy_invitation_code_post_create');
            await Clipboard.setData(ClipboardData(text: invitationCode));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('招待コードをコピーしました')),
              );
            }
          },
          child: const Text('コピー'),
        ),
        TextButton(
          onPressed: () async {
            analytics.logEvent(name: 'tap_share_invitation_code_post_create');
            await SharePlus.instance.share(
              ShareParams(text: '買い物リストの招待コード: $invitationCode'),
            );
          },
          child: const Text('共有'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

/// `design_handoff_shoppinglist/preview/screens-groups.jsx#GroupCreatePage` の
/// iconName プリセット 6 種。`Group.iconName` で許容される値。
const _iconPresets = <({String name, IconData icon, String label})>[
  (name: 'home', icon: Icons.home_outlined, label: 'いえ'),
  (name: 'cart', icon: Icons.shopping_cart_outlined, label: 'カート'),
  (name: 'fork', icon: Icons.restaurant_outlined, label: 'たべる'),
  (name: 'cookie', icon: Icons.cookie_outlined, label: 'おかし'),
  (name: 'pets', icon: Icons.pets_outlined, label: 'ペット'),
  (name: 'bag', icon: Icons.shopping_bag_outlined, label: 'バッグ'),
];

class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final isCreating = useState(false);
    final errorMessage = useState<String?>(null);
    final selectedIconName = useState<String>('home');

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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
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
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: neutral.danger),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // GroupCreatePage iconName 選択 (3x2 GridView)。AI アイコン生成タイルは
              // M-3 確定で表示しない (design_handoff v2 運用ルール 4 参照)。
              Text(
                'アイコン',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: neutral.ink2,
                      letterSpacing: 0.04,
                    ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.6,
                children: _iconPresets.map((preset) {
                  final isSelected = selectedIconName.value == preset.name;
                  return GestureDetector(
                    onTap: () {
                      analytics.logEvent(
                        name: 'select_group_icon',
                        parameters: {'iconName': preset.name},
                      );
                      selectedIconName.value = preset.name;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.accentSoft : neutral.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? tokens.accent : neutral.divider,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            preset.icon,
                            size: 24,
                            color: isSelected ? tokens.accent : neutral.ink,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color:
                                      isSelected ? tokens.accent : neutral.ink2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                            final groupID =
                                await ref.read(createGroupProvider).call(
                                      appUser: appUser,
                                      name:
                                          nameController.text.trim().isNotEmpty
                                              ? nameController.text.trim()
                                              : null,
                                      setAsDefault: false,
                                      iconName: selectedIconName.value,
                                    );
                            // 作成後、招待コードを直ちに生成して共有 dialog を表示する。
                            // `design_handoff_shoppinglist/preview/screens-groups.jsx` 準拠。
                            try {
                              final invitationCode = await ref
                                  .read(createGroupInvitationProvider)
                                  .call(groupID: groupID);
                              if (context.mounted) {
                                await showDialog<void>(
                                  context: context,
                                  builder: (dialogContext) =>
                                      _PostCreateInvitationDialog(
                                    invitationCode: invitationCode,
                                  ),
                                );
                              }
                            } catch (e) {
                              // 招待生成失敗時もグループ作成自体は成功している
                              // のでエラー表示は SnackBar に留め、画面は閉じる。
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
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
