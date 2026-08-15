import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/settings/page.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_menu_button.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/features/shopping_list/components/notify_group_button.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// ShoppingListPage の最上段（高さ 52）。
/// `design_handoff_shopping_list/source/screens-list.jsx#ListTopBar` 相当。
/// 左にリスト名 + ▼（タップでリスト切替シート）、
/// 右にリスト追加・グループ通知・リスト設定・ユーザー設定のアイコン。
///
/// Scaffold の appBar スロットを使わず Column 内の通常 Widget として置いている理由:
/// - paper/surface の上にフラットに乗せ、下の白い card と段差なく繋ぐハイブリッドサーフェス
///   デザインのため。AppBar 既定の背景色・elevation・scrolledUnderElevation の色被り・
///   自動 leading / SafeArea がこのフラット表現と衝突する。
/// - このバーの上には親(ShoppingListPage)側の GroupChipsBar が並ぶ。appBar スロットは
///   1画面1つ・最上段固定のため、親子をまたぐこの並び順を表現できない。
/// - 下のリストは card 内の独立スクロールなので、AppBar のスクロール連動 elevation も不要。
class ListTopBar extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;

  /// 表示中リストのアイテム一覧（チェック済み含む全件）。
  /// リスト追加メニュー(`CreateListMenuButton`)の複製アクションで引き継ぐ。
  /// 未取得（ロード中）は null を渡し、複製アクションを無効化する（空 [] とは区別する）。
  final List<GroupShoppingListItem>? shoppingListItems;
  final void Function(String newID) onShoppingListIDChanged;

  /// リスト追加ボタンの位置を特定するための GlobalKey。
  /// スポットライト(`CreateListSpotlightHost`, Issue #494)の切り抜き対象に使う。
  final GlobalKey createListButtonKey;

  const ListTopBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.shoppingListItems,
    required this.onShoppingListIDChanged,
    required this.createListButtonKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final appUser = ref.watch(appUserProvider).asData?.value;

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap:
                    shoppingLists.isEmpty
                        ? null
                        : () {
                          analytics.logEvent(
                            name: 'tap_open_list_picker',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID,
                            },
                          );
                          FocusScope.of(context).unfocus();
                          appShowModalBottomSheet(
                            context: context,
                            builder:
                                (context) => ListPickerSheet(
                                  groupID: groupID,
                                  shoppingLists: shoppingLists,
                                  currentShoppingListID: shoppingListID,
                                  onShoppingListIDChanged:
                                      onShoppingListIDChanged,
                                  appUser: appUser,
                                ),
                          );
                        },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        shoppingList?.name ??
                            context.l10n.shoppingListDefaultName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: tokens.neutral.ink,
                          letterSpacing: -0.17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: tokens.neutral.ink2,
                    ),
                  ],
                ),
              ),
            ),
            // スポットライトの切り抜き対象を特定するため KeyedSubtree で GlobalKey を付ける。
            KeyedSubtree(
              key: createListButtonKey,
              child: CreateListMenuButton(
                groupID: groupID,
                appUser: appUser,
                shoppingList: shoppingList,
                shoppingListItems: shoppingListItems,
              ),
            ),
            NotifyGroupButton(
              groupID: groupID,
              shoppingListID: shoppingListID,
              shoppingListName: shoppingList?.name,
            ),
            IconButton(
              key: const Key('list_setting_button'),
              icon: const _SettingsBadgeIcon(baseIcon: Icons.receipt_long),
              tooltip: context.l10n.shoppingListSettingTooltip,
              onPressed:
                  shoppingList == null
                      ? null
                      : () {
                        analytics.logEvent(
                          name: 'tap_open_list_setting',
                          parameters: {
                            'groupID': groupID,
                            'shoppingListID': shoppingListID,
                          },
                        );
                        FocusScope.of(context).unfocus();
                        appShowModalBottomSheet(
                          context: context,
                          builder:
                              (sheetContext) => ShoppingListSettingPage(
                                groupID: groupID,
                                shoppingListID: shoppingListID,
                                shoppingList: shoppingList!,
                                onDelete: () {
                                  // リスト本体に加えて items / receipts サブコレクションと
                                  // Storage 画像も消すため、Firestore 直接削除ではなく
                                  // Functions (Admin SDK) 経由で削除する（Issue #421）。
                                  functions.deleteShoppingList(
                                    groupID: groupID,
                                    shoppingListID: shoppingListID,
                                  );
                                  Navigator.of(
                                    sheetContext,
                                  ).popUntil((route) => route.isFirst);
                                },
                              ),
                        );
                      },
            ),
            IconButton(
              key: const Key('app_settings_button'),
              icon: const _SettingsBadgeIcon(baseIcon: Icons.person_outline),
              tooltip: context.l10n.commonSettings,
              onPressed: () {
                analytics.logEvent(
                  name: 'tap_open_app_setting',
                  parameters: null,
                );
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 設定対象を表すベースアイコンの右下に、小さな歯車をZ軸で重ねたアイコン。
/// 歯車の下にバーの背景色(surface)の縁取り円を敷き、ベースアイコンとの重なりを視覚的に分離する。
class _SettingsBadgeIcon extends StatelessWidget {
  /// 設定対象を表すベースアイコン（例: リスト設定ならメモ、ユーザー設定なら人物）。
  final IconData baseIcon;

  const _SettingsBadgeIcon({required this.baseIcon});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;

    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(baseIcon, size: 22, color: tokens.neutral.ink2),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: tokens.neutral.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings, size: 11, color: tokens.neutral.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
