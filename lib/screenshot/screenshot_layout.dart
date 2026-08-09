/// スクリーンショット 1 枚分のレイアウト。
///
/// 「背景 + キャッチコピー + デバイスフレーム + アプリ画面」を 1 つの Widget として組み立て、
/// これをシミュレータ上で全画面表示して撮影したものがそのままストアの提出画像になる
/// (合成の後処理を挟まない)。
library;

import 'package:flutter/material.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';

/// デバイスフレームの中に描くアプリ画面の論理幅。
///
/// iPhone 16 Pro の論理解像度。撮影機 (16 Pro Max) より一回り小さい端末の画面を
/// フレーム内に収める形にすることで、縮小率を抑えつつ余白を確保できる。
const _mockScreenWidth = 393.0;

/// デバイスフレームの中に描くアプリ画面の論理高さ。
const _mockScreenHeight = 852.0;

/// `MediaQuery` に与えるアプリ画面のサイズ。
const _mockScreenSize = Size(_mockScreenWidth, _mockScreenHeight);

/// アプリ画面をデバイスフレームに収めるための縮小率。
///
/// 幅 393 の画面をフレーム内幅 (約 306) に収める比率。値を上げるとフレームが
/// 画面幅を超え、下げるとコピーとの間の余白が間延びする。
const _mockScreenScale = 0.78;

/// フレーム内に見せるアプリ画面の上下セーフエリア。
///
/// Dynamic Island 世代の実機の値。これを与えないと AppBar が上端に貼り付き、
/// 実際の見え方とずれる。
const _mockScreenPadding = EdgeInsets.only(top: 59, bottom: 34);

/// ベゼルの厚み。実機と同じく上下左右で均一にする。
const _deviceBezelWidth = 9.0;

/// デバイスフレーム全体の高さ。アプリ画面の縮小後の高さにベゼルの厚みを足したもの。
const _deviceFrameHeight =
    _mockScreenHeight * _mockScreenScale + _deviceBezelWidth * 2;

/// 背景グラデーションの上端。アプリの `paper` より一段明るく、端末が浮いて見えるようにする。
const _backgroundTop = Color(0xFFFCFAF6);

/// 背景グラデーションの下端。アプリの `paper` と同色にし、端末下部と地続きに見せる。
const _backgroundBottom = Color(0xFFF1EDE4);

/// 端末のベゼルと見出しの色。実機のベゼル色ではなく、アプリの `ink` に寄せて画面全体の色数を抑える。
///
/// `AppNeutralColors.light` の値と揃えているが、`const` 式では同クラスのフィールドを
/// 参照できないため、スクリーンショット側で定数として持つ。
const _ink = Color(0xFF1B1813);

/// 補足テキストの色。`AppNeutralColors.light.ink2` と同値。
const _ink2 = Color(0xFF57514A);

/// 背景・キャッチコピー・デバイスフレームを合成した、提出用の 1 画面。
class ScreenshotLayout extends StatelessWidget {
  /// 画面上部に焼き込むキャッチコピー。
  final ScreenshotCopy copy;

  /// デバイスフレームの中に表示するアプリ画面。
  final Widget appScreen;

  const ScreenshotLayout({
    super.key,
    required this.copy,
    required this.appScreen,
  });

  @override
  Widget build(BuildContext context) {
    // Material を挟まないと、キャッチコピーが debug ビルドの未装飾テキスト
    // (黄色い二重下線) として描画され、そのまま撮影されてしまう。
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundTop, _backgroundBottom],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 72),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    copy.headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    copy.subheadline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: _ink2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // フレーム下端は画面外へ抜ける。アプリ画面の最下部 (FAB や操作ボタン) は
            // 見切れる前提で、上寄せのコンテンツだけを見せる。
            Expanded(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                // 親 (Expanded) の残り高さはフレームより小さい。min を 0 に落として
                // フレームが自然な高さのまま下へはみ出せるようにする。
                minHeight: 0,
                maxHeight: _deviceFrameHeight,
                child: _DeviceFrame(child: appScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// コード描画のデバイスフレーム。外部の枠画像に依存しない。
class _DeviceFrame extends StatelessWidget {
  /// フレーム内に描くアプリ画面。
  final Widget child;

  const _DeviceFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(52),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_deviceBezelWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
          child: SizedBox(
            width: _mockScreenWidth * _mockScreenScale,
            height: _mockScreenHeight * _mockScreenScale,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: _mockScreenWidth,
                height: _mockScreenHeight,
                child: MediaQuery(
                  data: const MediaQueryData(
                    size: _mockScreenSize,
                    devicePixelRatio: 3,
                    padding: _mockScreenPadding,
                    viewPadding: _mockScreenPadding,
                  ),
                  // フレームの内側に Navigator を置く。これが無いと、アプリ画面が開く
                  // モーダルシートやダイアログがルート Navigator のオーバーレイへ出て、
                  // 端末フレームの外側 (スクリーンショット全面) を覆ってしまう。
                  child: Navigator(
                    onGenerateRoute:
                        (settings) =>
                            MaterialPageRoute(builder: (context) => child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
