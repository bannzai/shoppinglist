import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_menu_button.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/keyboard_close_toolbar.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_pill.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// ソフトキーボード表示中は下部の浮遊要素(FAB・進捗ピル)が入力行と重なるため隠す、
/// という page.dart の挙動を検証する。キーボードは MediaQuery.viewInsets で疑似的に再現する
/// (ShoppingListPage は Scaffold の外側で viewInsets を読むため、ここで注入した値が効く)。
Future<void> _pumpPage(
  WidgetTester tester, {
  required bool isKeyboardVisible,
}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: previewProviderOverrides(sharedPreferences: sharedPreferences),
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Builder(
          builder:
              (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewInsets:
                      isKeyboardVisible
                          ? const EdgeInsets.only(bottom: 300)
                          : EdgeInsets.zero,
                ),
                child: const ShoppingListPage(),
              ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('キーボード非表示時は FAB と進捗ピルを表示する', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: false);

    expect(find.byType(ExpandableFab), findsOneWidget);
    expect(find.byType(ProgressPill), findsOneWidget);
    expect(
      find.byType(CreateListMenuButton),
      findsOneWidget,
      reason: 'リスト追加は上部バーのメニューボタン(Issue #461)',
    );
    expect(
      find.byType(KeyboardCloseToolbar),
      findsNothing,
      reason: '閉じるツールバーはキーボード表示中だけ出す(Issue #488)',
    );
  });

  testWidgets('キーボード表示時は FAB と進捗ピルを隠す', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    expect(find.byType(ExpandableFab), findsNothing);
    expect(find.byType(ProgressPill), findsNothing);
    expect(
      find.byType(CreateListMenuButton),
      findsOneWidget,
      reason: '上部バーのリスト追加ボタンはキーボードと重ならないため隠さない',
    );
    expect(
      find.byType(KeyboardCloseToolbar),
      findsOneWidget,
      reason: 'キーボードの閉じ方がわからない問題への導線(Issue #488)',
    );
  });

  testWidgets('閉じるツールバーは Scaffold body の最下部 = キーボード直上に置く', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    // Scaffold body は resizeToAvoidBottomInset でキーボード分(300)縮むため、
    // body 最下部に置いたツールバーの下端が「画面高 - キーボード高」に一致すれば
    // キーボード直上に載っている。
    expect(
      tester.getBottomLeft(find.byType(KeyboardCloseToolbar)).dy,
      tester.getSize(find.byType(MaterialApp)).height - 300,
    );
  });

  testWidgets('閉じるボタンのタップで入力行のフォーカスが外れる(キーボードが閉じる)', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    // アイテム行の TextField にフォーカスを当てて入力中の状態を作る。
    await tester.showKeyboard(find.byType(TextField).first);
    await tester.pump();
    final focusNode =
        tester.widget<TextField>(find.byType(TextField).first).focusNode!;
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.text('閉じる'));
    await tester.pump();

    // フォーカスが外れる = 実機ではソフトキーボードが閉じる。
    expect(focusNode.hasFocus, isFalse);
  });
}
