import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/utils/export_text_formatter.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

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
    // UI 表示用途は customerInfoProvider を使う。Promotional Entitlement 経由の付与でも
    // 即座に反映できる (Custom Claims はリアルタイムに更新されない)。
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    void autoSave(GroupShoppingList updated) {
      shoppingList.value = updated;
      ref.read(shoppingListUpdateProvider(groupID: groupID))(
        shoppingListID: shoppingListID,
        shoppingList: updated,
      );
    }

    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('買い物リスト設定'),
        backgroundColor: neutral.paper,
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
                      Text('買い物リスト名',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
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
                      Text('買い物する場所',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
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
                // i-21 自動通知 (リスト単位): `design_handoff_shopping_list/preview/screens-list-settings.jsx` 準拠。
                // グローバル通知設定 (SharedPreferences) と AND で評価される。
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('アイテム追加で家族に通知',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      'このリストでアイテム追加・チェック切替があったとき',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: shoppingList.value.autoNotifyEnabled,
                    onChanged: (value) {
                      analytics.logEvent(
                        name: 'toggle_list_auto_notify',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                          'value': value.toString(),
                        },
                      );
                      autoSave(shoppingList.value
                          .copyWith(autoNotifyEnabled: value));
                    },
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
                      Text('買い物リストの保存期間',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (isPremium)
                        const Row(
                          children: [
                            Icon(Icons.all_inclusive, size: 16),
                            SizedBox(width: 4),
                            Text('プレミアム: 無制限'),
                          ],
                        )
                      else
                        const Row(
                          children: [
                            Icon(Icons.calendar_month, size: 16),
                            SizedBox(width: 4),
                            Text('作成から30日間表示されます'),
                          ],
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
                      Text('グループ招待',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
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
                      Text('グループ管理',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
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
                _ListActionsSection(
                  groupID: groupID,
                  shoppingListID: shoppingListID,
                  shoppingList: shoppingList.value,
                  isPremium: isPremium,
                ),
                const Divider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppPill(
                      label: '買い物リストを削除',
                      icon: Icons.delete_outline,
                      variant: AppPillVariant.danger,
                      large: true,
                      expanded: true,
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
                                  style: TextStyle(color: neutral.danger),
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

/// 「リストの操作」セクション。複製 / エクスポートを集約する。
/// 旧 `ShoppingListAppBar` のメニューから移植したロジック。
class _ListActionsSection extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final GroupShoppingList shoppingList;
  final bool isPremium;
  const _ListActionsSection({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingList,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListItems = ref
            .watch(textShoppingListItemsProvider(
              groupID: groupID,
              shoppingListID: shoppingListID,
              showChecked: true,
            ))
            .valueOrNull ??
        const <GroupShoppingListItem>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('リストの操作',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                analytics.logEvent(name: 'tap_duplicate_list', parameters: {
                  'groupID': groupID,
                  'sourceShoppingListID': shoppingListID,
                });
                try {
                  await ref
                      .read(shoppingListDuplicateProvider(groupID: groupID))
                      .call(
                        createUserID: shoppingList.createUserID,
                        groupID: groupID,
                        sourceShoppingList: shoppingList,
                        shoppingListItems: shoppingListItems,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('リストを複製しました')),
                    );
                  }
                } on ShoppingListLimitExceededException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        action: SnackBarAction(
                          label: 'アップグレード',
                          onPressed: () => showPaywall(context: context),
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
              icon: const Icon(Icons.content_copy_outlined),
              label: const Text('現在のリストを複製'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                analytics
                    .logEvent(name: 'tap_export_shopping_list', parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                });
                if (!isPremium) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'リストのエクスポートはプレミアム機能です。プレミアムにアップグレードすると利用できます'),
                      action: SnackBarAction(
                        label: 'アップグレード',
                        onPressed: () => showPaywall(context: context),
                      ),
                    ),
                  );
                  return;
                }
                try {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) {
                    throw StateError('共有シートの表示位置を取得できませんでした');
                  }
                  await SharePlus.instance.share(
                    ShareParams(
                      text: buildShoppingListExportText(
                        shoppingListName: shoppingList.name,
                        shoppingListItems: shoppingListItems,
                      ),
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('リストをエクスポート'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationCodeDialog extends StatelessWidget {
  final String invitationCode;

  const _InvitationCodeDialog({required this.invitationCode});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return AlertDialog(
      title: const Text('招待コード'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '以下のコードを共有してください',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: neutral.ink2),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: neutral.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: neutral.divider, width: 0.5),
            ),
            child: SelectableText(
              invitationCode,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
                color: neutral.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '有効期限: 7日間',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: neutral.ink3),
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
