import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import '../helpers/read_provider_future.dart';

const _testGroupID = 'group-1';

/// Firestore へ触れずに shoppingListAddProvider の配線だけを検証するための Fake。
class _FakeGroupDatabase implements GroupDatabase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

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

ProviderContainer _buildContainer({required Stream<CustomerInfo> stream}) {
  final container = ProviderContainer(
    overrides: [
      groupDatabaseProvider(
        groupID: _testGroupID,
      ).overrideWithValue(_FakeGroupDatabase()),
      customerInfoProvider.overrideWith((ref) => stream),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('shoppingListAddProvider のプレミアム判定 (Issue #523)', () {
    test('RC CustomerInfo がプレミアムなら isPremiumResolver は true を返す', () async {
      // Issue #523: 課金済みでも Custom Claims 由来の firestoreIsPremium(常に false)を
      // 参照していたため、リスト作成上限(20個)の課金催促が出続けた。
      // プレミアム判定の SSOT である RC CustomerInfo に配線されていることを検証する。
      final container = _buildContainer(
        stream: Stream.value(_FakeCustomerInfo(premium: true)),
      );
      await readProviderFuture(
        container: container,
        provider: customerInfoProvider.future,
      );

      expect(
        container
            .read(shoppingListAddProvider(groupID: _testGroupID))
            .isPremiumResolver(),
        isTrue,
      );
    });

    test('RC CustomerInfo が非プレミアムなら isPremiumResolver は false を返す', () async {
      final container = _buildContainer(
        stream: Stream.value(_FakeCustomerInfo(premium: false)),
      );
      await readProviderFuture(
        container: container,
        provider: customerInfoProvider.future,
      );

      expect(
        container
            .read(shoppingListAddProvider(groupID: _testGroupID))
            .isPremiumResolver(),
        isFalse,
      );
    });

    test('CustomerInfo 未解決(ロード中)は無料側に倒す', () {
      final container = _buildContainer(stream: const Stream.empty());

      expect(
        container
            .read(shoppingListAddProvider(groupID: _testGroupID))
            .isPremiumResolver(),
        isFalse,
      );
    });

    test('プレミアムはリスト作成上限チェックを行わない', () async {
      // 上限チェック(countOfActiveGroupShoppingLists)が呼ばれると
      // _FakeGroupDatabase が UnimplementedError を投げるため、
      // ShoppingListLimitExceededException 以外で失敗することをもって
      // 「上限チェックをスキップし作成処理へ進んだ」ことを検証する。
      final container = _buildContainer(
        stream: Stream.value(_FakeCustomerInfo(premium: true)),
      );
      await readProviderFuture(
        container: container,
        provider: customerInfoProvider.future,
      );

      await expectLater(
        container
            .read(shoppingListAddProvider(groupID: _testGroupID))
            .call(
              createUserID: 'user-1',
              groupID: _testGroupID,
              shoppingLocationID: null,
              duplicatedFromGroupShoppingListID: null,
            ),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            contains('newGroupShoppingListReference'),
          ),
        ),
      );
    });
  });
}
