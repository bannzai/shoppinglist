import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list/components/banners/admob_native_ad_banner.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 一覧に固定表示する Native 広告(Issue #77)のプレミアム判定による表示切り替え(Issue #150)と、
/// キーボード表示中の非表示(State は保持)を検証する。
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

/// UMP(User Messaging Platform) の method channel をモックする。
/// google_mobile_ads プラグイン内部の requestConsentInfoUpdate は
/// PlatformException しか捕捉しないため、モック無しだと未登録チャンネルの
/// MissingPluginException が未処理エラーとしてテストを落とす。
/// 「同意取得済み・広告リクエスト可能」として応答し、後段の広告ロード呼び出しは
/// モックしない(MissingPluginException を widget 側の try/catch が握りつぶし、
/// 高さ 0 のまま = マウント有無の検証に影響しない)。
///
/// このチャンネルは非公開のカスタムコーデック(UserMessagingCodec)を使うため
/// MethodChannel ベースのモックでは引数(ConsentRequestParameters)をデコードできない。
/// raw メッセージから標準コーデックで読めるメソッド名(先頭の String)だけを取り出して
/// 応答を組み立てる。応答値は null / bool のみで、これは標準コーデックと互換。
void _mockUMPChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('plugins.flutter.io/google_mobile_ads/ump', (
        message,
      ) async {
        switch (const StandardMessageCodec().readValue(ReadBuffer(message!))
            as String) {
          case 'ConsentInformation#canRequestAds':
            return const StandardMethodCodec().encodeSuccessEnvelope(true);
          default:
            // requestConsentInfoUpdate / loadAndShowConsentFormIfRequired は
            // 成功(null = FormError なし)として応答する。
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
        }
      });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  // null は customerInfo 未解決(ロード中)を表す。previewProviderOverrides の
  // Stream.empty をそのまま使い、上書きしない。
  required bool? premium,
  // RevenueCat の現在の App User ID。既定は previewProviderOverrides と同じく
  // 現在ユーザー(mockUserID)でログイン済み相当。
  String revenueCatAppUserID = mockUserID,
  bool isKeyboardVisible = false,
}) async {
  _mockUMPChannel();
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
        revenueCatAppUserIDProvider.overrideWith(
          (ref) => Future.value(revenueCatAppUserID),
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

  testWidgets('キーボード表示中は Native 広告を隠すが State は保持する', (tester) async {
    await _pumpPage(tester, premium: false, isKeyboardVisible: true);

    // 既定の finder は offstage をスキップするため「表示されていない」ことを検証できる。
    expect(
      find.byType(AdMobNativeAdBanner),
      findsNothing,
      reason: 'キーボード表示中は入力領域を優先する(RetentionBanner と同じ扱い)',
    );
    // Visibility(maintainState) によりツリーには残り、ロード済み広告の State が
    // 破棄されない(キーボード開閉のたびに広告を再リクエストしない)。
    expect(
      find.byType(AdMobNativeAdBanner, skipOffstage: false),
      findsOneWidget,
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

  testWidgets('RevenueCat が現在ユーザーでログイン済みになるまで広告を表示しない', (tester) async {
    // AuthResolver の Purchases.logIn は unawaited のため、新規端末で既存プレミアム
    // アカウントにサインインした直後は匿名ユーザーの非プレミアム CustomerInfo が
    // 先に届き得る。現在の App User ID が Firebase uid と一致するまでは
    // 広告・ATT を出さない(page.dart の shouldShowAd)。
    await _pumpPage(
      tester,
      premium: false,
      revenueCatAppUserID: r'$RCAnonymousID:0123456789abcdef',
    );

    expect(find.byType(AdMobNativeAdBanner, skipOffstage: false), findsNothing);
  });
}
