import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/group_shopping_list_receipt.dart';
import 'package:shoppinglist/features/receipt/receipt_section.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testListID = 'list-001';

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

GroupShoppingListReceipt _receipt() => const GroupShoppingListReceipt(
  id: 'receipt-001',
  groupID: _testGroupID,
  shoppingListID: _testListID,
  userID: 'user-001',
  storagePath:
      'groups/$_testGroupID/shoppingLists/$_testListID/receipts/r.jpeg',
  amount: null,
  memo: null,
);

Future<void> _pumpAddButton(
  WidgetTester tester, {
  required bool premium,
  List<GroupShoppingListReceipt> receipts = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerInfoProvider.overrideWith(
          (ref) => Stream.value(_FakeCustomerInfo(premium: premium)),
        ),
        receiptsProvider(
          groupID: _testGroupID,
          shoppingListID: _testListID,
        ).overrideWith((ref) => Stream.value(receipts)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const Scaffold(
          body: ReceiptAddButton(
            groupID: _testGroupID,
            shoppingListID: _testListID,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 表示中の AppPill のラベルを取り出す（find.text に依存せずプロパティで検証する）。
String _pillLabel(WidgetTester tester) =>
    tester.widget<AppPill>(find.byType(AppPill)).label;

void main() {
  group('ReceiptAddButton プレミアム表示', () {
    testWidgets('非プレミアムユーザーには王冠マークと追加ボタンが表示される', (WidgetTester tester) async {
      await _pumpAddButton(tester, premium: false);

      expect(find.byType(AppPill), findsOneWidget);
      // 王冠は AppPill の外ではなくボタン内（子孫）に収める。
      expect(
        find.descendant(
          of: find.byType(AppPill),
          matching: find.byIcon(Icons.workspace_premium),
        ),
        findsOneWidget,
      );
    });

    testWidgets('プレミアムユーザーには追加ボタンのみで王冠マークは表示されない', (WidgetTester tester) async {
      await _pumpAddButton(tester, premium: true);

      expect(find.byType(AppPill), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
    });
  });

  group('ReceiptAddButton ラベルの出し分け', () {
    testWidgets('レシート未登録なら「レシートを追加」', (WidgetTester tester) async {
      await _pumpAddButton(tester, premium: true, receipts: const []);

      expect(_pillLabel(tester), 'レシートを追加');
    });

    testWidgets('プレミアムかつレシート登録済みなら「レシートを編集」', (WidgetTester tester) async {
      await _pumpAddButton(tester, premium: true, receipts: [_receipt()]);

      expect(_pillLabel(tester), 'レシートを編集');
    });

    testWidgets('非プレミアムはレシートがあっても「レシートを追加」のまま', (WidgetTester tester) async {
      await _pumpAddButton(tester, premium: false, receipts: [_receipt()]);

      expect(_pillLabel(tester), 'レシートを追加');
    });
  });
}
