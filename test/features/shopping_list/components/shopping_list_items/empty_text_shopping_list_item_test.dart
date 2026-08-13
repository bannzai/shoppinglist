import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import '../../../../helpers/localized_test_app.dart';

/// 空状態ヒントカードの表示検証（Issue #462）。
/// FAB の長押しメニュー（写真 / URL から追加）は見た目から気づけないため、
/// 空状態のヒントカードに FAB と同じ add_task アイコン入りの導線行を表示する。
void main() {
  testWidgets('空状態ヒントカードに FAB 長押し導線（add_task アイコン行）が表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: const Scaffold(
            body: EmptyTextShoppingListItems(
              groupID: 'g',
              shoppingListID: 's',
              shoppingListItems: [],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byIcon(Icons.add_task),
      findsOneWidget,
      reason: 'FAB 長押しメニューへの導線行が FAB と同じアイコンで表示される',
    );
  });
}
