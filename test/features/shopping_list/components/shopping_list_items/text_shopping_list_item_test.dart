import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 検証用アイテム。message 以外は固定。
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

Future<void> _pump(WidgetTester tester, GroupShoppingListItem item) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: previewProviderOverrides(sharedPreferences: sharedPreferences),
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: TextShoppingListItemWidget(
            groupID: mockGroupID,
            textShoppingListItem: item,
            shoppingListItems: [item],
            reorderIndex: null,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// `_CircleCheckbox` の GestureDetector を特定する。
/// チェックボックスは唯一 ScaleTransition でラップされているため、その子孫の
/// GestureDetector を読み取れば private 型を参照せずに onTap の有無を検証できる。
GestureDetector _checkboxGesture(WidgetTester tester) {
  return tester.widget<GestureDetector>(
    find.descendant(
      of: find.byType(ScaleTransition),
      matching: find.byType(GestureDetector),
    ),
  );
}

void main() {
  group('TextShoppingListItemWidget の空行チェック禁止', () {
    testWidgets('空行: チェックボックスのタップが無効 (onTap == null)', (tester) async {
      await _pump(tester, _item(id: 'empty', message: ''));
      expect(_checkboxGesture(tester).onTap, isNull);
    });

    testWidgets('空白のみの行も空行扱いでタップ無効', (tester) async {
      await _pump(tester, _item(id: 'blank', message: '   '));
      expect(_checkboxGesture(tester).onTap, isNull);
    });

    testWidgets('テキストありの行: チェックボックスのタップが有効 (onTap != null)', (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      expect(_checkboxGesture(tester).onTap, isNotNull);
    });

    testWidgets('空行: 右スワイプチェックを禁止し左スワイプ削除のみ許可 (endToStart)', (tester) async {
      await _pump(tester, _item(id: 'empty', message: ''));
      expect(
        tester.widget<Dismissible>(find.byType(Dismissible)).direction,
        DismissDirection.endToStart,
      );
    });

    testWidgets('テキストありの行: 左右両方のスワイプを許可 (horizontal)', (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      expect(
        tester.widget<Dismissible>(find.byType(Dismissible)).direction,
        DismissDirection.horizontal,
      );
    });
  });

  group('TextShoppingListItemWidget の入力フィールド（Enter でキーボードを閉じない）', () {
    testWidgets('TextField は textInputAction.newline と onChanged を持ち、next/onSubmitted は使わない',
        (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      final textField = tester.widget<TextField>(find.byType(TextField));
      // actionable な action（next/done 等）は performAction で入力接続を close→reopen
      // （flutter#84240）してソフトキーボードを一瞬閉じるため使わない。改行(Enter)は
      // newline で受け、確定は onChanged の改行検知で行う。この設定が外れると
      // 「Enter のたびにキーボードが開閉する」回帰が再発する（fix-350 で実機計測して確定）。
      expect(textField.textInputAction, TextInputAction.newline);
      expect(textField.onChanged, isNotNull);
      expect(textField.onSubmitted, isNull);
      expect(textField.onEditingComplete, isNull);
    });
  });
}
