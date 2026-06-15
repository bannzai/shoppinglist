import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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

Future<void> _pumpSection(
  WidgetTester tester, {
  required bool premium,
  required List<GroupShoppingListReceipt> receipts,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerInfoProvider.overrideWith(
            (ref) => Stream.value(_FakeCustomerInfo(premium: premium))),
        receiptsProvider(groupID: _testGroupID, shoppingListID: _testListID)
            .overrideWith((ref) => Stream.value(receipts)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const Scaffold(
          body: ReceiptSection(
            groupID: _testGroupID,
            shoppingListID: _testListID,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ReceiptSection プレミアム表示', () {
    testWidgets('非プレミアムユーザーには王冠マークと追加ボタンが表示される', (WidgetTester tester) async {
      await _pumpSection(tester, premium: false, receipts: const []);

      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('プレミアムユーザーには王冠マークが表示されない', (WidgetTester tester) async {
      await _pumpSection(tester, premium: true, receipts: const []);

      expect(find.byIcon(Icons.workspace_premium), findsNothing);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });
  });
}
