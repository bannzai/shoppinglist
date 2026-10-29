import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/retention_banner.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_menu_button.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/keyboard_close_toolbar.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_pill.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../helpers/localized_test_app.dart';
import '../../helpers/merge_provider_overrides.dart';

/// ソフトキーボード表示中の下部浮遊要素の扱い(進捗ピルは隠す・FAB は隠さず表示し続けて
/// キーボードを閉じる導線にする。Issue #498)を検証する。
/// キーボードは MediaQuery.viewInsets で疑似的に再現する
/// (ShoppingListPage は Scaffold の外側で viewInsets を読むため、ここで注入した値が効く)。
Future<void> _pumpPage(
  WidgetTester tester, {
  required bool isKeyboardVisible,
  int? itemCount,
}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: mergeProviderOverrides(
        base: previewProviderOverrides(sharedPreferences: sharedPreferences),
        // itemCount 指定時はアイテム件数を差し替える
        // (RetentionBanner の表示条件 totalCount > 50 の検証用)。
        extra: [
          if (itemCount != null)
            textShoppingListItemsProvider(
              groupID: mockGroupID,
              shoppingListID: mockShoppingListID,
            ).overrideWith(
              (ref) => Stream.value([
                for (var i = 0; i < itemCount; i++)
                  GroupShoppingListItem(
                    id: 'keyboard-visibility-item-$i',
                    groupID: mockGroupID,
                    shoppingListID: mockShoppingListID,
                    userID: mockUserID,
                    message: 'アイテム$i',
                    order: i,
                    status: GroupShoppingListItemStatus.unchecked,
                    checkedByUserID: null,
                    color: null,
                    description: null,
                    imageURL: null,
                    lastEditedByUserID: null,
                  ),
              ]),
            ),
        ],
      ),
      child: localizedTestApp(
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

  testWidgets('キーボード表示時は進捗ピルを隠し FAB は表示し続ける', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    expect(
      find.byType(ExpandableFab),
      findsOneWidget,
      reason: 'FAB は隠さずタップ・長押しでキーボードを閉じる導線にする(Issue #498)',
    );
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

  testWidgets('キーボード表示中の FAB は閉じるツールバーと重ならない位置に持ち上がる', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    // FAB は body 下端に出る KeyboardCloseToolbar の高さ分持ち上がるため、
    // FAB の下端はツールバーの上端より上にある(右端の閉じるボタンを塞がない)。
    expect(
      tester.getBottomRight(find.byType(FloatingActionButton)).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byType(KeyboardCloseToolbar)).dy,
      ),
    );
  });

  testWidgets('キーボード表示中は保持期限バナー(RetentionBanner)を隠す', (tester) async {
    // 非プレミアム(previewProviderOverrides の既定) + 51 件でバナー表示条件を満たす。
    await _pumpPage(tester, isKeyboardVisible: true, itemCount: 51);

    expect(
      find.byType(RetentionBanner),
      findsNothing,
      reason: 'ツールバー分持ち上げた FAB がバナー右側の操作領域と重なるため隠す(Issue #498)',
    );
  });

  testWidgets('キーボード非表示時は保持期限バナー(RetentionBanner)を表示する', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: false, itemCount: 51);

    expect(find.byType(RetentionBanner), findsOneWidget);
  });

  testWidgets('キーボード表示中に FAB をタップするとフォーカスが外れ空行は追加されない', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    // アイテム行の TextField にフォーカスを当てて入力中の状態を作る。
    await tester.showKeyboard(find.byType(TextField).first);
    await tester.pump();
    final focusNode =
        tester.widget<TextField>(find.byType(TextField).first).focusNode!;
    expect(focusNode.hasFocus, isTrue);
    final textFieldCount = find.byType(TextField).evaluate().length;

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // フォーカスが外れる = 実機ではソフトキーボードが閉じる(Issue #498)。
    // 空行を追加すると新規行の autofocus でキーボードが開き直るため、行は増えない。
    expect(focusNode.hasFocus, isFalse);
    expect(find.byType(TextField).evaluate().length, textFieldCount);
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
