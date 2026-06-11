import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testUserID = 'test-user-001';

// CustomerInfo.isPremium は entitlements.active に premiumEntitlementIdentifier が
// 含まれるかで判定される（purchase.dart の CustomerInfoExtension）。
// 写真セクションの分岐にだけ使うため非プレミアム固定の Fake を渡す。
class _FakeCustomerInfo implements CustomerInfo {
  @override
  EntitlementInfos get entitlements => _FakeEntitlementInfos();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeEntitlementInfos implements EntitlementInfos {
  @override
  Map<String, EntitlementInfo> get active => {};

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// description 以外は固定の検証用アイテム。
GroupShoppingListItem _testItem({required String? description}) =>
    GroupShoppingListItem(
      id: 'item-001',
      groupID: _testGroupID,
      shoppingListID: 'list-001',
      userID: _testUserID,
      message: 'コーラ',
      order: 0,
      description: description,
      color: null,
      imageURL: null,
      checkedByUserID: null,
      lastEditedByUserID: null,
    );

Future<void> _pumpSheet(
  WidgetTester tester, {
  required String? description,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIDProvider.overrideWithValue(_testUserID),
        // カテゴリ軸を空にしてカテゴリセクションを省略し、説明セクションのみ検証する。
        groupCategoryAxesProvider(groupID: _testGroupID)
            .overrideWith((ref) => Stream.value(const <GroupCategoryAxis>[])),
        customerInfoProvider
            .overrideWith((ref) => Stream.value(_FakeCustomerInfo())),
      ],
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          // maxLength のカウンタ分を含めても収まるようスクロール可能にして検証する。
          body: SingleChildScrollView(
            child: TextShoppingListItemDetailBottomSheet(
              groupID: _testGroupID,
              textShoppingListItem: _testItem(description: description),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('TextShoppingListItemDetailBottomSheet の説明 (description) 入力', () {
    testWidgets('説明の TextField は 80 文字制限 (maxLength) を持つ', (tester) async {
      await _pumpSheet(tester, description: null);
      expect(tester.widget<TextField>(find.byType(TextField)).maxLength, 80);
    });

    testWidgets('80 文字を超える入力は 80 文字で打ち切られる', (tester) async {
      await _pumpSheet(tester, description: null);
      await tester.enterText(find.byType(TextField), 'あ' * 100);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'あ' * 80,
      );
    });

    testWidgets('80 文字を超える既存の description は切り詰めずに表示する', (tester) async {
      await _pumpSheet(tester, description: 'あ' * 100);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'あ' * 100,
      );
    });
  });
}
