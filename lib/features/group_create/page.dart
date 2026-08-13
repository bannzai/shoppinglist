import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/features/notification_permission/pre_permission_dialog.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    // グループ名 TextField の入力に応じて「作成する」ボタンの活性状態を切り替えるため購読する。
    // Issue #432: グループ作成時に名前を必須化する。
    useListenable(nameController);
    final trimmedGroupName = nameController.text.trim();
    final canCreate = trimmedGroupName.isNotEmpty;
    final isCreating = useState(false);
    final errorMessage = useState<String?>(null);
    final selectedIconName = useState<String>('home');

    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final appUser = ref.watch(appUserProvider).asData?.value;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: Text(context.l10n.groupCreateTitle),
        backgroundColor: neutral.paper,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.groupNameLabel,
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
                    hintText: context.l10n.groupNameHint,
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: neutral.divider2, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: tokens.accent, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: neutral.dangerSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    errorMessage.value!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: neutral.danger),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // GroupCreatePage iconName 選択 (3x2 GridView)。AI アイコン生成タイルは
              // M-3 確定で表示しない (design_handoff v2 運用ルール 4 参照)。
              Text(
                context.l10n.groupCreateIconLabel,
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
                children:
                    _iconPresets.map((preset) {
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
                            color:
                                isSelected ? tokens.accentSoft : neutral.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  isSelected ? tokens.accent : neutral.divider,
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
                                _iconPresetLabel(context, preset.name),
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
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
                  label:
                      isCreating.value
                          ? context.l10n.commonCreating
                          : context.l10n.groupCreateSubmit,
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed:
                      (isCreating.value || !canCreate)
                          ? null
                          : () async {
                            analytics.logEvent(
                              name: 'tap_create_group',
                              parameters: null,
                            );
                            isCreating.value = true;
                            errorMessage.value = null;
                            try {
                              if (appUser == null) {
                                throw StateError('AppUser is not available');
                              }
                              final groupID = await functions.createGroup(
                                createUserID: appUser.id,
                                name: trimmedGroupName,
                                setAsDefault: false,
                                iconName: selectedIconName.value,
                              );
                              // 作成後、招待コードを直ちに生成して共有 dialog を表示する。
                              // `design_handoff_shoppinglist/preview/screens-groups.jsx` 準拠。
                              try {
                                final invitation = await functions
                                    .createGroupInvitation(groupID: groupID);
                                if (context.mounted) {
                                  await showDialog<void>(
                                    context: context,
                                    builder:
                                        (dialogContext) =>
                                            _PostCreateInvitationDialog(
                                              invitationCode:
                                                  invitation.invitationCode,
                                            ),
                                  );
                                }
                                // グループ作成 = 誰かと共有する意思の表明であり、
                                // メンバーの更新をプッシュ通知で受け取る動機が高い
                                // タイミングのため、招待 dialog を閉じた後に通知許可を
                                // 促す (Issue #500)。
                                if (context.mounted) {
                                  await maybeRequestNotificationPermission(
                                    context,
                                    trigger: 'group_create',
                                  );
                                }
                              } catch (e, st) {
                                // 招待生成失敗時もグループ作成自体は成功している
                                // のでエラー表示は SnackBar に留め、画面は閉じる。
                                if (context.mounted) {
                                  showErrorSnackBar(context, e, st);
                                }
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e, st) {
                              logError(e, st);
                              errorMessage.value = describeError(e, st).message;
                            } finally {
                              isCreating.value = false;
                            }
                          },
                  icon: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// グループ作成成功後に招待コードを表示する dialog。
/// `design_handoff_shoppinglist/preview/screens-groups.jsx` 準拠。
/// コピー / 共有 / 閉じる の 3 アクションを提供する。
class _PostCreateInvitationDialog extends StatelessWidget {
  final String invitationCode;
  const _PostCreateInvitationDialog({required this.invitationCode});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    return AlertDialog(
      backgroundColor: neutral.card,
      title: Text(context.l10n.groupCreateInvitationDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.groupCreateInvitationDialogMessage),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              invitationCode,
              style: monoTextStyle(
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
            analytics.logEvent(
              name: 'tap_copy_invitation_code_post_create',
              parameters: null,
            );
            final copiedMessage = context.l10n.listSettingInvitationCodeCopied;
            await Clipboard.setData(ClipboardData(text: invitationCode));
            // ダイアログ上の SnackBar は背後の Scaffold に描画されて
            // 見えないため、前面に出るグローバルトーストで通知する。
            showGlobalToast(copiedMessage, title: null);
          },
          child: Text(context.l10n.commonCopy),
        ),
        TextButton(
          onPressed: () async {
            analytics.logEvent(
              name: 'tap_share_invitation_code_post_create',
              parameters: null,
            );
            final box = context.findRenderObject() as RenderBox?;
            await SharePlus.instance.share(
              ShareParams(
                text: context.l10n.listSettingInvitationShareText(
                  invitationCode,
                ),
                sharePositionOrigin:
                    box == null
                        ? null
                        : box.localToGlobal(Offset.zero) & box.size,
              ),
            );
          },
          child: Text(context.l10n.commonShare),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonClose),
        ),
      ],
    );
  }
}

/// `design_handoff_shoppinglist/preview/screens-groups.jsx#GroupCreatePage` の
/// iconName プリセット 6 種。`Group.iconName` で許容される値。
const _iconPresets = <({String name, IconData icon})>[
  (name: 'home', icon: Icons.home_outlined),
  (name: 'cart', icon: Icons.shopping_cart_outlined),
  (name: 'fork', icon: Icons.restaurant_outlined),
  (name: 'cookie', icon: Icons.cookie_outlined),
  (name: 'pets', icon: Icons.pets_outlined),
  (name: 'bag', icon: Icons.shopping_bag_outlined),
];

/// [_iconPresets] の iconName に対応する表示ラベル。
String _iconPresetLabel(BuildContext context, String iconName) =>
    switch (iconName) {
      'cart' => context.l10n.groupCreateIconCart,
      'fork' => context.l10n.groupCreateIconFork,
      'cookie' => context.l10n.groupCreateIconCookie,
      'pets' => context.l10n.groupCreateIconPets,
      'bag' => context.l10n.groupCreateIconBag,
      _ => context.l10n.groupCreateIconHome,
    };
