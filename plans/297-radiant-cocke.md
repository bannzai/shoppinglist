# Issue #297: ShoppingListSettingPage を design v2 Web SSOT に完全準拠させる

## Context

Issue #297 のコメント (2026-05-17 投稿) で、`ShoppingListSettingPage` (買い物リスト設定画面) が Web SSOT (`design_handoff_shoppinglist/preview/screens-list-settings.jsx`) と構造的に大きく乖離していることが指摘された。PR-4 (#266) / follow-up #283 は autoNotify Switch を足しただけで、画面全体の design v2 化はスコープ外だった。本プランで以下を達成する。

1. セクション label を SSOT 準拠の 11px uppercase letter-spaced ink2 に統一 (汎用 widget 新設)
2. 「買い物する場所」を `DropdownButtonFormField` から AppCell (タップで選択画面に遷移) に置き換え
3. 「共有」セクションを 1 card に統合 (招待コード送付 / グループ設定 を Divider で並べる)
4. 保存期間カードに「アップグレード」Pill (`AppPill soft + icon crown`) を追加 (無料時のみ)
5. 削除ダイアログを `AppDialogShell` ベース + body 文 (件数表示) + ボタン文言修正
6. 招待コード dialog を `AppDialogShell` ベース + 「共有」ボタン追加 + 動的残り時間表示 (Functions 側 `expiresDateTime` 返却拡張)
7. autoNotify Switch を AppCell 化して「通知」セクションとして残す (SSOT 拡張提案として残置)
8. 「リストの操作」(複製 / エクスポート) を AppCell 化して残す (SSOT 拡張提案として残置)

採用した判断:
- autoNotify / リスト操作 は Web SSOT 未拡張のまま「セクションとして残す」
- 招待残り時間は Functions 拡張で `expiresDateTime` を返し動的表示
- AppCell に `detail: String?` prop を追加 (Web SSOT `Cell` の `detail` 同等)

## 変更対象ファイル

### 新規

| ファイル | 役割 |
|---|---|
| `lib/components/frame/app_section_label.dart` | 11px uppercase letter-spaced ink2 のセクション見出し共通 widget |
| `lib/features/shopping_list_setting/shopping_location_select_page.dart` | 「買い物する場所」選択画面 (AppCell list, 「なし」+ locations) |
| `lib/features/shopping_list_setting/invitation_code_dialog.dart` | `AppDialogShell` + 動的残り時間 (Timer.periodic) + コピー/共有 Pill |
| `lib/features/shopping_list_setting/delete_confirm_dialog.dart` | `AppDialogShell` + 件数入り body 文 + キャンセル/削除 Pill |
| `test/features/shopping_list_setting/page_test.dart` | レイアウト widget test (セクション label / 共有 1 card / 削除 dialog / 招待 dialog) |
| `firebase/functions/src/functions/createGroupInvitation/function.test.ts` の `expiresDateTime` ケース追記 | (既存に追記) |

### 修正

| ファイル | 修正内容 |
|---|---|
| `lib/components/frame/app_cell.dart` | `detail: String?` prop を追加。chev-r の手前に `Text` 表示 |
| `lib/features/shopping_list_setting/page.dart` | 626 行を全面リファクタ。AppSectionLabel + AppSectionCard + AppCell + AppPill ベースに |
| `lib/provider/group_invitation.dart` | `CreateGroupInvitation.call` の戻りを `({String invitationCode, DateTime expiresDateTime})` に拡張 |
| `lib/utils/functions/firebase_function.dart` | `createGroupInvitation` の戻り値型を record に変更 (`expiresAt` を ISO8601 で受け取って `DateTime.parse`) |
| `firebase/functions/src/functions/createGroupInvitation/function.ts` | `data.expiresDateTime: string (ISO8601)` を追加返却 |
| `firebase/functions/src/functions/createGroupInvitation/function.test.ts` | `expiresDateTime` 返却の test 追加 |
| `lib/features/previews/screens/shopping_list_setting_preview.dart` | 招待 dialog プレビュー対応 (引数 ダミー `DateTime.now().add(7d)`) |
| `maestro/flows/design_v2_list_settings.yaml` | Cell 表示 / 共有 1 card / 削除 dialog body / 招待 dialog 「共有」ボタンを assert |

## 既存資源の再利用

- **AppCell** (`lib/components/frame/app_cell.dart`) — `detail` prop 追加のみで `Cell` SSOT に追随
- **AppSectionCard** (`lib/components/frame/app_section_card.dart`) — 1 card に複数 Cell + Divider 自動挿入の機能をそのまま使う (PR #290 group_setting の実績パターン)
- **AppDialogShell** (`lib/components/frame/app_dialog_shell.dart`) — `showGeneralDialog` 経由で blur + overlay + card (PR #286 SignOut / #291 Verifying 実績パターン)
- **AppPill** (`lib/components/frame/app_pill.dart`) — 既存 `variant` (ghost/accent/soft/danger) + `large` + `icon` + `expanded` を活用
- **ShoppingListUpdate** (`lib/provider/shopping_list.dart:139`) — autoSave 経路はそのまま
- **textShoppingListItemsProvider** (`lib/provider/shopping_list_item.dart`) — 削除 dialog の件数取得に再利用
- **share_plus 11.1.0** (`pubspec.yaml:75`) — 招待 dialog の「共有」ボタンで `SharePlus.instance.share` (`group_create/page.dart:67-69` の参照例あり)

## 具体的な実装コード

### 1. `lib/components/frame/app_cell.dart` の拡張

```dart
class AppCell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  /// 末尾 chev-r の手前に表示する補助テキスト。
  /// `design_handoff_shopping_list/preview/screens-list-settings.jsx#Cell` の
  /// `detail` 相当 (`fontSize: 13, color: ink3`)。Switch 付き Cell には表示しない。
  final String? detail;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitch;
  final bool? switchValue;
  final bool danger;

  const AppCell({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.detail,
    this.onTap,
    this.onSwitch,
    this.switchValue,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = danger ? neutral.danger : tokens.accent;
    final titleColor = danger ? neutral.danger : neutral.ink;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: neutral.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: textTheme.bodyLarge?.copyWith(color: titleColor)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: textTheme.bodySmall?.copyWith(color: neutral.ink3)),
                    ],
                  ],
                ),
              ),
              if (onSwitch != null && switchValue != null)
                Switch(value: switchValue!, onChanged: onSwitch)
              else ...[
                if (detail != null) ...[
                  Text(detail!,
                      style: textTheme.bodySmall?.copyWith(color: neutral.ink3)),
                  const SizedBox(width: 6),
                ],
                if (onTap != null)
                  Icon(Icons.chevron_right, size: 18, color: neutral.ink3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. `lib/components/frame/app_section_label.dart` (新規)

```dart
import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 設定画面のセクション見出し。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#Section` の
/// label 相当 (`fontSize: 11, fontWeight: 700, color: ink2,
/// padding: '0 12px 6px', letterSpacing: 0.05, textTransform: uppercase`)。
class AppSectionLabel extends StatelessWidget {
  /// 表示文字列。`toUpperCase()` で大文字化する。
  final String text;

  const AppSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05,
              color: context.tokens.neutral.ink2,
            ),
      ),
    );
  }
}
```

### 3. `lib/features/shopping_list_setting/shopping_location_select_page.dart` (新規)

```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_cell.dart';
import 'package:shoppinglist/components/frame/app_section_card.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// ShoppingListSettingPage の「買い物する場所」Cell から遷移する選択画面。
/// 既存 locations + 「なし」を AppCell list で表示し、タップで選択結果 (`String?`) を返す。
class ShoppingLocationSelectPage extends ConsumerWidget {
  final String groupID;
  final String? currentLocationID;

  const ShoppingLocationSelectPage({
    super.key,
    required this.groupID,
    required this.currentLocationID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(shoppingLocationsProvider(groupID: groupID));
    final neutral = context.tokens.neutral;
    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('買い物する場所を選ぶ'),
        backgroundColor: neutral.paper,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: locationsAsync.when(
        data: (locations) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 32),
          child: AppSectionCard(
            children: [
              AppCell(
                icon: Icons.block,
                title: 'なし',
                detail: currentLocationID == null ? '選択中' : null,
                onTap: () {
                  analytics.logEvent(
                    name: 'select_list_location',
                    parameters: {'groupID': groupID, 'value': 'none'},
                  );
                  Navigator.pop<String?>(context, null);
                },
              ),
              for (final location in locations)
                AppCell(
                  icon: Icons.place_outlined,
                  title: location.name,
                  detail: currentLocationID == location.id ? '選択中' : null,
                  onTap: () {
                    analytics.logEvent(
                      name: 'select_list_location',
                      parameters: {'groupID': groupID, 'locationID': location.id},
                    );
                    Navigator.pop<String?>(context, location.id);
                  },
                ),
            ],
          ),
        ),
        error: (e, st) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
```

### 4. `lib/features/shopping_list_setting/invitation_code_dialog.dart` (新規)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/components/frame/app_dialog_shell.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 招待コード表示ダイアログ。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#InviteCodeDialog` の
/// 構造に準拠: 28文字大コード (mono, surface2 背景, 1px dashed border) + 「有効期限: 7日間 ・ 残り Xd Yh」+
/// コピー (ghost) / 共有 (accent) Pill。
class InvitationCodeDialog extends HookWidget {
  final String invitationCode;
  final DateTime expiresDateTime;

  const InvitationCodeDialog({
    super.key,
    required this.invitationCode,
    required this.expiresDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final now = useState(DateTime.now());
    useEffect(() {
      final timer = Timer.periodic(const Duration(minutes: 1), (_) {
        now.value = DateTime.now();
      });
      return timer.cancel;
    }, const []);

    final neutral = context.tokens.neutral;
    final remaining = expiresDateTime.difference(now.value);
    final isExpired = remaining.isNegative;
    final remainingText = isExpired
        ? '有効期限切れ'
        : '有効期限: 7日間 ・ 残り ${remaining.inDays}日${remaining.inHours.remainder(24)}時間';

    return AppDialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('招待コード',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: neutral.ink2,
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: neutral.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: neutral.divider,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: SelectableText(
              invitationCode,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
                color: neutral.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(remainingText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: neutral.ink3)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppPill(
                  label: 'コピー',
                  icon: Icons.copy_outlined,
                  variant: AppPillVariant.ghost,
                  large: true,
                  expanded: true,
                  onPressed: () async {
                    analytics.logEvent(name: 'tap_copy_list_invite_code');
                    await Clipboard.setData(ClipboardData(text: invitationCode));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('招待コードをコピーしました')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPill(
                  label: '共有',
                  icon: Icons.ios_share_outlined,
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed: () async {
                    analytics.logEvent(name: 'tap_share_list_invite_code');
                    final box = context.findRenderObject() as RenderBox?;
                    await SharePlus.instance.share(ShareParams(
                      text: '買い物リストの招待コード: $invitationCode',
                      sharePositionOrigin:
                          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 5. `lib/features/shopping_list_setting/delete_confirm_dialog.dart` (新規)

```dart
import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/app_dialog_shell.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 買い物リスト削除確認ダイアログ。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#DeleteConfirmDialog` 準拠。
class DeleteConfirmDialog extends StatelessWidget {
  final String shoppingListName;
  final int itemCount;
  final String groupID;
  final String shoppingListID;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.shoppingListName,
    required this.itemCount,
    required this.groupID,
    required this.shoppingListID,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final neutral = context.tokens.neutral;
    return AppDialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('このリストを削除しますか?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: neutral.ink,
                  )),
          const SizedBox(height: 6),
          Text(
            '「$shoppingListName」とその中の $itemCount件 のアイテムが削除されます。元に戻せません。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: neutral.ink2,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppPill(
                  label: 'キャンセル',
                  variant: AppPillVariant.ghost,
                  large: true,
                  expanded: true,
                  onPressed: () {
                    analytics.logEvent(
                      name: 'cancel_delete_list',
                      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPill(
                  label: '削除',
                  variant: AppPillVariant.danger,
                  large: true,
                  expanded: true,
                  onPressed: () {
                    analytics.logEvent(
                      name: 'tap_confirm_delete_list',
                      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
                    );
                    onConfirm();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 6. `lib/features/shopping_list_setting/page.dart` の主要構造

主要な build メソッドの骨格 (autoSave / hooks は現行を維持):

```dart
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
          // 1. リスト名
          const AppSectionLabel(text: 'リスト名'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              onSubmitted: (value) {
                analytics.logEvent(name: 'submit_list_name', parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                });
                autoSave(shoppingList.value.copyWith(name: value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text('確定キーで保存されます',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: neutral.ink3,
                      fontSize: 11,
                    )),
          ),
          const SizedBox(height: 14),

          // 2. 買い物する場所 (単独 Cell)
          const AppSectionLabel(text: '買い物する場所'),
          _ShoppingLocationCell(
            groupID: groupID,
            currentLocationID: shoppingList.value.shoppingLocationID,
            onSelected: (newID) =>
                autoSave(shoppingList.value.copyWith(shoppingLocationID: newID)),
          ),
          const SizedBox(height: 14),

          // 3. 保存期間 (アップグレード Pill 付き)
          const AppSectionLabel(text: '保存期間'),
          _StoragePeriodCard(isPremium: isPremium),
          const SizedBox(height: 14),

          // 4. 通知 (SSOT 拡張提案中。autoNotify Switch を AppCell で保持)
          const AppSectionLabel(text: '通知'),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: neutral.card,
              child: AppCell(
                icon: Icons.notifications_outlined,
                title: 'アイテム追加で家族に通知',
                subtitle: 'このリストでアイテム追加・チェック切替があったとき',
                switchValue: shoppingList.value.autoNotifyEnabled,
                onSwitch: (value) {
                  analytics.logEvent(name: 'toggle_list_auto_notify', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                    'value': value.toString(),
                  });
                  autoSave(shoppingList.value.copyWith(autoNotifyEnabled: value));
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 5. 共有 (1 card に 2 Cell)
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
                    onTap: isCreatingInvitation.value
                        ? null
                        : () => _onTapInvite(context, ref, isCreatingInvitation),
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
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => GroupSettingPage(groupID: groupID),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 6. リストの操作 (SSOT 拡張提案中。複製 / エクスポートを AppCell で残置)
          const AppSectionLabel(text: 'リストの操作'),
          _ListActionsCard(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingList: shoppingList.value,
            isPremium: isPremium,
          ),
          const SizedBox(height: 14),

          // 7. 削除ボタン (素 AppPill danger large)
          AppPill(
            label: 'このリストを削除',
            icon: Icons.delete_outline,
            variant: AppPillVariant.danger,
            large: true,
            expanded: true,
            onPressed: () => _onTapDelete(context, ref),
          ),
        ],
      ),
    ),
  ),
);
```

`_onTapInvite` の差分 (戻り値 record 化に追随):

```dart
Future<void> _onTapInvite(BuildContext context, WidgetRef ref,
    ValueNotifier<bool> isCreatingInvitation) async {
  analytics.logEvent(
    name: 'tap_create_list_invitation',
    parameters: {'groupID': groupID},
  );
  isCreatingInvitation.value = true;
  try {
    final invitation =
        await ref.read(createGroupInvitationProvider).call(groupID: groupID);
    if (!context.mounted) return;
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: '招待コード',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, __, ___) => InvitationCodeDialog(
        invitationCode: invitation.invitationCode,
        expiresDateTime: invitation.expiresDateTime,
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  } finally {
    isCreatingInvitation.value = false;
  }
}
```

`_onTapDelete` の差分 (件数取得 + AppDialogShell 化):

```dart
Future<void> _onTapDelete(BuildContext context, WidgetRef ref) async {
  analytics.logEvent(name: 'tap_delete_list', parameters: {
    'groupID': groupID,
    'shoppingListID': shoppingListID,
  });
  final items = ref
          .read(textShoppingListItemsProvider(
            groupID: groupID,
            shoppingListID: shoppingListID,
            showChecked: true,
          ))
          .valueOrNull ??
      const <GroupShoppingListItem>[];
  await showGeneralDialog<void>(
    context: context,
    barrierLabel: '買い物リスト削除確認',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (_, __, ___) => DeleteConfirmDialog(
      shoppingListName: shoppingList.value.name,
      itemCount: items.length,
      groupID: groupID,
      shoppingListID: shoppingListID,
      onConfirm: onDelete,
    ),
  );
}
```

`_ShoppingLocationCell` / `_StoragePeriodCard` / `_ListActionsCard` は private widget として page.dart 末尾に切り出す:

```dart
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
    final currentName = locations
        ?.where((l) => l.id == currentLocationID)
        .map((l) => l.name)
        .firstOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: context.tokens.neutral.card,
        child: AppCell(
          icon: Icons.place_outlined,
          title: currentName ?? '未設定',
          detail: '変更',
          onTap: () async {
            analytics.logEvent(
              name: 'tap_change_list_location',
              parameters: {'groupID': groupID},
            );
            final result = await Navigator.push<String?>(
              context,
              MaterialPageRoute(
                builder: (_) => ShoppingLocationSelectPage(
                  groupID: groupID,
                  currentLocationID: currentLocationID,
                ),
              ),
            );
            if (!context.mounted) return;
            // Navigator.pop(null) 経路と「画面戻し」経路を区別するためフラグを使うのが本来。
            // 「なし」を表す null は SelectPage 側で明示的に pop(null) しているため、
            // pop で result == null の場合は変更しないという扱いにする。
            // (SelectPage を pop(null) で抜けた = なし選択、画面戻しは willPop で popResult なし)
            if (result == currentLocationID) return;
            onSelected(result);
          },
        ),
      ),
    );
  }
}

class _StoragePeriodCard extends StatelessWidget {
  final bool isPremium;
  const _StoragePeriodCard({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final neutral = context.tokens.neutral;
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
                Text(isPremium ? 'プレミアム: 無制限' : '作成から30日間',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: neutral.ink,
                        )),
                if (!isPremium) ...[
                  const SizedBox(height: 2),
                  Text('プレミアムなら期限なしで残せます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11.5,
                            color: neutral.ink3,
                          )),
                ],
              ],
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(width: 8),
            AppPill(
              label: 'アップグレード',
              icon: Icons.star_outline,
              variant: AppPillVariant.soft,
              onPressed: () {
                analytics.logEvent(name: 'tap_storage_period_upgrade');
                showPaywall(context: context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
```

`_ListActionsCard` は現行 `_ListActionsSection` の複製 / エクスポートロジックを保ったまま AppCell に置き換える:

```dart
class _ListActionsCard extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final GroupShoppingList shoppingList;
  final bool isPremium;
  const _ListActionsCard({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingList,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref
            .watch(textShoppingListItemsProvider(
              groupID: groupID,
              shoppingListID: shoppingListID,
              showChecked: true,
            ))
            .valueOrNull ??
        const <GroupShoppingListItem>[];
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: context.tokens.neutral.card,
        child: Column(
          children: [
            AppCell(
              icon: Icons.content_copy_outlined,
              title: '現在のリストを複製',
              onTap: () => _duplicate(context, ref, items),
            ),
            const AppDivider(),
            AppCell(
              icon: Icons.ios_share_outlined,
              title: 'リストをエクスポート',
              onTap: () => _export(context, ref, items),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _duplicate(BuildContext context, WidgetRef ref,
      List<GroupShoppingListItem> items) async {
    analytics.logEvent(name: 'tap_duplicate_list', parameters: {
      'groupID': groupID,
      'sourceShoppingListID': shoppingListID,
    });
    try {
      await ref.read(shoppingListDuplicateProvider(groupID: groupID)).call(
            createUserID: shoppingList.createUserID,
            groupID: groupID,
            sourceShoppingList: shoppingList,
            shoppingListItems: items,
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
  }

  Future<void> _export(BuildContext context, WidgetRef ref,
      List<GroupShoppingListItem> items) async {
    analytics.logEvent(name: 'tap_export_shopping_list', parameters: {
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
      await SharePlus.instance.share(ShareParams(
        text: buildShoppingListExportText(
          shoppingListName: shoppingList.name,
          shoppingListItems: items,
        ),
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
```

### 7. `firebase/functions/src/functions/createGroupInvitation/function.ts` の戻り値拡張

```ts
const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      invitationCode: z.string(),
      expiresDateTime: z.string(), // ISO8601
    }),
  }),
  ErrorResponseSchema,
]);

// ... (中略、expiresDateTime の admin.firestore.Timestamp 計算は既存のまま)

      return {
        result: "OK" as const,
        data: {
          invitationCode,
          expiresDateTime: expiresDateTime.toDate().toISOString(),
        },
      } as z.infer<typeof ResponseSchema>;
```

### 8. `lib/utils/functions/firebase_function.dart` の戻り値型変更

```dart
Future<({String invitationCode, DateTime expiresDateTime})>
    createGroupInvitation({
  required String groupID,
}) async {
  final result = await httpsCallable('createGroupInvitation').call({
    'groupID': groupID,
  });
  debugPrint('createGroupInvitation.result: ${result.data}');
  final response = mapToJSON(result.data);
  if (response['result'] != 'OK') {
    throw Exception(response['error']['message']);
  }
  return (
    invitationCode: response['data']['invitationCode'] as String,
    expiresDateTime:
        DateTime.parse(response['data']['expiresDateTime'] as String),
  );
}
```

### 9. `lib/provider/group_invitation.dart` の `CreateGroupInvitation` 拡張

```dart
class CreateGroupInvitation {
  Future<({String invitationCode, DateTime expiresDateTime})> call({
    required String groupID,
  }) async {
    return functions.createGroupInvitation(groupID: groupID);
  }
}
```

### 10. Widget test `test/features/shopping_list_setting/page_test.dart` (新規)

主要 assertion:
- `AppSectionLabel('リスト名')`, `('買い物する場所')`, `('保存期間')`, `('通知')`, `('共有')`, `('リストの操作')` が `findsOneWidget`
- 「確定キーで保存されます」hint が表示
- 「買い物する場所」AppCell の detail に「変更」、tap で `ShoppingLocationSelectPage` が push される
- 保存期間カードに `AppPill` (label: 'アップグレード') が isPremium=false 時に表示、true 時に非表示
- 共有セクションに「グループに招待コードを送る」「グループ設定」の 2 AppCell + AppDivider
- 削除ボタンタップで `DeleteConfirmDialog` が showGeneralDialog で開く

### 11. Functions test `firebase/functions/src/functions/createGroupInvitation/function.test.ts` 追記

```ts
it('returns expiresDateTime as ISO8601 string (7 days ahead)', async () => {
  const result = await callCreateGroupInvitation({ uid, groupID });
  if (result.result !== 'OK') throw new Error('expected OK');
  expect(typeof result.data.expiresDateTime).toBe('string');
  const expiresAt = new Date(result.data.expiresDateTime);
  const diffMs = expiresAt.getTime() - Date.now();
  expect(diffMs).toBeGreaterThan(6.5 * 24 * 3600 * 1000);
  expect(diffMs).toBeLessThan(7.5 * 24 * 3600 * 1000);
});
```

### 12. `maestro/flows/design_v2_list_settings.yaml` の更新

既存 36 行を以下の項目で拡張:

```yaml
# セクション label (uppercase)
- assertVisible:
    text: "リスト名"
- assertVisible:
    text: "確定キーで保存されます"
- assertVisible:
    text: "買い物する場所"
- assertVisible:
    text: "保存期間"
- assertVisible:
    text: "通知"
- assertVisible:
    text: "共有"
- assertVisible:
    text: "リストの操作"

# 共有 1 card 2 Cell
- assertVisible:
    text: "グループに招待コードを送る"
- assertVisible:
    text: "グループ設定"

# 削除ダイアログ body 文 (件数表示)
- tapOn:
    text: "このリストを削除"
- assertVisible:
    text: "このリストを削除しますか?"
- assertVisible:
    text: "アイテムが削除されます"
- tapOn:
    text: "キャンセル"
```

## 動作確認手順

1. **コード生成**:
   ```bash
   cd /Users/bannzai/ghq/github.com/bannzai/shoppinglist
   dart run build_runner build --delete-conflicting-outputs
   ```
2. **静的解析・テスト**:
   ```bash
   flutter analyze
   flutter test
   ```
3. **Firebase Functions** (`package.json` の場所が `firebase/functions/` なので注意。`.claude/rules/plan-checklist.md` 表記の `firebase/functions/functions/` は誤りで、`firebase/firebase.json` の `"source": "functions"` に整合):
   ```bash
   cd firebase/functions
   npm run lint && npm run build && npm test
   ```
4. **ビルド検証**:
   ```bash
   flutter build ios --no-codesign
   flutter build apk --debug
   ```
5. **iOS Simulator (iPhone 16 Plus) でプレビュー画面確認**:
   ```bash
   flutter run -t lib/features/previews/main_preview.dart -d "iPhone 16 Plus"
   # → previews エントリから "ShoppingListSettingPage" を選択
   # → Web SSOT (design_handoff_shoppinglist/preview/) と並べて目視確認
   ```
6. **Maestro E2E**:
   ```bash
   maestro test maestro/flows/design_v2_list_settings.yaml
   ```

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成
- [ ] Entity命名: フィールド名が省略されていない
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（timestamp等メタデータ除く）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当する場合）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `npm run lint` パス（firebase/functions/functions/ で実行）
- [ ] ビルド: `npm run build` 成功
- [ ] テスト: `npm test` 全件パス
- [ ] クライアント呼び出し関数はGenKitで定義
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
