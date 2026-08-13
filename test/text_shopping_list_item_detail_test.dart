import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'helpers/localized_test_app.dart';

const _testGroupID = 'test-group-001';
const _testUserID = 'test-user-001';
const _testAxisID = 'axis-001';

/// 検証用アイテム。旧機能のデータ (description/color/imageURL) を持たせて、
/// データが残っていても編集 UI が出ないことを確認できるようにする。
const _testItem = GroupShoppingListItem(
  id: 'item-001',
  groupID: _testGroupID,
  shoppingListID: 'list-001',
  userID: _testUserID,
  message: 'コーラ',
  order: 0,
  description: '500ml ペットボトル',
  color: '#F44336',
  imageURL: 'https://example.com/item.jpg',
  checkedByUserID: null,
  lastEditedByUserID: null,
);

const _testAxis = GroupCategoryAxis(
  id: _testAxisID,
  groupID: _testGroupID,
  userID: _testUserID,
  name: 'デフォルト',
  order: 0,
);

Future<void> _pumpSheet(
  WidgetTester tester, {
  required List<GroupCategoryAxis> categoryAxes,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupCategoryAxesProvider(
          groupID: _testGroupID,
        ).overrideWith((ref) => Stream.value(categoryAxes)),
        groupCategoriesProvider(
          groupID: _testGroupID,
          categoryAxisID: _testAxisID,
        ).overrideWith((ref) => Stream.value(const <GroupCategory>[])),
      ],
      child: localizedTestApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: TextShoppingListItemDetailBottomSheet(
            groupID: _testGroupID,
            textShoppingListItem: _testItem,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group(
    'TextShoppingListItemDetailBottomSheet（Issue #464: 説明・写真・カラーの編集廃止）',
    () {
      testWidgets(
        'description/color/imageURL を持つ既存データでも編集 UI (TextField 等) を表示しない',
        (tester) async {
          await _pumpSheet(tester, categoryAxes: const []);
          // 説明入力の TextField が無い。
          expect(find.byType(TextField), findsNothing);
          // 写真追加の OutlinedButton が無い。
          expect(find.byType(OutlinedButton), findsNothing);
          // カラー選択の円 (GestureDetector で並べていた Wrap) が無い。
          expect(find.byType(Wrap), findsNothing);
        },
      );

      testWidgets('アイテム削除アイコンは引き続き表示する', (tester) async {
        await _pumpSheet(tester, categoryAxes: const []);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('カテゴリ軸が無いときはカテゴリ選択の TextButton を表示しない', (tester) async {
        await _pumpSheet(tester, categoryAxes: const []);
        expect(find.byType(TextButton), findsNothing);
      });

      testWidgets('カテゴリ軸があるときはカテゴリ選択の TextButton を表示する', (tester) async {
        await _pumpSheet(tester, categoryAxes: const [_testAxis]);
        expect(find.byType(TextButton), findsOneWidget);
      });
    },
  );
}
