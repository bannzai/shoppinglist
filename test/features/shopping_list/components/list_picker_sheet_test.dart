import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

// ListPickerSheet は本体ツリー（ListTopBar）で取得済みの AppUser を引数で受け取る。
// モーダルシートは AppEntityPrepareResolver の外に出るため、シート内で appUserProvider を
// read しても AsyncLoading(null) になりうる。値を warm な親ツリーから渡す設計。
// ここではシートのレンダリング（リスト名・選択中チェック・追加行）の回帰を検証する。
Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          accent: AccentPreset.shu,
        ),
        home: Scaffold(body: child),
      ),
    );

GroupShoppingList _list(String id, String name) => GroupShoppingList(
      id: id,
      createUserID: 'user-1',
      groupID: 'group-1',
      name: name,
      ttlExpiresDateTime: null,
      shoppingLocationID: null,
      duplicatedFromGroupShoppingListID: null,
    );

void main() {
  testWidgets('リスト名・「新しいリストを追加」行を表示し、選択中リストのみチェックを出す', (tester) async {
    await tester.pumpWidget(_wrap(
      ListPickerSheet(
        groupID: 'group-1',
        shoppingLists: [
          _list('list-1', '2026-05-28'),
          _list('list-2', '2026-05-30'),
        ],
        currentShoppingListID: 'list-2',
        onShoppingListIDChanged: (_) {},
        appUser: null,
      ),
    ));

    expect(find.text('2026-05-28'), findsOneWidget);
    expect(find.text('2026-05-30'), findsOneWidget);
    expect(find.text('新しいリストを追加'), findsOneWidget);
    // 選択中（list-2）の行のみチェックマーク
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
