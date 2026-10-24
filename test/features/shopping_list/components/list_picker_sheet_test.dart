import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/list_picker_sheet.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../../helpers/localized_test_app.dart';

// ListPickerSheet は本体ツリー（ListTopBar）で取得済みの AppUser を引数で受け取る。
// モーダルシートは AppEntityPrepareResolver の外に出るため、シート内で appUserProvider を
// read しても AsyncLoading(null) になりうる。値を warm な親ツリーから渡す設計。
// ここではシートのレンダリング（リスト名・選択中チェック・追加行）の回帰を検証する。
Widget _wrap(Widget child) => ProviderScope(
  child: localizedTestApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
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

/// ShoppingListAdd の呼び出し回数と完了タイミングをテスト側から制御する fake。
class _FakeShoppingListAdd implements ShoppingListAdd {
  /// call の戻り値として返す Future。Completer で完了タイミングを制御する。
  final Future<GroupShoppingList> result;

  /// call が呼ばれた回数。連打による多重実行が無いことの検証に使う。
  int callCount = 0;

  _FakeShoppingListAdd({required this.result});

  @override
  GroupDatabase get database => throw UnimplementedError();

  @override
  IsPremiumResolver get isPremiumResolver => throw UnimplementedError();

  @override
  Future<void> Function() get premiumEntitlementSyncer =>
      throw UnimplementedError();

  @override
  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) {
    callCount++;
    return result;
  }
}

/// ListPickerSheet を実際のモーダルルートとして開くテスト用ホーム。
/// pop し過ぎ(#372)の検証では、本 Widget のルートが Navigator に残っていることを確認する。
class _SheetHost extends StatelessWidget {
  /// モーダルとして表示する ListPickerSheet。
  final ListPickerSheet sheet;

  const _SheetHost({required this.sheet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => sheet,
            );
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

/// _SheetHost をホームに据え、shoppingListAddProvider を fake に差し替えた
/// アプリツリーを pump してシートを開いた状態まで進める。
Future<void> _pumpSheetHost(
  WidgetTester tester, {
  required _FakeShoppingListAdd fake,
  required void Function(String newID) onShoppingListIDChanged,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shoppingListAddProvider(groupID: 'group-1').overrideWith((ref) => fake),
      ],
      child: localizedTestApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: _SheetHost(
          sheet: ListPickerSheet(
            groupID: 'group-1',
            shoppingLists: [_list('list-1', '2026-06-01')],
            currentShoppingListID: 'list-1',
            onShoppingListIDChanged: onShoppingListIDChanged,
            appUser: const AppUser(id: 'user-1'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  expect(find.byType(ListPickerSheet), findsOneWidget);
}

void main() {
  testWidgets('リスト名・「新しいリストを追加」行を表示し、選択中リストのみチェックを出す', (tester) async {
    await tester.pumpWidget(
      _wrap(
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
      ),
    );

    expect(find.text('2026-05-28'), findsOneWidget);
    expect(find.text('2026-05-30'), findsOneWidget);
    expect(find.byType(ListPickerAddListRow), findsOneWidget);
    // 選択中（list-2）の行のみチェックマーク
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('追加行を連打してもリスト作成は1回だけ実行され、完了後はシートのみ閉じてホームが残る', (tester) async {
    final completer = Completer<GroupShoppingList>();
    final fake = _FakeShoppingListAdd(result: completer.future);
    final changedIDs = <String>[];
    await _pumpSheetHost(
      tester,
      fake: fake,
      onShoppingListIDChanged: changedIDs.add,
    );

    // 作成リクエスト中(未完了)に連打する
    await tester.tap(find.byType(ListPickerAddListRow));
    await tester.pump();
    await tester.tap(find.byType(ListPickerAddListRow));
    await tester.pump();

    expect(fake.callCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_list('list-new', '2026-06-10'));
    await tester.pumpAndSettle();

    expect(find.byType(ListPickerSheet), findsNothing);
    expect(find.byType(_SheetHost), findsOneWidget);
    expect(changedIDs, ['list-new']);
  });

  testWidgets('作成リクエスト中にシートを手動で閉じても、遅延した pop がホームを剥がさない(#372)', (tester) async {
    final completer = Completer<GroupShoppingList>();
    final fake = _FakeShoppingListAdd(result: completer.future);
    final changedIDs = <String>[];
    await _pumpSheetHost(
      tester,
      fake: fake,
      onShoppingListIDChanged: changedIDs.add,
    );

    await tester.tap(find.byType(ListPickerAddListRow));
    await tester.pump();

    // バリアタップ・スワイプ相当の手動クローズ
    Navigator.of(tester.element(find.byType(_SheetHost))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(ListPickerSheet), findsNothing);

    completer.complete(_list('list-new', '2026-06-10'));
    await tester.pumpAndSettle();

    // 修正前はここで遅延した pop がホームまで剥がし、真っ黒な画面になっていた
    expect(find.byType(_SheetHost), findsOneWidget);
    expect(changedIDs, ['list-new']);
  });
}
