import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/components/primitives/app_divider.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/primitives/app_section_label.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list_setting/delete_confirm_dialog.dart';
import 'package:shoppinglist/features/shopping_list_setting/invitation_code_dialog.dart';
import 'package:shoppinglist/features/shopping_list_setting/shopping_location_select_page.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 買い物リスト設定画面。
/// `design_handoff_shoppinglist/preview/screens-list-settings.jsx#ShoppingListSettingPage` 準拠。
///
/// セクション構成 (上から):
/// 1. リスト名 (card-bg 入力欄 + 「確定キーで保存されます」hint)
/// 2. 買い物する場所 (単独 AppCell、タップで `ShoppingLocationSelectPage` 遷移)
/// 3. カテゴリ (単独 AppCell、タップで `GroupCategoryPage` 遷移。カテゴリは groupID 単位で共通)
/// 4. 保存期間 (アップグレード Pill 付きカード。`isPremium=false` 時のみ Pill 表示)
/// 5. 通知 (autoNotify AppCell。Web SSOT 未拡張だが UX 上残す)
/// 6. 共有 (1 card に 2 AppCell + AppDivider — 招待コード送付 / グループ設定)
/// 7. リストの操作 (1 card に 1 AppCell — 複製。Web SSOT 未拡張だが UX 上残す)
/// 8. 削除ボタン (AppPill danger large)
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
    final shoppingListState = useState(shoppingList);
    final textEditingController = useTextEditingController(
      text: shoppingListState.value.name,
    );
    final isCreatingInvitation = useState(false);
    // UI 表示用は customerInfoProvider を使う。Promotional Entitlement 経由の付与でも
    // 即座に反映できる (Custom Claims はリアルタイムに更新されない)。
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    void autoSave(GroupShoppingList updated) {
      shoppingListState.value = updated;
      ref.read(shoppingListUpdateProvider(groupID: groupID))(
        shoppingListID: shoppingListID,
        shoppingList: updated,
      );
    }

    final neutral = context.appTheme.neutral;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionLabel(text: 'リスト名'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: neutral.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  key: const ValueKey('shopping_list_name_field'),
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (value) {
                    shoppingListState.value = shoppingListState.value.copyWith(
                      name: value,
                    );
                  },
                  onSubmitted: (value) {
                    analytics.logEvent(
                      name: 'submit_list_name',
                      parameters: {
                        'groupID': groupID,
                        'shoppingListID': shoppingListID,
                      },
                    );
                    autoSave(shoppingListState.value.copyWith(name: value));
                  },
                ),
              ),
              const SizedBox(height: 14),
              const AppSectionLabel(text: '買い物する場所'),
              _ShoppingLocationCell(
                groupID: groupID,
                currentLocationID: shoppingListState.value.shoppingLocationID,
                onSelected:
                    (newID) => autoSave(
                      shoppingListState.value.copyWith(
                        shoppingLocationID: newID,
                      ),
                    ),
              ),
              const SizedBox(height: 14),
              const AppSectionLabel(text: 'カテゴリ'),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: neutral.card,
                  child: AppCell(
                    icon: Icons.category_outlined,
                    title: 'カテゴリ',
                    subtitle: '自動分類のキーワード管理',
                    onTap: () {
                      analytics.logEvent(
                        name: 'navigate_category_from_list_setting',
                        parameters: {'groupID': groupID},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupCategoryPage(groupID: groupID),
                        ),
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    switchValue: null,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppSectionLabel(text: '保存期間'),
              _StoragePeriodCard(isPremium: isPremium),
              const SizedBox(height: 14),
              const AppSectionLabel(text: '共有'),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: neutral.card,
                  child: Column(
                    children: [
                      AppCell(
                        icon: Icons.person_add_outlined,
                        title: 'グループに招待コードを送る',
                        onTap:
                            isCreatingInvitation.value
                                ? null
                                : () => _onTapInvite(
                                  context: context,
                                  ref: ref,
                                  isCreatingInvitation: isCreatingInvitation,
                                ),
                        detail: null,
                        onSwitch: null,
                        subtitle: null,
                        switchValue: null,
                      ),
                      const AppDivider(),
                      AppCell(
                        icon: Icons.people_outlined,
                        title: 'グループ設定',
                        onTap: () {
                          analytics.logEvent(
                            name: 'tap_navigate_grp_setting',
                            parameters: {'groupID': groupID},
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => GroupSettingPage(groupID: groupID),
                            ),
                          );
                        },
                        detail: null,
                        onSwitch: null,
                        subtitle: null,
                        switchValue: null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppSectionLabel(text: 'リストの操作'),
              _ListActionsCard(
                groupID: groupID,
                shoppingListID: shoppingListID,
                shoppingList: shoppingListState.value,
              ),
              const SizedBox(height: 14),
              // SSOT: screens-list-settings.jsx L55-61
              // background: dangerSoft / color: danger / radius: 14 / padding: 14px 16px
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: neutral.dangerSoft,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap:
                        () => _onTapDelete(
                          context: context,
                          ref: ref,
                          currentShoppingListName: shoppingListState.value.name,
                        ),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: neutral.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'このリストを削除',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: neutral.danger,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTapInvite({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<bool> isCreatingInvitation,
  }) async {
    analytics.logEvent(
      name: 'tap_create_list_invitation',
      parameters: {'groupID': groupID},
    );
    // Issue #432: グループ名未設定のまま招待すると混乱を招くため、招待前に名前登録を
    // 必須化する。アクション実行時のみ必要なグループ情報は build で watch せず、ここで
    // 最新値を非同期取得する（ロード中の誤判定と不要な再描画を避ける）。
    final group = await ref.read(groupProvider(groupID: groupID).future);
    if (!context.mounted) {
      return;
    }
    // この画面にはグループ名入力欄がないため、トーストからグループ設定画面へ誘導する。
    if (!group.nameIsNotEmpty) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      showGlobalActionToast(
        message: '招待する前にグループ名を設定してください',
        actionLabel: 'グループ設定',
        onAction:
            () => Navigator.push(
              rootContext,
              MaterialPageRoute(
                builder: (_) => GroupSettingPage(groupID: groupID),
              ),
            ),
      );
      return;
    }
    isCreatingInvitation.value = true;
    try {
      final invitation = await ref
          .read(createGroupInvitationProvider)
          .call(groupID: groupID);
      if (!context.mounted) {
        return;
      }
      await showGeneralDialog<void>(
        context: context,
        barrierLabel: '招待コード',
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder:
            (_, __, ___) => InvitationCodeDialog(
              invitationCode: invitation.invitationCode,
              expiresDateTime: invitation.expiresDateTime,
            ),
      );
    } catch (e, st) {
      // このページはボトムシート上に表示されるため、SnackBar は背後の
      // Scaffold に描画されて見えない。前面に出るグローバルトーストで通知する。
      showGlobalErrorToast(e, st);
    } finally {
      isCreatingInvitation.value = false;
    }
  }

  Future<void> _onTapDelete({
    required BuildContext context,
    required WidgetRef ref,
    required String currentShoppingListName,
  }) async {
    analytics.logEvent(
      name: 'tap_delete_list',
      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
    );
    final items =
        ref
            .read(
              textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
              ),
            )
            .valueOrNull ??
        const <GroupShoppingListItem>[];
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: '買い物リスト削除確認',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder:
          (_, __, ___) => DeleteConfirmDialog(
            shoppingListName: currentShoppingListName,
            itemCount: items.length,
            groupID: groupID,
            shoppingListID: shoppingListID,
            onConfirm: onDelete,
          ),
    );
  }
}

/// 「買い物する場所」セクションの単独 Cell。
/// タップで `ShoppingLocationSelectPage` に遷移し、選択結果を `onSelected` に通知する。
class _ShoppingLocationCell extends ConsumerWidget {
  final String groupID;
  final String? currentLocationID;
  final ValueChanged<String?> onSelected;

  const _ShoppingLocationCell({
    required this.groupID,
    required this.currentLocationID,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations =
        ref.watch(shoppingLocationsProvider(groupID: groupID)).valueOrNull;
    final currentName =
        locations
            ?.where((l) => l.id == currentLocationID)
            .map((l) => l.name)
            .firstOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: context.appTheme.neutral.card,
        child: AppCell(
          icon: Icons.place_outlined,
          title: currentName ?? '未設定',
          detail: '変更',
          onTap: () async {
            analytics.logEvent(
              name: 'tap_change_list_location',
              parameters: {'groupID': groupID},
            );
            final result = await pushShoppingLocationSelectPage(
              context: context,
              groupID: groupID,
              currentLocationID: currentLocationID,
            );
            if (!context.mounted) {
              return;
            }
            if (!result.changed) {
              return;
            }
            if (result.locationID == currentLocationID) {
              return;
            }
            onSelected(result.locationID);
          },
          onSwitch: null,
          subtitle: null,
          switchValue: null,
        ),
      ),
    );
  }
}

/// 保存期間カード。
/// プレミアム時は「プレミアム: 無制限」、非プレミアム時は「作成から30日間」と
/// アップグレード Pill を表示する。
class _StoragePeriodCard extends StatelessWidget {
  final bool isPremium;

  const _StoragePeriodCard({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final neutral = context.appTheme.neutral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: neutral.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: neutral.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPremium ? Icons.all_inclusive : Icons.description_outlined,
              size: 18,
              color: neutral.ink2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'プレミアム: 無制限' : '作成から30日間',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: neutral.ink,
                  ),
                ),
                if (!isPremium) ...[
                  const SizedBox(height: 2),
                  Text(
                    'プレミアムなら期限なしで残せます',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: neutral.ink3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(width: 8),
            AppPill(
              label: 'アップグレード',
              icon: Icons.workspace_premium,
              variant: AppPillVariant.soft,
              onPressed: () {
                analytics.logEvent(
                  name: 'tap_storage_period_upgrade',
                  parameters: null,
                );
                showPaywall(context: context);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// 「リストの操作」セクションの 1 card 1 Cell。
/// `_duplicate` のロジックは旧 `_ListActionsSection` (PR #283) から踏襲。
class _ListActionsCard extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final GroupShoppingList shoppingList;

  const _ListActionsCard({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref
            .watch(
              textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
              ),
            )
            .valueOrNull ??
        const <GroupShoppingListItem>[];
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: context.appTheme.neutral.card,
        child: Column(
          children: [
            AppCell(
              icon: Icons.content_copy_outlined,
              title: '現在のリストを複製',
              onTap: () => _duplicate(context: context, ref: ref, items: items),
              detail: null,
              onSwitch: null,
              subtitle: null,
              switchValue: null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _duplicate({
    required BuildContext context,
    required WidgetRef ref,
    required List<GroupShoppingListItem> items,
  }) async {
    analytics.logEvent(
      name: 'tap_duplicate_list',
      parameters: {'groupID': groupID, 'sourceShoppingListID': shoppingListID},
    );
    // このページはボトムシート上に表示されるため、SnackBar は背後の Scaffold に
    // 描画されて見えない。前面に出るグローバルトーストで通知する。
    // シートが閉じられた後でもアクションからペイウォールを開けるよう、
    // 生存し続ける root Navigator の context を束ねておく。
    final paywallContext = Navigator.of(context, rootNavigator: true).context;
    try {
      await ref
          .read(shoppingListDuplicateProvider(groupID: groupID))
          .call(
            createUserID: shoppingList.createUserID,
            groupID: groupID,
            sourceShoppingList: shoppingList,
            shoppingListItems: items,
          );
      showGlobalToast('リストを複製しました', title: null);
    } on ShoppingListLimitExceededException catch (e) {
      showGlobalActionToast(
        message: e.toString(),
        actionLabel: 'アップグレード',
        onAction: () => showPaywall(context: paywallContext),
      );
    } catch (e, st) {
      showGlobalErrorToast(e, st);
    }
  }
}
