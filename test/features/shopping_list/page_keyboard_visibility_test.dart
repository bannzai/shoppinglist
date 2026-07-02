import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/features/shopping_list/components/progress_pill.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// ソフトキーボード表示中は下部の浮遊要素(ダブル FAB・進捗ピル)が入力行と重なるため隠す、
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
  testWidgets('キーボード非表示時はダブル FAB と進捗ピルを表示する', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: false);

    expect(find.byType(ExpandableFab), findsOneWidget);
    expect(find.byType(CreateListFab), findsOneWidget);
    expect(find.byType(ProgressPill), findsOneWidget);
  });

  testWidgets('キーボード表示時はダブル FAB と進捗ピルを隠す', (tester) async {
    await _pumpPage(tester, isKeyboardVisible: true);

    expect(find.byType(ExpandableFab), findsNothing);
    expect(find.byType(CreateListFab), findsNothing);
    expect(find.byType(ProgressPill), findsNothing);
  });
}
