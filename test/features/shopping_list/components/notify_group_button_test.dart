import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/shopping_list/components/notify_group_button.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 手動通知ボタン(Issue #449)の表示条件と初回説明ダイアログのゲートを検証する。
/// 送信(Firebase Functions 呼び出し)は実機 + 開発者オプションのデバッグユーザーで確認する。
const _groupID = 'group-001';
const _listID = 'list-001';
const _meID = 'user-me';
const _otherID = 'user-other';

const _buttonKey = Key('notify_group_button');

GroupUserProfile _profile(String userID, String name) => GroupUserProfile(
  id: GroupUserProfile.documentID(groupID: _groupID, userID: userID),
  groupID: _groupID,
  userID: userID,
  displayName: name,
);

/// NotifyGroupButton を override 済みコンテナ下に pump する。
/// [seenGuide] が true のとき「初回説明済み」状態を再現する。
Future<void> _pump(
  WidgetTester tester, {
  required List<GroupUserProfile> profiles,
  bool seenGuide = false,
}) async {
  SharedPreferences.setMockInitialValues(
    seenGuide ? {'hasSeenManualNotifyGuide': true} : {},
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      currentUserIDProvider.overrideWithValue(_meID),
      groupUserProfilesProvider(
        groupID: _groupID,
      ).overrideWith((ref) => Stream.value(profiles)),
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
          body: NotifyGroupButton(
            groupID: _groupID,
            shoppingListID: _listID,
            shoppingListName: 'テストリスト',
          ),
        ),
      ),
    ),
  );
  // groupUserProfilesProvider の Stream を反映させる。
  await tester.pump();
}

void main() {
  testWidgets('ソログループ(他メンバー無し)ではボタンを表示しない', (tester) async {
    await _pump(tester, profiles: [_profile(_meID, '自分')]);
    expect(find.byKey(_buttonKey), findsNothing);
  });

  testWidgets('他メンバーが居るときはボタンを表示する', (tester) async {
    await _pump(
      tester,
      profiles: [_profile(_meID, '自分'), _profile(_otherID, '家族')],
    );
    expect(find.byKey(_buttonKey), findsOneWidget);
  });

  testWidgets('初回タップで説明ダイアログが出る。キャンセルで閉じる(送信しない)', (tester) async {
    await _pump(
      tester,
      profiles: [_profile(_meID, '自分'), _profile(_otherID, '家族')],
      seenGuide: false,
    );

    expect(find.byType(AppDialogShell), findsNothing);

    await tester.tap(find.byKey(_buttonKey));
    await tester.pump(); // dialog push
    await tester.pump(const Duration(milliseconds: 200)); // 遷移アニメーション
    expect(find.byType(AppDialogShell), findsOneWidget);

    // キャンセル(Row 内の先頭 AppPill)をタップ → ダイアログが閉じ、送信パスへ進まない。
    await tester.tap(find.byType(AppPill).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(AppDialogShell), findsNothing);
  });
}

// 説明済み(seenGuide=true)で「タップ→ダイアログ無しで直接送信」する経路は
// Firebase Functions 呼び出しを伴い widget test で擬似できないため、実機 + 開発者オプションの
// デバッグユーザーで確認する(Issue #449)。
