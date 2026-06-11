import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_fab.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// リスト作成の呼び出しを記録するモック（Firestore を叩かない）。
class _RecordingShoppingListAdd extends ShoppingListAdd {
  int callCount = 0;

  _RecordingShoppingListAdd()
      : super(
          database: GroupDatabase(groupID: 'g'),
          isPremiumResolver: () => false,
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
  Future<void> pumpFab(
    WidgetTester tester, {
    required ShoppingListAdd shoppingListAdd,
    required AddShoppingListItem addShoppingListItem,
    required ShoppingListDuplicate shoppingListDuplicate,
    required AppUser? appUser,
    required GroupShoppingList? shoppingList,
    required List<GroupShoppingListItem> shoppingListItems,
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
        ],
        child: MaterialApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: Scaffold(
            floatingActionButton: CreateListFab(
              groupID: 'g',
              appUser: appUser,
              shoppingList: shoppingList,
              shoppingListItems: shoppingListItems,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('タップでリスト作成 → 表示切替 → 空アイテム追加まで連鎖する', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    await pumpFab(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    // currentShoppingListIDProvider は autoDispose のため、実アプリでページが
    // 常時 watch している状況を再現して購読を張り、update 後の状態破棄を防ぐ。
    final currentShoppingListIDSubscription = ProviderScope.containerOf(
      tester.element(find.byType(CreateListFab)),
    ).listen(currentShoppingListIDProvider, (_, __) {});

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙ってタップする。
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    expect(recordingListAdd.callCount, 1);
    expect(recordingItemAdd.callCount, 1, reason: '作成直後に入力行(空アイテム)を 1 件追加する');
    expect(recordingItemAdd.lastShoppingListID, 'new-list');
    expect(recordingItemAdd.lastMessage, '');
    expect(recordingItemAdd.lastOrder, 0);
    expect(
      currentShoppingListIDSubscription.read(),
      'new-list',
      reason: '作成したリストへ表示を切り替える',
    );
  });

  testWidgets('上限超過時は SnackBar を表示しアイテム追加へ進まない', (tester) async {
    final recordingItemAdd = _RecordingAddShoppingListItem();
    await pumpFab(
      tester,
      shoppingListAdd: _LimitExceededShoppingListAdd(),
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙ってタップする。
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.byType(SnackBarAction),
      findsOneWidget,
      reason: 'アップグレード導線のアクションを表示する',
    );
    expect(recordingItemAdd.callCount, 0);
  });

  testWidgets('AppUser 未ロード(null)の間はタップしても何もしない', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    await pumpFab(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: _RecordingShoppingListDuplicate(),
      appUser: null,
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙ってタップする。
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    expect(recordingListAdd.callCount, 0);
    expect(recordingItemAdd.callCount, 0);
  });

  testWidgets('長押しメニューの「今日の日付でリストを追加」はタップと同じ作成連鎖を行う', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpFab(
      tester,
      shoppingListAdd: recordingListAdd,
      addShoppingListItem: recordingItemAdd,
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: _sourceShoppingList,
      shoppingListItems: const [],
    );

    final currentShoppingListIDSubscription = ProviderScope.containerOf(
      tester.element(find.byType(CreateListFab)),
    ).listen(currentShoppingListIDProvider, (_, __) {});

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙って長押しする。
    await tester.longPress(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.today_outlined));
    await tester.pumpAndSettle();

    expect(recordingListAdd.callCount, 1);
    expect(recordingItemAdd.callCount, 1);
    expect(recordingDuplicate.callCount, 0);
    expect(currentShoppingListIDSubscription.read(), 'new-list');
  });

  testWidgets('長押しメニューの「現在のリストを複製」は全アイテムを引き継ぎ、複製先へ表示を切り替える', (tester) async {
    final recordingListAdd = _RecordingShoppingListAdd();
    final recordingItemAdd = _RecordingAddShoppingListItem();
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpFab(
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
      tester.element(find.byType(CreateListFab)),
    ).listen(currentShoppingListIDProvider, (_, __) {});

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙って長押しする。
    await tester.longPress(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.content_copy_outlined));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 1);
    expect(recordingDuplicate.lastSourceShoppingList?.id, 'current-list');
    expect(
      recordingDuplicate.lastShoppingListItems?.map((item) => item.id),
      ['unchecked-item', 'checked-item'],
      reason: 'チェック済みを含む全アイテムを引き継ぐ',
    );
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

  testWidgets('長押しメニューの「未チェックのみ引き継いで複製」はチェック済みアイテムを引き継がない', (tester) async {
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpFab(
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

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙って長押しする。
    await tester.longPress(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 1);
    expect(
      recordingDuplicate.lastShoppingListItems?.map((item) => item.id),
      ['unchecked-item-1', 'unchecked-item-2'],
      reason: 'チェック済みアイテムは引き継がない',
    );
  });

  testWidgets('複製元リスト未取得(null)の間は複製アクションをタップしても何もしない', (tester) async {
    final recordingDuplicate = _RecordingShoppingListDuplicate();
    await pumpFab(
      tester,
      shoppingListAdd: _RecordingShoppingListAdd(),
      addShoppingListItem: _RecordingAddShoppingListItem(),
      shoppingListDuplicate: recordingDuplicate,
      appUser: const AppUser(id: 'u'),
      shoppingList: null,
      shoppingListItems: const [],
    );

    // CreateListFab は展開メニューを含む Column のため、widget 中心はボタンを
    // 外れる。ボタン内の receipt アイコンを狙って長押しする。
    await tester.longPress(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.content_copy_outlined));
    await tester.pumpAndSettle();

    expect(recordingDuplicate.callCount, 0);
  });
}
