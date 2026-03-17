import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/button.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class ShoppingListSettingPage extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final GroupShoppingList shoppingList;
  final VoidCallback onDelete;
  const ShoppingListSettingPage({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingList,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = useState(this.shoppingList);
    final textEditingController =
        useTextEditingController(text: shoppingList.value.name);
    final isCreatingInvitation = useState(false);
    final ttlExpiresDateTimeValue = shoppingList.value.ttlExpiresDateTime;

    void autoSave(GroupShoppingList updated) {
      shoppingList.value = updated;
      ref.read(shoppingListUpdateProvider(groupID: groupID))(
        shoppingListID: shoppingListID,
        shoppingList: updated,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト設定'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('買い物リスト名',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: double.infinity,
                        child: TextField(
                          key: const ValueKey('shopping_list_name_field'),
                          controller: textEditingController,
                          onChanged: (value) {
                            shoppingList.value =
                                shoppingList.value.copyWith(name: value);
                          },
                          onSubmitted: (value) {
                            analytics.logEvent(
                              name: 'submit_list_name',
                              parameters: {
                                'groupID': groupID,
                                'shoppingListID': shoppingListID,
                              },
                            );
                            autoSave(shoppingList.value.copyWith(name: value));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // 買い物する場所セクション
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('買い物する場所',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      () {
                        final locationsAsync = ref
                            .watch(shoppingLocationsProvider(groupID: groupID));
                        return locationsAsync.when(
                          data: (locations) => DropdownButtonFormField<String?>(
                            initialValue: locations.any((l) =>
                                    l.id ==
                                    shoppingList.value.shoppingLocationID)
                                ? shoppingList.value.shoppingLocationID
                                : null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('なし'),
                              ),
                              ...locations
                                  .map((location) => DropdownMenuItem<String?>(
                                        value: location.id,
                                        child: Text(location.name),
                                      )),
                            ],
                            onChanged: (value) {
                              analytics.logEvent(
                                name: 'select_list_location',
                                parameters: {
                                  'groupID': groupID,
                                  'shoppingListID': shoppingListID,
                                },
                              );
                              autoSave(shoppingList.value
                                  .copyWith(shoppingLocationID: value));
                            },
                          ),
                          error: (e, st) => Text(e.toString()),
                          loading: () => const CircularProgressIndicator(),
                        );
                      }(),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('買い物リストの保存期間',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          analytics.logEvent(
                            name: 'tap_set_list_expiration',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID,
                            },
                          );
                          final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 30)));
                          if (date != null) {
                            autoSave(shoppingList.value
                                .copyWith(ttlExpiresDateTime: date));
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.calendar_month),
                        iconAlignment: IconAlignment.start,
                        label: () {
                          if (ttlExpiresDateTimeValue != null) {
                            return Text(
                              '${DateFormat.MEd().format(ttlExpiresDateTimeValue)}まで保存されてます',
                              style: const TextStyle(),
                            );
                          } else {
                            return const Text('有効期限を設定');
                          }
                        }(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                    name: 'tap_create_list_invitation',
                                    parameters: {'groupID': groupID},
                                  );
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
                                                invitationCode: invitationCode),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                        ),
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
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('グループ管理',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            analytics.logEvent(
                              name: 'tap_navigate_grp_setting',
                              parameters: {'groupID': groupID},
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupSettingPage(
                                  groupID: groupID,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('グループ設定'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: elevatedButtonStyle.merge(
                        const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.red)),
                      ),
                      onPressed: () {
                        analytics.logEvent(
                          name: 'tap_delete_list',
                          parameters: {
                            'groupID': groupID,
                            'shoppingListID': shoppingListID,
                          },
                        );
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('買い物リストを削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  analytics.logEvent(
                                    name: 'tap_confirm_delete_list',
                                    parameters: {
                                      'groupID': groupID,
                                      'shoppingListID': shoppingListID,
                                    },
                                  );
                                  onDelete();
                                },
                                child: Text(
                                  '削除',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  analytics.logEvent(
                                    name: 'cancel_delete_list',
                                    parameters: {
                                      'groupID': groupID,
                                      'shoppingListID': shoppingListID,
                                    },
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text('キャンセル'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('買い物リストを削除'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvitationCodeDialog extends StatelessWidget {
  final String invitationCode;

  const _InvitationCodeDialog({required this.invitationCode});

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
            analytics.logEvent(name: 'tap_copy_list_invite_code');
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
            analytics.logEvent(name: 'cancel_list_invite_dialog');
            Navigator.pop(context);
          },
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
