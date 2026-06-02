import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Future<void> _pump(WidgetTester tester, {required bool sortByCategory}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: previewProviderOverrides(sharedPreferences: sharedPreferences),
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: ShoppingListItems(
            groupID: mockGroupID,
            shoppingListID: mockShoppingListID,
            sortByCategory: sortByCategory,
            shoppingLocationID: null,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ShoppingListItems: スクロールでキーボードを閉じる', () {
    testWidgets('フラット表示の ReorderableList が onDrag で閉じる', (tester) async {
      await _pump(tester, sortByCategory: false);
      expect(
        tester
            .widget<ReorderableList>(find.byType(ReorderableList))
            .keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );
    });

    testWidgets('カテゴリ分類表示の ListView が onDrag で閉じる', (tester) async {
      await _pump(tester, sortByCategory: true);
      expect(
        tester
            .widget<ListView>(find.byType(ListView).first)
            .keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );
    });
  });
}
