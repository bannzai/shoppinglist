import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testUserID = 'test-user-001';
const _testShoppingListID = 'list-001';

GroupShoppingListItem _testItem({String? description, String? color}) =>
    GroupShoppingListItem(
      id: 'item-001',
      groupID: _testGroupID,
      shoppingListID: _testShoppingListID,
      userID: _testUserID,
      message: 'コーラ',
      order: 0,
      description: description,
      color: color,
      imageURL: null,
      checkedByUserID: null,
      lastEditedByUserID: null,
    );

/// 自動保存(disappear)で呼ばれた更新引数を記録するスパイ。
class _SpyUpdate extends UpdateShoppingListItem {
  _SpyUpdate() : super(database: GroupDatabase(groupID: _testGroupID));

  int callCount = 0;
  GroupShoppingListItem? lastItem;

  @override
  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String editedByUserID,
  }) async {
    callCount += 1;
    lastItem = item;
  }
}

List<Override> _overrides(_SpyUpdate spy) => [
      currentUserIDProvider.overrideWithValue(_testUserID),
      // 軸を空にしてカテゴリセクションを省略する（説明・カラーのみ検証）。
      groupCategoryAxesProvider(groupID: _testGroupID)
          .overrideWith((ref) => Stream.value(const <GroupCategoryAxis>[])),
      customerInfoProvider
          .overrideWith((ref) => const Stream<CustomerInfo>.empty()),
      updateShoppingListItemProvider(groupID: _testGroupID)
          .overrideWith((ref) => spy),
    ];

/// シートをルートとして pump する。tree を差し替えると dispose され、
/// useOnDisappear による自動保存が発火する。
Future<void> _pumpSheet(
  WidgetTester tester, {
  required _SpyUpdate spy,
  required GroupShoppingListItem item,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(spy),
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: TextShoppingListItemDetailBottomSheet(
            groupID: _testGroupID,
            textShoppingListItem: item,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// tree を空に差し替えてシートを dispose させる。
Future<void> _disposeSheet(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
  await tester.pump();
}

void main() {
  group('アイテム詳細 離脱時の自動保存', () {
    testWidgets('説明を変更してシートを閉じると自動保存される', (tester) async {
      final spy = _SpyUpdate();
      await _pumpSheet(tester, spy: spy, item: _testItem(description: null));

      await tester.enterText(find.byType(TextField), 'キッコーマンの丸大豆');
      await _disposeSheet(tester);

      expect(spy.callCount, 1);
      expect(spy.lastItem?.description, 'キッコーマンの丸大豆');
    });

    testWidgets('変更せずシートを閉じると保存されない', (tester) async {
      final spy = _SpyUpdate();
      await _pumpSheet(
        tester,
        spy: spy,
        item: _testItem(description: '既存メモ'),
      );

      await _disposeSheet(tester);

      expect(spy.callCount, 0);
    });
  });
}
