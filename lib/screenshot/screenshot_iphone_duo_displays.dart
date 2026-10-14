/// App Store へ提出する iPhone Duo のスクリーンショットの、ディスプレイごとの寸法とレイアウト。
///
/// 撮影 (`integration_test/app_store_screenshots_iphone_duo_test.dart`) と、
/// レイアウトが崩れないことの検証 (`test/screenshot/`) が同じ定義を使う。
library;

import 'package:flutter/widgets.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';
import 'package:shoppinglist/screenshot/screenshot_layout.dart';

/// 提出画像の px を論理サイズから求める倍率。
///
/// Apple の仕様の iPhone Duo の 4 寸法 (1398×2034・2034×1398・2007×2853・2853×2007) は
/// どれも 3 で割り切れ、3 倍で書き出すと論理サイズが整数になるため。
const screenshotIPhoneDuoPixelRatio = 3.0;

/// 撮影する iPhone Duo のディスプレイ。
///
/// `name` は出力ファイル名の先頭に付ける識別子。`size` は提出画像の px を
/// [screenshotIPhoneDuoPixelRatio] で割った論理サイズで、px は Apple の
/// 「Screenshot specifications」の iPhone Duo の節
/// (https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)。
/// 外側は縦 (1398×2034)。内側は縦横の両方を受け付けるが、アプリが内側ディスプレイで
/// 横長に表示されるため横 (2853×2007) で作る。
final screenshotIPhoneDuoDisplays = <
  ({
    String name,
    Size size,
    Widget Function({required ScreenshotCopy copy, required Widget appScreen})
    layout,
  })
>[
  (
    name: 'outer',
    size: const Size(466, 678),
    layout:
        ({required copy, required appScreen}) =>
            ScreenshotLayout(copy: copy, appScreen: appScreen),
  ),
  (
    name: 'inner',
    size: const Size(951, 669),
    layout:
        ({required copy, required appScreen}) =>
            ScreenshotIPhoneDuoInnerLayout(copy: copy, appScreen: appScreen),
  ),
];
