import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shoppinglist/utils/config/admob.dart';

/// 買い物リスト一覧の上部に固定表示する AdMob Native 広告(Issue #77)。
/// Google 公式の Native Templates(small) で描画し、読み込み完了までは高さ 0 で場所を取らない。
/// プレミアムユーザーへの非表示切り替え(Issue #150)は呼び出し側(page.dart)が行う。
///
/// NativeAd のロード・破棄というプラットフォームリソースのライフサイクル管理が必要なため
/// StatefulWidget にしている(Pilll の AdMobNativeAdvance と同じ構成)。
class AdMobNativeAdBanner extends StatefulWidget {
  const AdMobNativeAdBanner({super.key});

  @override
  State<AdMobNativeAdBanner> createState() => _AdMobNativeAdBannerState();
}

class _AdMobNativeAdBannerState extends State<AdMobNativeAdBanner> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  // Native Templates(small) の推奨アスペクト比。高さの最小要件 32px・推奨 90px 以上を
  // 画面幅から満たすための比率で、Pilll の実測値をそのまま採用している。
  // https://developers.google.com/admob/flutter/native/templates
  static const double _adAspectRatioSmall = 91 / 355;

  @override
  void initState() {
    super.initState();
    // ATT ダイアログは初回フレーム描画前(アプリが active になる前)に要求すると
    // 表示されずに denied 相当で返ることがあるため、初回フレーム後に実行する
    // (Pilll の AdMob widget と同じ扱い)。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nativeAd = _nativeAd;
    if (!_nativeAdIsLoaded || nativeAd == null) {
      return const SizedBox.shrink();
    }
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width,
      height: width * _adAspectRatioSmall,
      child: AdWidget(ad: nativeAd),
    );
  }

  /// Native 広告をロードする。失敗時は高さ 0 のまま何も表示しない。
  ///
  /// iOS はロード前に App Tracking Transparency の許可を求める(Pilll と同じく
  /// 広告を表示する非プレミアムユーザーだけに出す)。ダイアログは初回のみ表示され、
  /// 以降は決定済みステータスが即座に返る。拒否されても広告は配信される
  /// (パーソナライズされないだけ)ため、結果に関わらずロードへ進む。
  Future<void> _loadAd() async {
    if (Platform.isIOS) {
      try {
        await AppTrackingTransparency.requestTrackingAuthorization();
      } catch (e) {
        // widget test 環境では platform channel が存在せず失敗するが、
        // ATT はロード継続に必須ではないため握りつぶす。
        debugPrint('requestTrackingAuthorization error: $e');
      }
    }
    final nativeAd = NativeAd(
      adUnitId: admobNativeAdvanceAdUnitID,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('$NativeAd failedToLoad: $error');
          ad.dispose();
          _nativeAd = null;
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
    );
    _nativeAd = nativeAd;
    try {
      await nativeAd.load();
    } catch (e) {
      // widget test 環境では platform channel が存在せず MissingPluginException になる。
      // 実行環境の広告失敗も含め、ロードできない場合は非表示のままにする。
      debugPrint('$NativeAd load error: $e');
      nativeAd.dispose();
      _nativeAd = null;
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
