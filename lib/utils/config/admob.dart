import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID(Issue #77)。
/// クライアント埋め込み前提の公開情報のためコードに直書きする(Google Maps キーと同じ方針)。
/// debug / profile ビルドでは、開発中の表示・タップが AdMob の無効トラフィック判定
/// (アカウント制限)につながるのを防ぐため、Google 公式のテスト用ユニット ID を使う。
/// https://developers.google.com/admob/ios/test-ads
/// https://developers.google.com/admob/android/test-ads

/// Native Advanced 広告のユニット ID。
String get admobNativeAdvanceAdUnitID {
  if (kReleaseMode) {
    return Platform.isAndroid
        ? 'ca-app-pub-9127772965271297/1862729709'
        : 'ca-app-pub-9127772965271297/9894392261';
  }
  return Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';
}

/// バナー広告のユニット ID。AdMob 側で発行済みだが、バナー広告は未実装のため現状参照元はない。
String get admobBannerAdUnitID {
  if (kReleaseMode) {
    return Platform.isAndroid
        ? 'ca-app-pub-9127772965271297/8581310590'
        : 'ca-app-pub-9127772965271297/6080373989';
  }
  return Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741'
      : 'ca-app-pub-3940256099942544/2435281174';
}
