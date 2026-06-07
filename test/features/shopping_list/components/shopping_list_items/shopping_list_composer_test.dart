import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_composer.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_composer_state.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

GroupShoppingListItem _item({required String id, required String message}) {
  return GroupShoppingListItem(
    id: id,
    groupID: mockGroupID,
    shoppingListID: mockShoppingListID,
    userID: mockUserID,
    message: message,
    order: 0,
    status: GroupShoppingListItemStatus.unchecked,
    checkedByUserID: null,
    color: null,
    description: null,
    imageURL: null,
    lastEditedByUserID: null,
  );
}

/// add の呼び出しを記録するスパイ。call は Firestore に触れず記録のみ。
class _SpyAdd extends AddShoppingListItem {
  _SpyAdd() : super(database: GroupDatabase(groupID: mockGroupID));
  int callCount = 0;
  String? message;
  int? order;

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
    this.message = message;
    this.order = order;
    return _item(id: 'new', message: message);
  }
}

/// update の呼び出しを記録するスパイ。
class _SpyUpdate extends UpdateShoppingListItem {
  _SpyUpdate() : super(database: GroupDatabase(groupID: mockGroupID));
  int callCount = 0;
  String? message;

  @override
  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String editedByUserID,
  }) async {
    callCount++;
    message = item.message;
  }
}

/// delete の呼び出しを記録するスパイ。
class _SpyDelete extends DeleteShoppingListItem {
  _SpyDelete() : super(database: GroupDatabase(groupID: mockGroupID));
  int callCount = 0;
  String? itemID;

  @override
  Future<void> call({
    required String shoppingListID,
    required String itemID,
  }) async {
    callCount++;
    this.itemID = itemID;
  }
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<GroupShoppingListItem> items,
  AddShoppingListItem? add,
  UpdateShoppingListItem? update,
  DeleteShoppingListItem? delete,
}) async {
  final container = ProviderContainer(overrides: [
    currentUserIDProvider.overrideWithValue(mockUserID),
    if (add != null)
      addShoppingListItemProvider(groupID: mockGroupID)
          .overrideWith((ref) => add),
    if (update != null)
      updateShoppingListItemProvider(groupID: mockGroupID)
          .overrideWith((ref) => update),
    if (delete != null)
      deleteShoppingListItemProvider(groupID: mockGroupID)
          .overrideWith((ref) => delete),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: ShoppingListComposer(
            groupID: mockGroupID,
            shoppingListID: mockShoppingListID,
            shoppingListItems: items,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  group('ShoppingListComposer', () {
    testWidgets('追加モードで改行すると addShoppingListItem が呼ばれる', (tester) async {
      final add = _SpyAdd();
      await _pump(tester, items: [], add: add);

      // 改行(\n)で確定。performAction ではなく onChanged の改行検知で追加する。
      await tester.enterText(find.byType(TextField), 'パン\n');
      await tester.pump();

      expect(add.callCount, 1);
      expect(add.message, 'パン');
      expect(add.order, 0); // nextOrder of []
    });

    testWidgets('追加モードで空のまま改行しても追加されない', (tester) async {
      final add = _SpyAdd();
      await _pump(tester, items: [], add: add);

      await tester.enterText(find.byType(TextField), '\n');
      await tester.pump();

      expect(add.callCount, 0);
    });

    testWidgets('編集モードで改行すると updateShoppingListItem が呼ばれる', (tester) async {
      final update = _SpyUpdate();
      final item = _item(id: 'x', message: '牛乳');
      final container = await _pump(tester, items: [item], update: update);

      // 行タップ相当: 編集対象IDをセット → コンポーザーがテキストを読み込む。
      container.read(editingShoppingListItemIDProvider.notifier).edit('x');
      await tester.pump();
      expect(find.text('牛乳'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '牛乳 2本\n');
      await tester.pump();

      expect(update.callCount, 1);
      expect(update.message, '牛乳 2本');
      // 確定後は新規追加モードに戻る。
      expect(container.read(editingShoppingListItemIDProvider), isNull);
    });

    testWidgets('編集モードで空にして改行すると deleteShoppingListItem が呼ばれる',
        (tester) async {
      final delete = _SpyDelete();
      final item = _item(id: 'x', message: '牛乳');
      final container = await _pump(tester, items: [item], delete: delete);

      container.read(editingShoppingListItemIDProvider.notifier).edit('x');
      await tester.pump();

      await tester.enterText(find.byType(TextField), '\n');
      await tester.pump();

      expect(delete.callCount, 1);
      expect(delete.itemID, 'x');
    });
  });
}
