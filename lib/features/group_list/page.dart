import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/user_groups.dart';

class GroupListPage extends HookConsumerWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final groupsAsync = ref.watch(userGroupsProvider);

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
