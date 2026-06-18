import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/shopping_list/components/family_notification_trigger.dart';
import 'package:shoppinglist/features/shopping_list/components/notification_member_bar.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 「自分の変更を相手に知らせたい」(Issue #430)の回帰テスト。
/// FamilyNotificationTrigger は localShoppingListItemEditCount(=hasPendingWrites 由来の
/// 自分の編集回数)が増えた時だけ家族通知バーを出す。他メンバーの編集が stream 同期されても
/// このカウントは増えないため、通知バーは出ない。
const _groupID = 'group-001';
const _listID = 'list-001';
const _meID = 'user-me';
const _otherID = 'user-other';

GroupUserProfile _profile(String userID, String name) => GroupUserProfile(
  id: GroupUserProfile.documentID(groupID: _groupID, userID: userID),
  groupID: _groupID,
  userID: userID,
  displayName: name,
);

/// テスト用コンテナを生成して appProviderContainer に差し込み、
/// FamilyNotificationTrigger と ToastOverlay を同じコンテナ下に pump する。
/// localEditCountStream で「自分の編集」イベントを駆動する。
Future<void> _pump(
  WidgetTester tester, {
  required Stream<int> localEditCountStream,
  required List<GroupUserProfile> profiles,
}) async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      currentUserIDProvider.overrideWithValue(_meID),
      groupUserProfilesProvider(
        groupID: _groupID,
      ).overrideWith((ref) => Stream.value(profiles)),
      localShoppingListItemEditCountProvider(
        groupID: _groupID,
        shoppingListID: _listID,
      ).overrideWith((ref) => localEditCountStream),
    ],
  );
  addTearDown(container.dispose);
  appProviderContainer = container;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const Scaffold(
          body: Stack(
            children: [
              FamilyNotificationTrigger(
                groupID: _groupID,
                shoppingListID: _listID,
                shoppingListName: 'テストリスト',
              ),
              ToastOverlay(),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('自分の変更(hasPendingWrites)を検知したら家族通知バーを出す', (tester) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    await _pump(
      tester,
      localEditCountStream: controller.stream,
      profiles: [_profile(_meID, '自分'), _profile(_otherID, '家族')],
    );

    expect(find.byType(NotificationMemberBar), findsNothing);

    controller.add(1); // 自分の編集を 1 回検知
    await tester.pump(); // state 反映 + postFrameCallback 予約
    await tester.pump(); // OverlayEntry insert
    await tester.pump(const Duration(milliseconds: 250)); // 表示アニメーション

    expect(find.byType(NotificationMemberBar), findsOneWidget);

    // トーストの自動消滅タイマー(5秒)を消化し、テスト終了時に pending timer を残さない。
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(NotificationMemberBar), findsNothing);
  });

  testWidgets('他メンバーの変更のみ(自分の編集イベント無し)では通知バーを出さない', (tester) async {
    // 他メンバーの変更は hasPendingWrites=false のため localEditCount が増えない。
    // = このストリームは何も emit しない状態に相当する。
    final controller = StreamController<int>();
    addTearDown(controller.close);
    await _pump(
      tester,
      localEditCountStream: controller.stream,
      profiles: [_profile(_meID, '自分'), _profile(_otherID, '家族')],
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(NotificationMemberBar), findsNothing);
  });

  testWidgets('ソログループ(他メンバー無し)では自分の変更でも出さない', (tester) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    await _pump(
      tester,
      localEditCountStream: controller.stream,
      profiles: [_profile(_meID, '自分')],
    );

    controller.add(1);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(NotificationMemberBar), findsNothing);
  });
}
