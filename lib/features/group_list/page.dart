import 'package:flutter/material.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/error_view.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

class GroupListPage extends ConsumerWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final groupsAsync = ref.watch(userGroupsProvider);
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    // 無料プランで作成上限に達しているか。作成済みグループ(自分がオーナー)が上限+1以上で到達。
    final appUser = appUserAsync.asData?.value;
    final groups = groupsAsync.asData?.value ?? const <Group>[];
    final createdGroupCount =
        appUser == null
            ? 0
            : groups.where((group) => group.ownerUserID == appUser.id).length;
    final isLimitReached =
        !isPremium && createdGroupCount >= freeAdditionalGroupCreationLimit + 1;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: Text(context.l10n.settingsGroupManagement),
        backgroundColor: neutral.paper,
      ),
      // 左右の safe area を避ける。ListView は padding を明示すると MediaQuery の
      // inset を足さないため、画面の端にステータスバーの列がある iPhone Duo では
      // グループのカードが列の下に重なっていた (issue #640)。上下はこれまでどおり。
      body: SafeArea(
        top: false,
        bottom: false,
        child: switch ((appUserAsync, groupsAsync)) {
          (AsyncData(value: final appUser), AsyncData(value: final groups)) =>
            groups.isEmpty
                ? Center(
                  child: Text(
                    context.l10n.groupListEmpty,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: neutral.ink2),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: groups.length + (isPremium ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (!isPremium && index == groups.length) {
                      return _FreeLimitBanner(
                        onTap: () => showPaywall(context: context),
                      );
                    }
                    final group = groups[index];
                    final isDefault = group.id == appUser.defaultGroupID;
                    return _GroupCard(
                      group: group,
                      isDefault: isDefault,
                      onTap: () {
                        analytics.logEvent(
                          name: 'tap_select_group',
                          parameters: {'groupID': group.id},
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    GroupSettingPage(groupID: group.id),
                          ),
                        );
                      },
                    );
                  },
                ),
          (AsyncError(:final error, :final stackTrace), _) ||
          (
            _,
            AsyncError(:final error, :final stackTrace),
          ) => ErrorView(error: error, stackTrace: stackTrace),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      // 上限到達時はFAB自体を非表示にする。上限の案内と解除導線は本文の _FreeLimitBanner が担う。
      floatingActionButton:
          isLimitReached
              ? null
              : FloatingActionButton(
                tooltip: context.l10n.groupCreateTitle,
                backgroundColor: tokens.accent,
                foregroundColor: Colors.white,
                onPressed: () {
                  analytics.logEvent(
                    name: 'tap_navigate_group_create',
                    parameters: null,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GroupCreatePage(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
    );
  }
}

/// 1 グループのカード。3-stack avatars + 名前 + デフォルトバッジ + メンバー数。
/// `design_handoff_shoppinglist/preview/screens-groups.jsx#GroupListPage` 相当。
class _GroupCard extends ConsumerWidget {
  final Group group;
  final bool isDefault;
  final VoidCallback onTap;
  const _GroupCard({
    required this.group,
    required this.isDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final profiles =
        ref.watch(groupUserProfilesProvider(groupID: group.id)).asData?.value ??
        const <GroupUserProfile>[];
    final shown = profiles.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: neutral.card,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: neutral.divider, width: 0.5),
            ),
            child: Row(
              children: [
                if (shown.isEmpty)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: neutral.surface2,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.person, size: 16, color: neutral.ink3),
                  )
                else
                  SizedBox(
                    width: (shown.length - 1) * 20.0 + 28,
                    height: 28,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(shown.length, (i) {
                        final profile = shown[i];
                        final initial =
                            (profile.displayName?.isNotEmpty ?? false)
                                ? profile.displayName![0].toUpperCase()
                                : '?';
                        return Positioned(
                          left: i * 20.0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.accentSoft,
                              border: Border.all(
                                color: neutral.card,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: monoTextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: tokens.accent,
                                letterSpacing: null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              group.name ?? context.l10n.commonUnnamed,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: neutral.ink),
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.accentSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                context.l10n.commonDefault,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.groupListMemberCount(
                          group.memberUserIDs.length,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: neutral.ink3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: neutral.ink4, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 無料プラン上限を案内するバナー。
class _FreeLimitBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _FreeLimitBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, size: 18, color: tokens.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.groupListFreeLimitBanner,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                context.l10n.groupListFreeLimitAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
