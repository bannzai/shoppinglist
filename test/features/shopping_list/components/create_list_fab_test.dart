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

void main() {
  Future<void> pumpFab(
    WidgetTester tester, {
    required ShoppingListAdd shoppingListAdd,
    required AddShoppingListItem addShoppingListItem,
    required AppUser? appUser,
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
        ],
        child: MaterialApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: Scaffold(
            floatingActionButton: CreateListFab(groupID: 'g', appUser: appUser),
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
      appUser: const AppUser(id: 'u'),
    );

    // currentShoppingListIDProvider は autoDispose のため、実アプリでページが
    // 常時 watch している状況を再現して購読を張り、update 後の状態破棄を防ぐ。
    final currentShoppingListIDSubscription = ProviderScope.containerOf(
      tester.element(find.byType(CreateListFab)),
    ).listen(currentShoppingListIDProvider, (_, __) {});

    await tester.tap(find.byType(CreateListFab));
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
      appUser: const AppUser(id: 'u'),
    );

    await tester.tap(find.byType(CreateListFab));
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
      appUser: null,
    );

    await tester.tap(find.byType(CreateListFab));
    await tester.pumpAndSettle();

    expect(recordingListAdd.callCount, 0);
    expect(recordingItemAdd.callCount, 0);
  });
}
