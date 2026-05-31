import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/settings/page.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// ShoppingListPage の最上段（高さ 52）。
/// `design_handoff_shopping_list/source/screens-list.jsx#ListTopBar` 相当。
/// 左にリスト名 + ▼（タップでリスト切替シート）、右にアバタースタック + 設定アイコン。
class ListTopBar extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final void Function(String newID) onShoppingListIDChanged;

  const ListTopBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final memberProfiles =
        ref.watch(groupUserProfilesProvider(groupID: groupID)).asData?.value ??
            const <GroupUserProfile>[];

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: shoppingLists.isEmpty
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
                          builder: (_) => ListPickerSheet(
                            groupID: groupID,
                            shoppingLists: shoppingLists,
                            currentShoppingListID: shoppingListID,
                            onShoppingListIDChanged: onShoppingListIDChanged,
                            // 実処理は本体ツリー（ここ）で実行する。モーダルシートの
                            // スコープでは appUserProvider 等が温まらず AsyncLoading の
                            // ままになるため、シート内で ref.read しても null になる。
                            onCreateNewList: (sheetContext) async {
                              final appUser =
                                  ref.read(appUserProvider).asData?.value;
                              final sheetNavigator =
                                  Navigator.of(sheetContext);
                              final messenger = ScaffoldMessenger.of(context);
                              if (appUser == null) {
                                sheetNavigator.pop();
                                return;
                              }
                              try {
                                final newList = await ref
                                    .read(shoppingListAddProvider(
                                        groupID: groupID))
                                    .call(
                                      createUserID: appUser.id,
                                      groupID: groupID,
                                      shoppingLocationID: null,
                                      duplicatedFromGroupShoppingListID: null,
                                    );
                                sheetNavigator.pop();
                                onShoppingListIDChanged(newList.id);
                              } on ShoppingListLimitExceededException catch (e) {
                                sheetNavigator.pop();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    action: SnackBarAction(
                                      label: 'アップグレード',
                                      onPressed: () =>
                                          showPaywall(context: context),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                sheetNavigator.pop();
                                messenger.showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          ),
                        );
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        shoppingList?.name ?? '買い物リスト',
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
            if (memberProfiles.isNotEmpty)
              _AvatarStack(
                profiles: memberProfiles,
                cardColor: tokens.neutral.surface,
              ),
            IconButton(
              key: const Key('list_setting_button'),
              icon: Icon(
                Icons.more_horiz,
                size: 22,
                color: tokens.neutral.ink2,
              ),
              tooltip: 'リスト設定',
              onPressed: shoppingList == null
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
                        builder: (sheetContext) => ShoppingListSettingPage(
                          groupID: groupID,
                          shoppingListID: shoppingListID,
                          shoppingList: shoppingList!,
                          onDelete: () {
                            ref
                                .read(shoppingListDeleteProvider(
                                    groupID: groupID))
                                .call(shoppingListID: shoppingListID);
                            Navigator.of(sheetContext)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      );
                    },
            ),
            IconButton(
              key: const Key('app_settings_button'),
              icon: Icon(
                Icons.settings_outlined,
                size: 22,
                color: tokens.neutral.ink2,
              ),
              tooltip: '設定',
              onPressed: () {
                analytics.logEvent(name: 'tap_open_app_setting');
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// メンバーアバターを最大 3 つ重ねて表示。超過分は `+N` で表示する。
class _AvatarStack extends StatelessWidget {
  final List<GroupUserProfile> profiles;
  final Color cardColor;
  static const int _max = 3;

  const _AvatarStack({required this.profiles, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final visible = profiles.take(_max).toList();
    final overflow = profiles.length - visible.length;

    final children = <Widget>[];
    for (final (index, profile) in visible.indexed) {
      children.add(Positioned(
        left: index * 20.0,
        child: _Avatar(profile: profile, borderColor: cardColor),
      ));
    }
    if (overflow > 0) {
      children.add(Positioned(
        left: visible.length * 20.0,
        child: _OverflowAvatar(count: overflow, borderColor: cardColor),
      ));
    }

    final width = (visible.length + (overflow > 0 ? 1 : 0)) * 20.0 + 8;
    return SizedBox(
      width: width,
      height: 28,
      child: Stack(children: children),
    );
  }
}

class _Avatar extends StatelessWidget {
  final GroupUserProfile profile;
  final Color borderColor;
  const _Avatar({required this.profile, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final initial = (profile.displayName?.isNotEmpty ?? false)
        ? profile.displayName!.substring(0, 1).toUpperCase()
        : '?';
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.accentSoft,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.accentInk,
            ),
      ),
    );
  }
}

class _OverflowAvatar extends StatelessWidget {
  final int count;
  final Color borderColor;
  const _OverflowAvatar({required this.count, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.neutral.surface2,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: tokens.neutral.ink2,
            ),
      ),
    );
  }
}
