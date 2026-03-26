import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/group_category/category_edit_page.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/category_presets.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupSettingPage extends ConsumerWidget {
  final String groupID;

  const GroupSettingPage({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupID: groupID));
    final profilesAsync =
        ref.watch(groupUserProfilesProvider(groupID: groupID));

    return groupAsync.when(
      data: (group) => profilesAsync.when(
        data: (profiles) => _GroupSettingBody(
          groupID: groupID,
          group: group,
          profiles: profiles,
        ),
        error: (e, st) => Scaffold(
          appBar: AppBar(title: const Text('グループ設定')),
          body: Center(child: Text(e.toString())),
        ),
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('グループ設定')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('グループ設定')),
        body: Center(child: Text(e.toString())),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('グループ設定')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _GroupSettingBody extends HookConsumerWidget {
  final String groupID;
  final Group group;
  final List<GroupUserProfile> profiles;

  const _GroupSettingBody({
    required this.groupID,
    required this.group,
    required this.profiles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider);
    final isOwner =
        group.ownerUserID != null && group.ownerUserID == currentUserID;
    final groupNameController =
        useTextEditingController(text: group.name ?? '');
    final isCreatingInvitation = useState(false);
    final isRemovingMember = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ設定'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // グループ名セクション
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('グループ名',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: groupNameController,
                        readOnly: !isOwner,
                        decoration: const InputDecoration(
                          hintText: 'グループ名を入力',
                        ),
                        onSubmitted: !isOwner
                            ? null
                            : (value) {
                                final newName = value.trim();
                                if (newName.isEmpty ||
                                    newName == (group.name ?? '')) {
                                  return;
                                }
                                ref
                                    .read(groupNameUpdateProvider(
                                        groupID: groupID))
                                    .call(name: newName);
                              },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                // メンバー一覧セクション
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text('メンバー一覧',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ...profiles.map((profile) {
                  final isProfileOwner = profile.userID == group.ownerUserID;
                  final isSelf = profile.userID == currentUserID;
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(profile.displayName ?? '名前未設定'),
                    subtitle: () {
                      if (isProfileOwner) {
                        return const Text('オーナー');
                      } else if (isSelf) {
                        return const Text('自分');
                      }
                      return null;
                    }(),
                    trailing: (isOwner && !isProfileOwner)
                        ? IconButton(
                            icon: Icon(Icons.remove_circle,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: isRemovingMember.value
                                ? null
                                : () {
                                    analytics.logEvent(
                                        name: 'tap_remove_member',
                                        parameters: {
                                          'groupID': groupID,
                                          'targetUserID': profile.userID
                                        });
                                    _showRemoveMemberDialog(
                                      context: context,
                                      ref: ref,
                                      profile: profile,
                                      isRemovingMember: isRemovingMember,
                                    );
                                  },
                          )
                        : null,
                  );
                }),
                const Divider(height: 32),

                // 買い物する場所セクション（インライン）
                _ShoppingLocationsSection(groupID: groupID),
                const Divider(height: 32),

                // カテゴリセクション（インライン）
                _CategoriesSection(groupID: groupID),
                const Divider(height: 32),

                // グループ招待セクション
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('グループ招待',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isCreatingInvitation.value
                              ? null
                              : () async {
                                  analytics.logEvent(
                                      name: 'tap_create_grp_invitation',
                                      parameters: {'groupID': groupID});
                                  isCreatingInvitation.value = true;
                                  try {
                                    final invitationCode = await ref
                                        .read(createGroupInvitationProvider)
                                        .call(groupID: groupID);
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _InvitationCodeDialog(
                                                groupID: groupID,
                                                invitationCode: invitationCode),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  } finally {
                                    isCreatingInvitation.value = false;
                                  }
                                },
                          icon: isCreatingInvitation.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.person_add),
                          label: const Text('グループに招待'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveMemberDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupUserProfile profile,
    required ValueNotifier<bool> isRemovingMember,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${profile.displayName ?? '名前未設定'}をグループから削除しますか？'),
        content: const Text('削除されたメンバーはこのグループにアクセスできなくなります'),
        actions: [
          TextButton(
            onPressed: () async {
              analytics.logEvent(
                  name: 'tap_confirm_remove_member',
                  parameters: {
                    'groupID': groupID,
                    'targetUserID': profile.userID
                  });
              Navigator.pop(dialogContext);
              isRemovingMember.value = true;
              try {
                await functions.removeGroupMember(
                  groupID: groupID,
                  targetUserID: profile.userID,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${profile.displayName ?? 'メンバー'}を削除しました')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              } finally {
                isRemovingMember.value = false;
              }
            },
            child: Text(
              '削除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_remove_member',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

// --- 買い物する場所セクション ---

class _ShoppingLocationsSection extends ConsumerWidget {
  final String groupID;

  const _ShoppingLocationsSection({required this.groupID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync =
        ref.watch(shoppingLocationsProvider(groupID: groupID));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('買い物する場所',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          locationsAsync.when(
            data: (locations) {
              if (locations.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '場所を登録すると、買い物リストのアイテムにお店を設定でき、\nお店ごとにリストを絞り込めるようになります',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_add_location',
                            parameters: {'groupID': groupID});
                        _showAddDialog(context: context, ref: ref);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('場所を追加'),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  ...locations.map((location) => ListTile(
                        leading: const Icon(Icons.store),
                        title: Text(location.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                analytics.logEvent(
                                    name: 'tap_edit_location',
                                    parameters: {
                                      'groupID': groupID,
                                      'locationID': location.id
                                    });
                                _showEditDialog(
                                  context: context,
                                  ref: ref,
                                  location: location,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () {
                                analytics.logEvent(
                                    name: 'tap_delete_location',
                                    parameters: {
                                      'groupID': groupID,
                                      'locationID': location.id
                                    });
                                _showDeleteDialog(
                                  context: context,
                                  ref: ref,
                                  location: location,
                                );
                              },
                            ),
                          ],
                        ),
                      )),
                  TextButton.icon(
                    onPressed: () {
                      analytics.logEvent(
                          name: 'tap_add_location',
                          parameters: {'groupID': groupID});
                      _showAddDialog(context: context, ref: ref);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('場所を追加'),
                  ),
                ],
              );
            },
            error: (e, st) => Text(e.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  void _showAddDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('場所を追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '場所の名前（例: スーパー）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              analytics.logEvent(
                  name: 'tap_confirm_add_location',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(shoppingLocationAddProvider(groupID: groupID))
                    .call(name: name);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('追加'),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_add_location',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupShoppingLocation location,
  }) {
    final controller = TextEditingController(text: location.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('場所を編集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '場所の名前',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              analytics.logEvent(
                  name: 'tap_save_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(shoppingLocationUpdateProvider(groupID: groupID))
                    .call(
                      shoppingLocationID: location.id,
                      shoppingLocation: location.copyWith(name: name),
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_edit_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupShoppingLocation location,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('「${location.name}」を削除しますか？'),
        content: const Text('この場所を削除しても、この場所が設定されている買い物リストには影響しません'),
        actions: [
          TextButton(
            onPressed: () async {
              analytics.logEvent(
                  name: 'tap_confirm_del_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(shoppingLocationDeleteProvider(groupID: groupID))
                    .call(shoppingLocationID: location.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(
              '削除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_del_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

// --- カテゴリ共通ダイアログ ---

void _showAddCategoryDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String groupID,
  required String categoryAxisID,
  required int currentCategoryCount,
}) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('カテゴリを追加'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'カテゴリ名（例: 野菜）',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            analytics.logEvent(
                name: 'tap_confirm_add_category',
                parameters: {'groupID': groupID});
            Navigator.pop(dialogContext);
            try {
              final category = await ref
                  .read(groupCategoryAddProvider(
                      groupID: groupID))
                  .call(
                    groupID: groupID,
                    userID: ref.read(currentUserIDProvider)!,
                    categoryAxisID: categoryAxisID,
                    name: name,
                    order: currentCategoryCount,
                  );
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupCategoryEditPage(
                      groupID: groupID,
                      categoryAxisID: categoryAxisID,
                      categoryID: category.id,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            }
          },
          child: const Text('追加'),
        ),
        TextButton(
          onPressed: () {
            analytics.logEvent(
                name: 'cancel_add_category', parameters: {'groupID': groupID});
            Navigator.pop(dialogContext);
          },
          child: const Text('キャンセル'),
        ),
      ],
    ),
  );
}

// --- カテゴリセクション ---

class _CategoriesSection extends ConsumerWidget {
  final String groupID;

  const _CategoriesSection({required this.groupID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final axesAsync =
        ref.watch(groupCategoryAxesProvider(groupID: groupID));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('カテゴリ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          axesAsync.when(
            data: (axes) {
              if (axes.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'カテゴリを登録すると、買い物リストのアイテムが自動で分類され、\n見やすくなります',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_add_first_category',
                            parameters: {'groupID': groupID});
                        _addCategoryWithAutoAxis(
                          context: context,
                          ref: ref,
                          existingAxes: axes,
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('カテゴリを追加'),
                    ),
                  ],
                );
              }
              return _CategoryListContent(
                groupID: groupID,
                axis: axes.first,
              );
            },
            error: (e, st) => Text(e.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  void _addCategoryWithAutoAxis({
    required BuildContext context,
    required WidgetRef ref,
    required List<GroupCategoryAxis> existingAxes,
  }) async {
    GroupCategoryAxis axis;
    if (existingAxes.isEmpty) {
      axis = await ref
          .read(groupCategoryAxisAddProvider(groupID: groupID))
          .call(groupID: groupID, userID: ref.read(currentUserIDProvider)!, name: 'デフォルト', order: 0);
    } else {
      axis = existingAxes.first;
    }

    if (context.mounted) {
      _showAddCategoryDialog(
        context: context,
        ref: ref,
        groupID: groupID,
        categoryAxisID: axis.id,
        currentCategoryCount: 0,
      );
    }
  }
}

class _CategoryListContent extends ConsumerWidget {
  final String groupID;
  final GroupCategoryAxis axis;

  const _CategoryListContent({
    required this.groupID,
    required this.axis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupCategoriesProvider(
        groupID: groupID, categoryAxisID: axis.id));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'カテゴリを登録すると、買い物リストのアイテムが自動で分類され、\n見やすくなります',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  analytics.logEvent(
                      name: 'tap_add_category',
                      parameters: {'groupID': groupID});
                  _showAddCategoryDialog(
                    context: context,
                    ref: ref,
                    groupID: groupID,
                    categoryAxisID: axis.id,
                    currentCategoryCount: 0,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('カテゴリを追加'),
              ),
            ],
          );
        }
        return Column(
          children: [
            ...categories.map((category) {
              final categoryColor =
                  category.color != null ? colorFromHex(category.color!) : null;
              return ListTile(
                leading: Icon(
                  categoryIconFromName(category.iconName),
                  color: categoryColor,
                ),
                title: Text(category.name),
                subtitle: Text('キーワード: ${category.keywords.length}件'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_edit_category',
                            parameters: {
                              'groupID': groupID,
                              'categoryID': category.id
                            });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GroupCategoryEditPage(
                              groupID: groupID,
                              categoryAxisID: axis.id,
                              categoryID: category.id,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_delete_category',
                            parameters: {
                              'groupID': groupID,
                              'categoryID': category.id
                            });
                        _showDeleteDialog(
                          context: context,
                          ref: ref,
                          category: category,
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                analytics.logEvent(
                    name: 'tap_add_category', parameters: {'groupID': groupID});
                _showAddCategoryDialog(
                  context: context,
                  ref: ref,
                  groupID: groupID,
                  categoryAxisID: axis.id,
                  currentCategoryCount: categories.length,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('カテゴリを追加'),
            ),
          ],
        );
      },
      error: (e, st) => Text(e.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupCategory category,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('「${category.name}」を削除しますか？'),
        content: const Text('このカテゴリに設定されたキーワードも削除されます'),
        actions: [
          TextButton(
            onPressed: () async {
              analytics.logEvent(
                  name: 'tap_confirm_del_category',
                  parameters: {'groupID': groupID, 'categoryID': category.id});
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(groupCategoryDeleteProvider(
                        groupID: groupID))
                    .call(
                      categoryAxisID: axis.id,
                      categoryID: category.id,
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(
              '削除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_del_category',
                  parameters: {'groupID': groupID, 'categoryID': category.id});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

// --- 招待コードダイアログ ---

class _InvitationCodeDialog extends StatelessWidget {
  final String groupID;
  final String invitationCode;

  const _InvitationCodeDialog(
      {required this.groupID, required this.invitationCode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('招待コード'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('以下のコードを共有してください'),
          const SizedBox(height: 16),
          SelectableText(
            invitationCode,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '有効期限: 7日間',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            analytics.logEvent(
                name: 'tap_copy_invitation_code',
                parameters: {'groupID': groupID});
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
          onPressed: () {
            analytics.logEvent(
                name: 'cancel_invitation_dialog',
                parameters: {'groupID': groupID});
            Navigator.pop(context);
          },
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
