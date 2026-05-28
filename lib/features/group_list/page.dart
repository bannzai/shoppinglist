import 'package:flutter/material.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
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
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('グループ管理'),
        backgroundColor: neutral.paper,
      ),
      body: switch ((appUserAsync, groupsAsync)) {
        (AsyncData(value: final appUser), AsyncData(value: final groups)) =>
          groups.isEmpty
              ? Center(
                  child: Text(
                    '所属しているグループはありません',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: neutral.ink2),
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
                            parameters: {'groupID': group.id});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GroupSettingPage(groupID: group.id),
                          ),
                        );
                      },
                    );
                  },
                ),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) =>
          Center(child: Text(error.toString())),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: _buildFab(
        context: context,
        appUserAsync: appUserAsync,
        groupsAsync: groupsAsync,
        isPremium: isPremium,
        tokens: tokens,
      ),
    );
  }

  Widget _buildFab({
    required BuildContext context,
    required AsyncValue appUserAsync,
    required AsyncValue<List<Group>> groupsAsync,
    required bool isPremium,
    required AppTokens tokens,
  }) {
    final appUser = appUserAsync.asData?.value;
    final groups = groupsAsync.asData?.value ?? const <Group>[];
    final createdGroupCount = appUser == null
        ? 0
        : groups.where((group) => group.ownerUserID == appUser.id).length;
    final isLimitReached =
        !isPremium && createdGroupCount >= freeAdditionalGroupCreationLimit + 1;

    return FloatingActionButton(
      tooltip: 'グループ作成',
      backgroundColor: isLimitReached ? tokens.neutral.surface2 : tokens.accent,
      foregroundColor: isLimitReached ? tokens.neutral.ink3 : Colors.white,
      onPressed: () {
        analytics.logEvent(name: 'tap_navigate_group_create');
        if (isLimitReached) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '無料プランではソログループ+1グループまで作成できます。プレミアムにアップグレードすると無制限に作成できます',
              ),
              action: SnackBarAction(
                label: 'アップグレード',
                onPressed: () => showPaywall(context: context),
              ),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GroupCreatePage(),
          ),
        );
      },
      child: isLimitReached ? const Icon(Icons.lock) : const Icon(Icons.add),
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
    final tokens = context.tokens;
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
                              border:
                                  Border.all(color: neutral.card, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: monoTextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: tokens.accent,
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
                              group.name ?? '名前未設定',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: neutral.ink),
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: tokens.accentSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'デフォルト',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
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
                        'メンバー ${group.memberUserIDs.length}人',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: neutral.ink3),
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
    final tokens = context.tokens;
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
              '無料プランは追加 1 グループまで',
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
                '解除',
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
