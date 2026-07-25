import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// ログイン後・グループ未参加(defaultGroupID == null)のユーザーに表示する初期セットアップ画面。
/// 「招待コードで参加」か「自分のリストを作る(ソログループ作成)」を選ばせる。
/// どちらでも defaultGroupID がセットされ、AppEntityPrepareResolver が再ビルドされて
/// 通常フロー(ホーム)へ遷移する。本画面は Navigator のルートではなく
/// AppEntityPrepareResolver の直接の子として表示されるため、明示的な pop は不要で画面が置き換わる。
class GroupJoinOrCreatePage extends HookConsumerWidget {
  /// ソログループ作成に必要なログイン済みユーザー。AppEntityPrepareResolver が
  /// 非 null を保証した上で渡す。
  final AppUser appUser;

  const GroupJoinOrCreatePage({super.key, required this.appUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCreating = useState(false);
    final errorMessage = useState<String?>(null);
    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.groups, size: 32, color: tokens.accent),
              ),
              const SizedBox(height: 24),
              Text(
                'はじめましょう',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '家族やパートナーから招待コードを受け取っていますか？\n'
                'コードで参加すると同じ買い物リストを一緒に使えます。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: neutral.ink2,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 16),
                Text(
                  key: const ValueKey('group_join_or_create_error_message'),
                  errorMessage.value!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: neutral.danger),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                  key: const ValueKey('group_join_or_create_join_button'),
                  label: '招待コードで参加',
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed:
                      isCreating.value
                          ? null
                          : () {
                            analytics.logEvent(
                              name: 'tap_join_via_code',
                              parameters: null,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const GroupInvitationAcceptPage(),
                              ),
                            );
                          },
                  icon: null,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                  key: const ValueKey('group_join_or_create_create_button'),
                  label: isCreating.value ? '作成中...' : '自分のリストを作る',
                  variant: AppPillVariant.ghost,
                  large: true,
                  expanded: true,
                  onPressed:
                      isCreating.value
                          ? null
                          : () async {
                            analytics.logEvent(
                              name: 'tap_create_solo_group',
                              parameters: null,
                            );
                            isCreating.value = true;
                            errorMessage.value = null;
                            try {
                              await functions.createGroup(
                                createUserID: appUser.id,
                                name: null,
                                setAsDefault: true,
                                iconName: 'home',
                              );
                              // 成功時は defaultGroupID がセットされ
                              // AppEntityPrepareResolver が再ビルドされて本画面が置き換わる。
                              // 破棄済み hook への書き込みを避けるため isCreating は戻さない。
                            } catch (e, st) {
                              logError(e, st);
                              errorMessage.value = describeError(e, st).message;
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
