import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

// ListPickerSheet は本体ツリー（ListTopBar）へ「新しいリスト追加」処理を委譲する。
// モーダルシートのスコープでは appUserProvider 等が AsyncLoading のままになり
// シート内で ref.read すると null になってしまうため、シート自身は onCreateNewList を
// 呼ぶだけにする設計。この委譲が壊れていないことを検証する。
Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(
        brightness: Brightness.light,
        accent: AccentPreset.shu,
      ),
      home: Scaffold(body: child),
    );

GroupShoppingList _list(String id, String name) => GroupShoppingList(
      id: id,
      createUserID: 'user-1',
      groupID: 'group-1',
      name: name,
      ttlExpiresDateTime: null,
    );

void main() {
  testWidgets('「新しいリストを追加」タップで onCreateNewList がシートの context 付きで呼ばれる',
      (tester) async {
    var createCalled = 0;
    BuildContext? passedContext;
    String? changedID;

    await tester.pumpWidget(_wrap(
      ListPickerSheet(
        groupID: 'group-1',
        shoppingLists: [_list('list-1', '2026-05-28')],
        currentShoppingListID: 'list-1',
        onShoppingListIDChanged: (id) => changedID = id,
        onCreateNewList: (sheetContext) {
          createCalled++;
          passedContext = sheetContext;
        },
      ),
    ));

    expect(find.text('新しいリストを追加'), findsOneWidget);

    await tester.tap(find.text('新しいリストを追加'));
    await tester.pump();

    // 委譲コールバックが1回だけ呼ばれ、シートの BuildContext が渡る
    expect(createCalled, 1);
    expect(passedContext, isNotNull);
    // 追加処理は委譲先の責務なので、切替コールバックはここでは呼ばれない
    expect(changedID, isNull);
  });

  testWidgets('現在選択中のリストにはチェックマークを表示する', (tester) async {
    await tester.pumpWidget(_wrap(
      ListPickerSheet(
        groupID: 'group-1',
        shoppingLists: [_list('list-1', '2026-05-28'), _list('list-2', '2026-05-30')],
        currentShoppingListID: 'list-2',
        onShoppingListIDChanged: (_) {},
        onCreateNewList: (_) {},
      ),
    ));

    expect(find.text('2026-05-28'), findsOneWidget);
    expect(find.text('2026-05-30'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
