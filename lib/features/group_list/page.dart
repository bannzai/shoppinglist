import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/user_groups.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ管理'),
      ),
      body: switch ((appUserAsync, groupsAsync)) {
        (AsyncData(value: final appUser), AsyncData(value: final groups)) =>
          groups.isEmpty
              ? const Center(
                  child: Text('所属しているグループはありません'),
                )
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final isDefault = group.id == appUser.defaultGroupID;
                    return ListTile(
                      title: Text(group.name ?? '名前未設定'),
                      subtitle: Text('メンバー ${group.memberUserIDs.length}人'),
                      trailing: isDefault
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
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
      ),
    );
  }

  Widget _buildFab({
    required BuildContext context,
    required AsyncValue appUserAsync,
    required AsyncValue<List<Group>> groupsAsync,
    required bool isPremium,
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
      onPressed: () {
        analytics.logEvent(name: 'tap_navigate_group_create');
        if (isLimitReached) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '無料プランではソログループ+1グループまで作成できます。プレミアムにアップグレードすると無制限に作成できます',
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
      child: isLimitReached
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.lock,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            )
          : const Icon(Icons.add),
    );
  }
}
