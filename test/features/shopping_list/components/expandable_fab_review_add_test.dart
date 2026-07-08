import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// Firestore へ書き込む代わりに追加されたアイテム名を記録する [AddShoppingListItem]。
/// reviewAndAddAICandidates が確定分を実際に追加したかを検証する。
class _RecordingAddShoppingListItem extends AddShoppingListItem {
  /// call されたアイテム名を呼び出し順に保持する。
  final List<String> addedMessages = [];

  _RecordingAddShoppingListItem()
    : super(database: GroupDatabase(groupID: 'test-group'));

  @override
  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    addedMessages.add(message);
    return GroupShoppingListItem(
      id: 'item-$order',
      groupID: 'test-group',
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
  // reviewAndAddAICandidates を起動するテスト用ホストを pump する。
  // [showLauncher] を false にすると起動ボタン(呼び出し元 widget)がツリーから外れ、
  // page.dart の isKeyboardVisible が FAB を隠す状況(#486)を再現できる。
  Future<void> pumpHost(
    WidgetTester tester, {
    required _RecordingAddShoppingListItem addShoppingListItem,
    required ValueNotifier<bool> showLauncher,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: showLauncher,
            builder: (context, visible, _) {
              if (!visible) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Builder(
                  builder:
                      (launcherContext) => ElevatedButton(
                        onPressed:
                            () => reviewAndAddAICandidates(
                              context: launcherContext,
                              addShoppingListItem: addShoppingListItem,
                              shoppingListID: 'test-shopping-list',
                              userID: 'test-user',
                              shoppingListItems: const [],
                              candidateNames: const ['りんご', 'バナナ'],
                              source: 'test',
                            ),
                        child: const Text('open'),
                      ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('review sheet で確定すると選択中の候補が追加される', (tester) async {
    final addShoppingListItem = _RecordingAddShoppingListItem();
    final showLauncher = ValueNotifier(true);
    await pumpHost(
      tester,
      addShoppingListItem: addShoppingListItem,
      showLauncher: showLauncher,
    );

    expect(find.text('2 件追加'), findsOneWidget);
    await tester.tap(find.text('2 件追加'));
    await tester.pumpAndSettle();

    expect(addShoppingListItem.addedMessages, ['りんご', 'バナナ']);
  });

  testWidgets('sheet 表示中に呼び出し元 widget が unmount されても確定分が追加される(#486)', (
    tester,
  ) async {
    // 画像フローでは review sheet の候補名 TextField タップでキーボードが出ると
    // FAB がツリーから外れる。その後の確定でも追加が成功することを検証する。
    final addShoppingListItem = _RecordingAddShoppingListItem();
    final showLauncher = ValueNotifier(true);
    await pumpHost(
      tester,
      addShoppingListItem: addShoppingListItem,
      showLauncher: showLauncher,
    );

    // sheet 表示中に呼び出し元をツリーから外す(キーボード表示による FAB unmount 相当)。
    showLauncher.value = false;
    await tester.pumpAndSettle();
    expect(find.text('open'), findsNothing);
    expect(find.text('2 件追加'), findsOneWidget, reason: 'sheet は残っている');

    await tester.tap(find.text('2 件追加'));
    await tester.pumpAndSettle();

    expect(addShoppingListItem.addedMessages, ['りんご', 'バナナ']);
  });

  testWidgets('review sheet をキャンセルすると何も追加されない', (tester) async {
    final addShoppingListItem = _RecordingAddShoppingListItem();
    final showLauncher = ValueNotifier(true);
    await pumpHost(
      tester,
      addShoppingListItem: addShoppingListItem,
      showLauncher: showLauncher,
    );

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(addShoppingListItem.addedMessages, isEmpty);
  });
}
