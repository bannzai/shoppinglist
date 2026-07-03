import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// ダブル FAB（リスト作成 / アイテム追加）が開閉状態を共有し、
/// もう一方を開くと前のメニューが自動的に閉じる（相互排他）ことの回帰テスト。
/// 2 つの FAB を同一 `ProviderScope`（＝共有 `shoppingListFabMenuProvider`）に載せて検証する。
const _shoppingList = GroupShoppingList(
  id: 'current-list',
  createUserID: 'creator',
  groupID: 'g',
  name: '2026-06-10',
  shoppingLocationID: null,
  duplicatedFromGroupShoppingListID: null,
  ttlExpiresDateTime: null,
);

/// アイテム追加 FAB のタップ（空行追加）を Firestore に繋がず記録するモック。
class _RecordingAddShoppingListItem extends AddShoppingListItem {
  int callCount = 0;

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
  Future<_RecordingAddShoppingListItem> pumpDoubleFab(
    WidgetTester tester,
  ) async {
    final recordingAdd = _RecordingAddShoppingListItem();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerInfoProvider.overrideWith(
            (ref) => const Stream<CustomerInfo>.empty(),
          ),
          currentUserIDProvider.overrideWithValue('u'),
          addShoppingListItemProvider(
            groupID: 'g',
          ).overrideWith((ref) => recordingAdd),
        ],
        child: MaterialApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: Scaffold(
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                CreateListFab(
                  groupID: 'g',
                  appUser: AppUser(id: 'u'),
                  shoppingList: _shoppingList,
                  shoppingListItems: [],
                ),
                SizedBox(height: 12),
                ExpandableFab(
                  groupID: 'g',
                  shoppingListID: 's',
                  shoppingListItems: [],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return recordingAdd;
  }

  testWidgets('アイテム追加メニューを開いた状態でリスト作成 FAB を押すと、アイテム追加メニューが閉じてリスト作成メニューが開く', (
    tester,
  ) async {
    await pumpDoubleFab(tester);

    // 展開メニューの行は折り畳み時も Align(heightFactor:0) でツリーに残るため、
    // 開閉判定は各 FAB のアイコンで行う（既存 FAB テストと同じ方針）:
    // - アイテム追加 FAB: 閉=add_task / 開=close、リスト作成 FAB: 閉=receipt_long / 開=close。

    // アイテム追加 FAB（FloatingActionButton）を長押しで開く（タップは空行追加）。
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(
      find.byIcon(Icons.add_task),
      findsNothing,
      reason: 'アイテム追加 FAB が開いて x になる',
    );
    expect(
      find.byIcon(Icons.receipt_long),
      findsOneWidget,
      reason: 'リスト作成 FAB は閉じたまま',
    );

    // もう一方（リスト作成 FAB）を開く。receipt_long アイコンが閉時の目印。
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    expect(
      find.byIcon(Icons.add_task),
      findsOneWidget,
      reason: 'もう一方を開くと単一状態の置き換えでアイテム追加メニューは閉じる（add_task に戻る）',
    );
    expect(
      find.byIcon(Icons.receipt_long),
      findsNothing,
      reason: 'リスト作成メニューが開いて x になる',
    );
  });

  testWidgets('リスト作成メニューを開いた状態でアイテム追加 FAB を押すと、リスト作成メニューが閉じてアイテム追加メニューが開く', (
    tester,
  ) async {
    await pumpDoubleFab(tester);

    // リスト作成 FAB を開く。
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();
    expect(
      find.byIcon(Icons.receipt_long),
      findsNothing,
      reason: 'リスト作成 FAB が開いて x になる',
    );
    expect(
      find.byIcon(Icons.add_task),
      findsOneWidget,
      reason: 'アイテム追加 FAB は閉じたまま',
    );

    // もう一方（アイテム追加 FAB）を長押しで開く（タップは空行追加）。
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(
      find.byIcon(Icons.receipt_long),
      findsOneWidget,
      reason: 'もう一方を開くと単一状態の置き換えでリスト作成メニューは閉じる（receipt_long に戻る）',
    );
    expect(
      find.byIcon(Icons.add_task),
      findsNothing,
      reason: 'アイテム追加メニューが開いて x になる',
    );
  });

  testWidgets('リスト作成メニューを開いた状態でアイテム追加 FAB をタップすると、空行を追加しつつリスト作成メニューが閉じる', (
    tester,
  ) async {
    final recordingAdd = await pumpDoubleFab(tester);

    // リスト作成 FAB を開く。
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();
    expect(
      find.byIcon(Icons.receipt_long),
      findsNothing,
      reason: 'リスト作成 FAB が開いて x になる',
    );

    // アイテム追加 FAB をタップ（addItem メニューは開いていないので空行追加パス）。
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(recordingAdd.callCount, 1, reason: 'タップで空行が追加される');
    expect(
      find.byIcon(Icons.receipt_long),
      findsOneWidget,
      reason: '行追加時に close() が走り、開いていたリスト作成メニューも閉じる',
    );
    expect(
      find.byIcon(Icons.add_task),
      findsOneWidget,
      reason: 'アイテム追加メニューは開かない（add_task のまま）',
    );
  });
}
