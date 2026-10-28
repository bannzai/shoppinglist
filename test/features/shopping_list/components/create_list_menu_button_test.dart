import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_menu_button.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_fab_menu.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../../helpers/localized_test_app.dart';

/// リスト作成の呼び出しを記録するモック（Firestore を叩かない）。
class _RecordingShoppingListAdd extends ShoppingListAdd {
  int callCount = 0;

  _RecordingShoppingListAdd()
    : super(
        database: GroupDatabase(groupID: 'g'),
        isPremiumResolver: () => false,
        premiumEntitlementSyncer: () async {},
      );

  @override
  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) async {
    callCount++;
    return GroupShoppingList(
      id: 'new-list',
      createUserID: createUserID,
      groupID: groupID,
      name: '2026-06-11',
      shoppingLocationID: shoppingLocationID,
      duplicatedFromGroupShoppingListID: duplicatedFromGroupShoppingListID,
      ttlExpiresDateTime: null,
    );
  }
}

/// 無料プランの上限超過を再現するモック。
class _LimitExceededShoppingListAdd extends ShoppingListAdd {
  _LimitExceededShoppingListAdd()
    : super(
        database: GroupDatabase(groupID: 'g'),
        isPremiumResolver: () => false,
        premiumEntitlementSyncer: () async {},
      );

  @override
  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) async {
    throw const ShoppingListLimitExceededException(
      limit: freeGroupActiveShoppingListLimit,
    );
  }
}

/// アイテム追加の呼び出し内容を記録するモック（Firestore を叩かない）。
class _RecordingAddShoppingListItem extends AddShoppingListItem {
  int callCount = 0;
  String? lastShoppingListID;
  String? lastMessage;
  int? lastOrder;

  _RecordingAddShoppingListItem()
    : super(database: GroupDatabase(groupID: 'g'));

  @override
  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    callCount++;
    lastShoppingListID = shoppingListID;
    lastMessage = message;
    lastOrder = order;
    return GroupShoppingListItem(
      id: 'id',
      groupID: 'g',
      shoppingListID: shoppingListID,
      userID: userID,
      message: message,
      order: order,
      description: description,
      color: color,
      checkedByUserID: null,
      imageURL: null,
      lastEditedByUserID: null,
    );
  }
}

/// リスト複製の呼び出し内容を記録するモック（Firestore を叩かない）。
class _RecordingShoppingListDuplicate extends ShoppingListDuplicate {
  int callCount = 0;
  GroupShoppingList? lastSourceShoppingList;
  List<GroupShoppingListItem>? lastShoppingListItems;

  _RecordingShoppingListDuplicate()
    : super(
        shoppingListAdd: _RecordingShoppingListAdd(),
        addShoppingListItem: _RecordingAddShoppingListItem(),
      );

  @override
  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required GroupShoppingList sourceShoppingList,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    callCount++;
    lastSourceShoppingList = sourceShoppingList;
    lastShoppingListItems = shoppingListItems;
    return GroupShoppingList(
      id: 'duplicated-list',
      createUserID: createUserID,
      groupID: groupID,
      name: '2026-06-12',
      shoppingLocationID: sourceShoppingList.shoppingLocationID,
      duplicatedFromGroupShoppingListID: sourceShoppingList.id,
      ttlExpiresDateTime: null,
    );
  }
}

/// 複製元として渡す表示中リスト。
const _sourceShoppingList = GroupShoppingList(
  id: 'current-list',
  createUserID: 'creator',
  groupID: 'g',
  name: '2026-06-10',
  shoppingLocationID: null,
  duplicatedFromGroupShoppingListID: null,
  ttlExpiresDateTime: null,
);

/// 複製元リストのアイテムを生成する。
GroupShoppingListItem _sourceShoppingListItem({
  required String id,
  required GroupShoppingListItemStatus status,
}) {
  return GroupShoppingListItem(
    id: id,
    groupID: 'g',
    shoppingListID: _sourceShoppingList.id,
    userID: 'u',
    message: id,
    order: 0,
    status: status,
    description: null,
    color: null,
    imageURL: null,
    checkedByUserID: null,
    lastEditedByUserID: null,
  );
}

void main() {
  final buttonFinder = find.byKey(const Key('create_list_menu_button'));

  Future<void> pumpButton(
    WidgetTester tester, {
    required ShoppingListAdd shoppingListAdd,
    required AddShoppingListItem addShoppingListItem,
    required ShoppingListDuplicate shoppingListDuplicate,
    required AppUser? appUser,
    required GroupShoppingList? shoppingList,
    required List<GroupShoppingListItem>? shoppingListItems,
    // provider(選択時点の最新一覧)が build 時に渡した一覧より進んでいる状況を
    // 再現するためのオーバーライド。省略時は build 時の一覧と同じ値を返す。
    List<GroupShoppingListItem>? latestShoppingListItemsOnProvider,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListAddProvider(
            groupID: 'g',
          ).overrideWith((ref) => shoppingListAdd),
          addShoppingListItemProvider(
            groupID: 'g',
          ).overrideWith((ref) => addShoppingListItem),
          shoppingListDuplicateProvider(
            groupID: 'g',
          ).overrideWith((ref) => shoppingListDuplicate),
          textShoppingListItemsProvider(
            groupID: 'g',
            shoppingListID: _sourceShoppingList.id,
          ).overrideWith(
            (ref) => Stream.value(
              latestShoppingListItemsOnProvider ??
                  shoppingListItems ??
                  const [],
            ),
          ),
        ],
        child: localizedTestApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: Scaffold(
            // 実アプリの ListTopBar と同じく画面右上に置く（メニューの展開位置を揃える）。
            body: Align(
              alignment: Alignment.topRight,
              child: CreateListMenuButton(
                groupID: 'g',
                appUser: appUser,
                shoppingList: shoppingList,
                shoppingListItems: shoppingListItems,
              ),
            ),
          ),
        ),
      ),
    );
    // 実アプリで _ActiveShoppingList がアイテム一覧 provider を watch して保持している
    // 状況を再現して購読を張り、複製選択時の ref.read で最新一覧が取れる状態にする。
    ProviderScope.containerOf(
      tester.element(find.byType(CreateListMenuButton)),
    ).listen(
      textShoppingListItemsProvider(
        groupID: 'g',
        shoppingListID: _sourceShoppingList.id,
      ),
      (_, _) {},
    );
    await tester.pump();
  }

  testWidgets('タップでメニューが開き、タップ単体ではリスト作成しない', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    await pumpButton(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // 3 アクションのメニューが開く。
    expect(find.text('今日の日付でリストを追加'), findsOneWidget);
    expect(find.text('現在のリストを複製'), findsOneWidget);
    expect(find.text('未チェックのみ引き継いで複製'), findsOneWidget);
    // 作成はメニュー内アクションに委ねるため、タップ単体では作成連鎖は走らない。
    expect(recordingListAdd.callCount, 0);
    expect(recordingItemAdd.callCount, 0);
  });

  testWidgets('メニュー外をタップするとメニューが閉じる', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    await pumpButton(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.text('今日の日付でリストを追加'), findsOneWidget);

    // メニューはボタン（右上）から展開するため、左下はメニュー外（barrier）。
    await tester.tapAt(const Offset(10, 500));
    await tester.pumpAndSettle();

    expect(find.text('今日の日付でリストを追加'), findsNothing);
    expect(recordingListAdd.callCount, 0);
  });

  testWidgets('メニューの「今日の日付でリストを追加」はリスト作成 → 表示切替 → 空アイテム追加まで連鎖する', (
    tester,
  ) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpButton(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    // currentShoppingListIDProvider は autoDispose のため、実アプリでページが
    // 常時 watch している状況を再現して購読を張り、update 後の状態破棄を防ぐ。
    final currentShoppingListIDSubscription = ProviderScope.containerOf(
      tester.element(find.byType(CreateListMenuButton)),
    ).listen(currentShoppingListIDProvider, (_, _) {});

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('今日の日付でリストを追加'));
    await tester.pumpAndSettle();

    expect(recordingListAdd.callCount, 1);
    expect(recordingItemAdd.callCount, 1, reason: '作成直後に入力行(空アイテム)を 1 件追加する');
    expect(recordingItemAdd.lastShoppingListID, 'new-list');
    expect(recordingItemAdd.lastMessage, '');
    expect(recordingItemAdd.lastOrder, 0);
    expect(recordingDuplicate.callCount, 0);
    expect(
      currentShoppingListIDSubscription.read(),
      'new-list',
      reason: '作成したリストへ表示を切り替える',
    );
  });

  testWidgets('上限超過時は SnackBar を表示しアイテム追加へ進まない', (tester) async {
    final recordingItemAdd = _RecordingAddShoppingListItem();
    await pumpButton(
      tester,
      shoppingListAdd: _LimitExceededShoppingListAdd(),
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('今日の日付でリストを追加'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.byType(SnackBarAction),
      findsOneWidget,
      reason: 'アップグレード導線のアクションを表示する',
    );
    expect(recordingItemAdd.callCount, 0);
  });

  testWidgets('AppUser 未ロード(null)の間はタップしてもメニューが開かない', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    await pumpButton(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: null,
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // enabled: false のためメニューは開かず、作成も走らない。
    expect(find.text('今日の日付でリストを追加'), findsNothing);
    expect(recordingListAdd.callCount, 0);
    expect(recordingItemAdd.callCount, 0);
  });

  testWidgets('メニューの「現在のリストを複製」は全アイテムを引き継ぎ、複製先へ表示を切り替える', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpButton(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: [
        _sourceShoppingListItem(
          id: 'unchecked-item',
          status: GroupShoppingListItemStatus.unchecked,
        ),
        _sourceShoppingListItem(
          id: 'checked-item',
          status: GroupShoppingListItemStatus.checked,
        ),
      ],
    );

    final currentShoppingListIDSubscription = ProviderScope.containerOf(
      tester.element(find.byType(CreateListMenuButton)),
    ).listen(currentShoppingListIDProvider, (_, _) {});

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('現在のリストを複製'));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 1);
    expect(recordingDuplicate.lastSourceShoppingList?.id, 'current-list');
    expect(recordingDuplicate.lastShoppingListItems?.map((item) => item.id), [
      'unchecked-item',
      'checked-item',
    ], reason: 'チェック済みを含む全アイテムを引き継ぐ');
    expect(
      recordingListAdd.callCount,
      0,
      reason: '複製は ShoppingListDuplicate に委譲し、作成連鎖（空アイテム追加）は行わない',
    );
    expect(recordingItemAdd.callCount, 0);
    expect(
      currentShoppingListIDSubscription.read(),
      'duplicated-list',
      reason: '複製したリストへ表示を切り替える',
    );
    expect(find.byType(SnackBar), findsOneWidget, reason: '複製完了を通知する');
  });

  testWidgets('メニューの「未チェックのみ引き継いで複製」はチェック済みアイテムを引き継がない', (tester) async {
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpButton(
      tester,
      shoppingListAdd: _RecordingShoppingListAdd(),
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: [
        _sourceShoppingListItem(
          id: 'unchecked-item-1',
          status: GroupShoppingListItemStatus.unchecked,
        ),
        _sourceShoppingListItem(
          id: 'checked-item',
          status: GroupShoppingListItemStatus.checked,
        ),
        _sourceShoppingListItem(
          id: 'unchecked-item-2',
          status: GroupShoppingListItemStatus.unchecked,
        ),
      ],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('未チェックのみ引き継いで複製'));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 1);
    expect(recordingDuplicate.lastShoppingListItems?.map((item) => item.id), [
      'unchecked-item-1',
      'unchecked-item-2',
    ], reason: 'チェック済みアイテムは引き継がない');
  });

  testWidgets('複製元リスト未取得(null)の間は複製アクションが無効でタップしても何もしない', (tester) async {
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpButton(
      tester,
      shoppingListAdd: _RecordingShoppingListAdd(),
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: null,
      shoppingListItems: const [],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // メニュー自体は開く（「今日の日付でリストを追加」は使える）。
    expect(find.text('今日の日付でリストを追加'), findsOneWidget);

    await tester.tap(find.text('現在のリストを複製'));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 0);
    // 無効アクションのタップではメニューは閉じない。
    expect(find.text('現在のリストを複製'), findsOneWidget);
  });

  testWidgets('複製は選択時点の最新アイテム一覧(provider)を使う', (tester) async {
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    // メニュー表示中に unfocus 起点のフォーカス喪失保存で入力が確定し、
    // build 時に渡した一覧より provider の最新一覧が進んでいる状況を再現する。
    await pumpButton(
      tester,
      shoppingListAdd: _RecordingShoppingListAdd(),
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: [
        _sourceShoppingListItem(
          id: 'existing-item',
          status: GroupShoppingListItemStatus.unchecked,
        ),
      ],
      latestShoppingListItemsOnProvider: [
        _sourceShoppingListItem(
          id: 'existing-item',
          status: GroupShoppingListItemStatus.unchecked,
        ),
        _sourceShoppingListItem(
          id: 'just-confirmed-item',
          status: GroupShoppingListItemStatus.unchecked,
        ),
      ],
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('現在のリストを複製'));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 1);
    expect(recordingDuplicate.lastShoppingListItems?.map((item) => item.id), [
      'existing-item',
      'just-confirmed-item',
    ], reason: 'build 時の一覧ではなく選択時点の最新一覧で複製し、直前に確定した入力の欠落を防ぐ');
  });

  testWidgets('メニューを開くとアイテム追加 FAB の展開メニューを閉じる', (tester) async {
    await pumpButton(
      tester,
      shoppingListAdd: _RecordingShoppingListAdd(),
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    // 実アプリで ExpandableFab が watch して保持する状況を再現して購読を張り、
    // autoDispose による状態破棄を防ぐ。
    final fabMenuSubscription = ProviderScope.containerOf(
      tester.element(find.byType(CreateListMenuButton)),
    ).listen(shoppingListFabMenuProvider, (_, _) {});
    ProviderScope.containerOf(
      tester.element(find.byType(CreateListMenuButton)),
    ).read(shoppingListFabMenuProvider.notifier).open();
    expect(fabMenuSubscription.read(), isTrue);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(
      fabMenuSubscription.read(),
      isFalse,
      reason: 'PopupMenu の背後に FAB メニューが残り、追加メニューが 2 つ同時表示されるのを防ぐ',
    );
    expect(find.text('今日の日付でリストを追加'), findsOneWidget);
  });

  testWidgets('アイテム一覧未取得(null)の間は複製アクションが無効でタップしても何もしない', (tester) async {
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpButton(
      tester,
      shoppingListAdd: _RecordingShoppingListAdd(),
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: null,
    );

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // メニュー自体は開く（「今日の日付でリストを追加」は使える）。
    expect(find.text('今日の日付でリストを追加'), findsOneWidget);

    // ロード中に空リストとして複製されアイテムが失われるのを防ぐため無効化されている。
    await tester.tap(find.text('現在のリストを複製'));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 0);
    // 無効アクションのタップではメニューは閉じない。
    expect(find.text('現在のリストを複製'), findsOneWidget);
  });
}
