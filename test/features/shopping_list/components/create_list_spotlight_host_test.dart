import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/spotlight/spotlight_view.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_spotlight.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// CreateListSpotlightHost の表示・非表示と、表示時の SharedPreferences 記録を検証する(Issue #494)。
/// 送信系(Firebase)を伴わないため widget test で完結する。
const _groupID = 'group-001';

/// 指定した作成日時のリストを1件返す。
GroupShoppingList _list({required DateTime createdDateTime}) =>
    GroupShoppingList(
      id: 'list-001',
      createUserID: 'user-001',
      groupID: _groupID,
      shoppingLocationID: null,
      duplicatedFromGroupShoppingListID: null,
      ttlExpiresDateTime: null,
      createdDateTime: createdDateTime,
    );

/// Host を override 済みコンテナ下に pump する。target には固定サイズの箱を置く。
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required GroupShoppingList shoppingList,
}) async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
    ],
  );
  addTearDown(container.dispose);
  appProviderContainer = container;

  final targetKey = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(key: targetKey, width: 40, height: 40),
              CreateListSpotlightHost(
                groupID: _groupID,
                shoppingLists: [shoppingList],
                shoppingListItems: const [],
                targetKey: targetKey,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // 初回データ到達後の post-frame 評価 → Overlay 挿入 → フェードイン、を反映させる。
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return container;
}

void main() {
  testWidgets('条件成立(昨日作成)でスポットライトを表示し、表示日時を記録する', (tester) async {
    // 24時間前 = 常に前日の日付。cond1 が成立する。
    final container = await _pump(
      tester,
      shoppingList: _list(
        createdDateTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    expect(find.byType(SpotlightView), findsOneWidget);
    // 表示した時点で最終表示日時が記録される(dismiss 時ではない)。
    expect(
      container.read(
        stringSharedPreferencesProvider(
          key: StringKey.createListSpotlightLastShownDateTime,
        ),
      ),
      isNotNull,
    );
  });

  testWidgets('条件不成立(本日作成・チェック無し)ではスポットライトを表示せず記録もしない', (tester) async {
    final container = await _pump(
      tester,
      shoppingList: _list(createdDateTime: DateTime.now()),
    );

    expect(find.byType(SpotlightView), findsNothing);
    expect(
      container.read(
        stringSharedPreferencesProvider(
          key: StringKey.createListSpotlightLastShownDateTime,
        ),
      ),
      isNull,
    );
  });

  // ルート遷移中の localToGlobal はスライド中座標を返し切り抜き位置がずれるため、遷移完了まで表示を保留する。
  // push の入場アニメーションでこのガードを再現する(遷移中は非表示、完了後に表示)。
  testWidgets('ルート遷移中は表示を保留し、遷移完了後に表示する', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      ],
    );
    addTearDown(container.dispose);
    appProviderContainer = container;

    final targetKey = GlobalKey();
    final shoppingList = _list(
      createdDateTime: DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // ホストを含むページを push する(入場アニメーションが走る)。
    appNavigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder:
            (context) => Scaffold(
              body: Column(
                children: [
                  SizedBox(key: targetKey, width: 40, height: 40),
                  CreateListSpotlightHost(
                    groupID: _groupID,
                    shoppingLists: [shoppingList],
                    shoppingListItems: const [],
                    targetKey: targetKey,
                  ),
                ],
              ),
            ),
      ),
    );

    // 遷移中(入場アニメーション途中)は測定・表示しない。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(SpotlightView), findsNothing);

    // 遷移完了後に表示される。
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsOneWidget);
  });
}
