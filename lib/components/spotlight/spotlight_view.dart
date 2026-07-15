import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// スポットライト(コーチマーク)で対象を切り抜く形状。
///
/// Swift 製ライブラリ Gecco(bannzai/Gecco)の `Spotlight.Shape`(Oval / RoundedRect)相当。
/// アプリ非依存の presentation 定義として、将来のパッケージ切り出し(TsukiAkari 構想)を意識し
/// 機能ロジックを持たない。切り抜きに使う形は [SpotlightOval] と [SpotlightRoundedRect] の2種。
sealed class SpotlightShape {
  const SpotlightShape();
}

/// 対象を正円/楕円で切り抜く形状。対象 Rect に内接する楕円になる。
class SpotlightOval extends SpotlightShape {
  const SpotlightOval();
}

/// 対象を角丸矩形で切り抜く形状。
class SpotlightRoundedRect extends SpotlightShape {
  /// 角の半径。
  final double cornerRadius;

  const SpotlightRoundedRect({required this.cornerRadius});
}

/// 画面全体をディム(黒半透明)で覆い、対象部分だけを [shape] で切り抜いて見せる
/// スポットライト表示。切り抜きの周囲に説明 [content] を配置する。
///
/// - 全画面ディムは [CustomPaint] + `Path.combine(PathOperation.difference)` で、全画面矩形から
///   切り抜き形状を引いたパスとして描く。
/// - フェードインしながら表示する。
/// - 画面のどこをタップしても [onDismiss] を呼ぶ(切り抜き部分のタップも含む。表示中は操作を止め、
///   まず説明を読ませてから閉じる想定)。
/// - [content] は対象 Rect の上下で空きが大きい側に配置する。
///
/// 座標系は [targetRect] を含めすべて global(画面)座標で扱う。Overlay の最前面に全画面で
/// 挿入して使うことを想定している。
class SpotlightView extends HookWidget {
  /// 切り抜く対象の global Rect(padding 適用前)。
  final Rect targetRect;

  /// 切り抜きに付ける余白。対象ぴったりだと窮屈なので少し広げて切り抜く。
  final EdgeInsets targetPadding;

  /// 切り抜き形状。
  final SpotlightShape shape;

  /// 対象の近くに表示する説明コンテンツ(バブル等)。
  final Widget content;

  /// 画面タップで閉じる時のコールバック。
  final VoidCallback onDismiss;

  /// ディムの色(既定は黒 60%)。
  final Color dimColor;

  const SpotlightView({
    super.key,
    required this.targetRect,
    required this.targetPadding,
    required this.shape,
    required this.content,
    required this.onDismiss,
    this.dimColor = const Color(0x99000000),
  });

  @override
  Widget build(BuildContext context) {
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 220),
    );
    // 目的: マウント直後にフェードインさせる。
    // 依存配列: const [] 。1度だけ forward すれば良く、以降の rebuild で再生し直さない。
    useEffect(() {
      fadeController.forward();
      return null;
    }, const []);

    final screenSize = MediaQuery.sizeOf(context);
    final cutoutRect = targetPadding.inflateRect(targetRect);
    // 対象の上下で空きが大きい側にバブルを寄せる。
    final placeBelow =
        (screenSize.height - cutoutRect.bottom) >= cutoutRect.top;

    // 画面のどこをタップしても閉じる。バブル・切り抜き部分のタップも、これらは onTap を持たないため
    // 最上位のこの GestureDetector が gesture arena を取り、onDismiss が呼ばれる。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: FadeTransition(
        opacity: fadeController,
        child: Stack(
          children: [
            // 全画面ディム + 対象の切り抜き。
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  cutoutRect: cutoutRect,
                  shape: shape,
                  dimColor: dimColor,
                ),
              ),
            ),
            // 説明バブル。対象の上/下に配置する。左右 16 の余白内で対象側(右)へ寄せる。
            Positioned(
              left: 16,
              right: 16,
              top: placeBelow ? cutoutRect.bottom + 12 : null,
              bottom:
                  placeBelow ? null : (screenSize.height - cutoutRect.top) + 12,
              child: Align(
                alignment:
                    placeBelow ? Alignment.topRight : Alignment.bottomRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 全画面矩形から [cutoutRect] を [shape] で引いたパスを [dimColor] で塗る painter。
class _SpotlightPainter extends CustomPainter {
  final Rect cutoutRect;
  final SpotlightShape shape;
  final Color dimColor;

  _SpotlightPainter({
    required this.cutoutRect,
    required this.shape,
    required this.dimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);
    final cutoutPath = switch (shape) {
      SpotlightOval() => Path()..addOval(cutoutRect),
      SpotlightRoundedRect(:final cornerRadius) =>
        Path()..addRRect(
          RRect.fromRectAndRadius(cutoutRect, Radius.circular(cornerRadius)),
        ),
    };
    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, cutoutPath),
      Paint()..color = dimColor,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.cutoutRect != cutoutRect ||
      oldDelegate.shape != shape ||
      oldDelegate.dimColor != dimColor;
}
