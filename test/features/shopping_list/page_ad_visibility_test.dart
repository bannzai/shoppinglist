import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/admob_native_ad_banner.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 一覧に固定表示する Native 広告(Issue #77)のプレミアム判定による表示切り替え(Issue #150)と、
/// キーボード表示中の非表示(RetentionBanner と同じ扱い)を検証する。
/// 広告のロード自体は platform channel が無いテスト環境では失敗し高さ 0 になるが、
/// 表示可否は AdMobNativeAdBanner のマウント有無(find.byType)で検証できる。

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

Future<void> _pumpPage(
  WidgetTester tester, {
  // null は customerInfo 未解決(ロード中)を表す。previewProviderOverrides の
  // Stream.empty をそのまま使い、上書きしない。
  required bool? premium,
  bool isKeyboardVisible = false,
}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...previewProviderOverrides(sharedPreferences: sharedPreferences),
        // previewProviderOverrides の Stream.empty(未解決のまま)を premium 指定で
        // 上書きする(overrides は後勝ち)。null の場合は未解決状態を再現するため
        // 上書きしない。
        if (premium != null)
          customerInfoProvider.overrideWith(
            (ref) => Stream.value(_FakeCustomerInfo(premium: premium)),
          ),
      ],
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
  testWidgets('非プレミアム時は Native 広告(AdMobNativeAdBanner)を表示する', (tester) async {
    await _pumpPage(tester, premium: false);

    expect(find.byType(AdMobNativeAdBanner), findsOneWidget);
  });

  testWidgets('プレミアム時は Native 広告(AdMobNativeAdBanner)を表示しない', (tester) async {
    await _pumpPage(tester, premium: true);

    expect(
      find.byType(AdMobNativeAdBanner),
      findsNothing,
      reason: 'プレミアム機能: 広告削除(Issue #150)',
    );
  });

  testWidgets('キーボード表示中は Native 広告(AdMobNativeAdBanner)を隠す', (tester) async {
    await _pumpPage(tester, premium: false, isKeyboardVisible: true);

    expect(
      find.byType(AdMobNativeAdBanner),
      findsNothing,
      reason: 'キーボード表示中は入力領域を優先する(RetentionBanner と同じ扱い)',
    );
  });

  testWidgets('customerInfo 未解決の間は Native 広告(AdMobNativeAdBanner)を表示しない', (
    tester,
  ) async {
    await _pumpPage(tester, premium: null);

    expect(
      find.byType(AdMobNativeAdBanner),
      findsNothing,
      reason: 'プレミアムユーザーの起動直後に広告ロードと ATT ダイアログが一瞬走るのを防ぐ',
    );
  });
}
