import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testUserID = 'test-user-001';

// CustomerInfo.isPremium は entitlements.active に premiumEntitlementIdentifier が
// 含まれるかで判定される（purchase.dart の CustomerInfoExtension）。
// テストでは entitlements のみ Fake して premium 状態を制御する。
class _FakeCustomerInfo implements CustomerInfo {
  _FakeCustomerInfo({required this.premium});
  final bool premium;

  @override
  EntitlementInfos get entitlements => _FakeEntitlementInfos(premium: premium);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeEntitlementInfos implements EntitlementInfos {
  _FakeEntitlementInfos({required this.premium});
  final bool premium;

  @override
  Map<String, EntitlementInfo> get active =>
      premium ? {premiumEntitlementIdentifier: _FakeEntitlementInfo()} : {};

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeEntitlementInfo implements EntitlementInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

// 写真未設定（imageURL = null）のアイテム。この状態で「写真を追加」ボタンが出る。
GroupShoppingListItem _testItem() => const GroupShoppingListItem(
      id: 'item-001',
      groupID: _testGroupID,
      shoppingListID: 'list-001',
      userID: _testUserID,
      message: 'コーラ',
      order: 0,
      description: null,
      color: null,
      imageURL: null,
      checkedByUserID: null,
      lastEditedByUserID: null,
    );

Future<void> _pumpSheet(WidgetTester tester, {required bool premium}) async {
  final container = ProviderContainer(
    overrides: [
      currentUserIDProvider.overrideWithValue(_testUserID),
      // カテゴリ軸を空にしてカテゴリセクションを省略し、写真セクションのみ検証する。
      groupCategoryAxesProvider(groupID: _testGroupID)
          .overrideWith((ref) => Stream.value(const <GroupCategoryAxis>[])),
      customerInfoProvider.overrideWith(
          (ref) => Stream.value(_FakeCustomerInfo(premium: premium))),
    ],
  );
  addTearDown(container.dispose);
  appProviderContainer = container;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Stack(
            children: [
              TextShoppingListItemDetailBottomSheet(
                groupID: _testGroupID,
                textShoppingListItem: _testItem(),
              ),
              const ToastOverlay(),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('TextShoppingListItemDetailBottomSheet 写真プレミアム表示', () {
    testWidgets('非プレミアムユーザーの「写真を追加」には王冠マークが表示される', (WidgetTester tester) async {
      await _pumpSheet(tester, premium: false);

      expect(find.text('写真を追加'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('非プレミアムユーザーが「写真を追加」を押すと前面トーストが表示される',
        (WidgetTester tester) async {
      await _pumpSheet(tester, premium: false);

      await tester.tap(find.text('写真を追加'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.text('商品写真の添付はプレミアム機能です'), findsOneWidget);
      expect(find.text('アップグレード'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('商品写真の添付はプレミアム機能です'), findsNothing);
      expect(find.text('アップグレード'), findsNothing);
    });

    testWidgets('プレミアムユーザーの「写真を追加」には王冠マークが表示されない', (WidgetTester tester) async {
      await _pumpSheet(tester, premium: true);

      expect(find.text('写真を追加'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
    });
  });
}
