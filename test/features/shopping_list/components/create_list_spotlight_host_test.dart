import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/spotlight/spotlight_view.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_spotlight.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// CreateListSpotlightHost の表示・非表示と、表示時の SharedPreferences 記録を検証する(Issue #494, #508)。
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
/// [spotlightLastShownIso] を渡すと表示済み状態(最終表示日時が記録済み)で開始する。
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required GroupShoppingList shoppingList,
  String? spotlightLastShownIso,
}) async {
  SharedPreferences.setMockInitialValues({
    if (spotlightLastShownIso != null)
      StringKey.createListSpotlightLastShownDateTime: spotlightLastShownIso,
  });
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

  // Issue #508: 日を跨いで cond1 が再成立しても、一度表示済みなら再表示しない(生涯1回のみ)。
  testWidgets('表示済み(前日に表示)なら、日を跨いで条件成立でも再表示しない', (tester) async {
    await _pump(
      tester,
      shoppingList: _list(
        createdDateTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // 前日に表示済み。従来(Issue #494)は日付が変わると再表示していた。
      spotlightLastShownIso:
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    );

    expect(find.byType(SpotlightView), findsNothing);
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

  // 別ルート(設定画面・シート等)が Host の上にある間は current でないため評価を保留し、
  // foreground 復帰(resumed)で評価が走っても表示しない。上のルートを閉じたら post-frame 再試行で
  // 拾って表示する。非 current 時に評価を捨てると、設定画面を開いたまま復帰 → 閉じても取りこぼす
  // (codex レビュー指摘)ため、その回帰を防ぐ。
  testWidgets('別ルートが上にある間は resumed 評価でも表示せず、pop 後に表示する', (tester) async {
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

    // shoppingListItems の null(未ロード)→ 非 null(ロード完了)で初回評価タイミングを制御する。
    Widget buildApp({required List<GroupShoppingListItem>? shoppingListItems}) {
      return UncontrolledProviderScope(
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
                  shoppingListItems: shoppingListItems,
                  targetKey: targetKey,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 未ロード状態で開始する(初回 post-frame 評価はまだ走らない)。
    await tester.pumpWidget(buildApp(shoppingListItems: null));
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsNothing);

    // Host の上に別ルートを push する(以降 Host は current でない)。
    appNavigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) => const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    // アイテムがロードされ初回評価が走るが、上に別ルートがあるため表示は保留される。
    await tester.pumpWidget(buildApp(shoppingListItems: const []));
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsNothing);

    // foreground 復帰相当の評価が走っても、current でないため表示しない(評価は捨てず保留)。
    // AppLifecycleListener は隣接状態の遷移のみ許すため、background 移行→復帰を段階的に流す。
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsNothing);

    // 上のルートを閉じると、保留していた評価が post-frame 再試行で拾われ表示される。
    appNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsOneWidget);
  });

  // 保留再試行は「最新 build の attemptShow」を ref 経由で呼ぶため、保留中に props(判定材料)が
  // 変わればその最新値で評価する。別ルートで保留中に条件を成立→不成立へ変えて rebuild し、
  // pop 後に表示されないことを検証する(古い closure を掴み続けると条件成立時の値で表示してしまう。
  // codex レビュー指摘の stale closure 回帰防止)。
  testWidgets('保留中に条件が不成立へ変わったら pop 後に表示しない(最新の判定材料で評価)', (tester) async {
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

    // shoppingLists / shoppingListItems を差し替え可能にして、保留中の props 更新を再現する。
    Widget buildApp({
      required GroupShoppingList shoppingList,
      required List<GroupShoppingListItem>? shoppingListItems,
    }) {
      return UncontrolledProviderScope(
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
                  shoppingListItems: shoppingListItems,
                  targetKey: targetKey,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 未ロード状態で開始する(初回 post-frame 評価はまだ走らない)。
    final yesterdayList = _list(
      createdDateTime: DateTime.now().subtract(const Duration(days: 1)),
    );
    await tester.pumpWidget(
      buildApp(shoppingList: yesterdayList, shoppingListItems: null),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsNothing);

    // Host の上に別ルートを push する(以降 Host は current でない)。
    appNavigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) => const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    // 条件成立(昨日作成)のままアイテムをロードし、初回評価を保留状態にする。
    await tester.pumpWidget(
      buildApp(shoppingList: yesterdayList, shoppingListItems: const []),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsNothing);

    // 保留中に先頭リストの作成日時が今日に変わる(= cond1 不成立)。最新の判定材料で評価されるべき。
    final todayList = _list(createdDateTime: DateTime.now());
    await tester.pumpWidget(
      buildApp(shoppingList: todayList, shoppingListItems: const []),
    );
    await tester.pumpAndSettle();

    // 上のルートを閉じる。最新 build の attemptShow で評価されるため条件不成立で表示されない。
    appNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byType(SpotlightView), findsNothing);
  });
}
