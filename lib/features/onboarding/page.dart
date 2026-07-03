import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// アプリ初回起動時のスライド式オンボーディング。
/// `design_handoff_shoppinglist/preview/screens-onboarding.jsx` 相当。
///
/// 完走 / スキップで hasSeenOnboarding を true に保存し、二度と表示されないようにする。
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  // 位置情報リマインダー非表示中 (issue #465) はスライド 3 (店舗近接通知の訴求) も
  // 除外するため、枚数は flag に連動する。
  static const _slideCount = shoppingLocationFeatureEnabled ? 3 : 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final controller = usePageController();
    final index = useState(0);

    final slides = <_SlideContent>[
      _SlideContent(
        eyebrowIndex: 1,
        title: '家族と作る、\n買い物リスト',
        body:
            '家で思いついたものを誰かが追加して、店頭で別の誰かがチェック。'
            '「買ってきて」のやり取りを、ぜんぶこの一枚に。',
        assetPath: 'images/onboarding/slide_1.png',
        fallbackBuilder: (tokens) => _TiltedListArt(tokens: tokens),
      ),
      _SlideContent(
        eyebrowIndex: 2,
        title: '同じリストを\n同時に編集',
        body:
            '家族・パートナー・同居人を招待コードで招くと、同じリストを編集できます。'
            '誰が追加したかではなく、何を買い忘れずに済むかを大切に。',
        assetPath: 'images/onboarding/slide_2.png',
        fallbackBuilder: (tokens) => _AvatarOrbitArt(tokens: tokens),
      ),
      // 位置情報リマインダーはファーストリリースでは非表示のため訴求スライドも出さない (issue #465)。
      if (shoppingLocationFeatureEnabled)
        _SlideContent(
          eyebrowIndex: 3,
          title: 'お店の近くで、\nそっと思い出す',
          body:
              '登録した店舗の近くに来ると、買い物リストをやさしくお知らせ。'
              '通知は必要な時だけ、押し付けがましくなく。',
          assetPath: 'images/onboarding/slide_3.png',
          fallbackBuilder: (tokens) => _MapHaloArt(tokens: tokens),
        ),
    ];

    Future<void> finish({required String reason}) async {
      analytics.logEvent(
        name: 'finish_onboarding',
        parameters: {'reason': reason, 'lastIndex': index.value.toString()},
      );
      await ref
          .read(
            boolSharedPreferencesProvider(
              key: BoolKey.hasSeenOnboarding,
            ).notifier,
          )
          .set(value: true);
    }

    return Scaffold(
      backgroundColor: tokens.neutral.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                child: TextButton(
                  onPressed: () => finish(reason: 'skip'),
                  child: Text(
                    'スキップ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.neutral.ink3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (i) {
                  index.value = i;
                  analytics.logEvent(
                    name: 'view_onboarding_slide',
                    parameters: {'slideIndex': i.toString()},
                  );
                },
                itemBuilder: (context, i) => _OnboardingSlide(data: slides[i]),
              ),
            ),
            _DotsIndicator(count: _slideCount, currentIndex: index.value),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                child: AppPill(
                  label: index.value == slides.length - 1 ? 'はじめる' : '次へ',
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed: () {
                    if (index.value == slides.length - 1) {
                      finish(reason: 'complete');
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  icon: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 スライドのデータ。`assetPath` の画像を表示し、ロード失敗時は
/// `fallbackBuilder` の Flutter 描画 Widget を使う。
class _SlideContent {
  final int eyebrowIndex;
  final String title;
  final String body;
  final String assetPath;
  final Widget Function(AppThemeExtension tokens) fallbackBuilder;
  const _SlideContent({
    required this.eyebrowIndex,
    required this.title,
    required this.body,
    required this.assetPath,
    required this.fallbackBuilder,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _SlideContent data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 220,
            height: 220,
            child: Image.asset(
              data.assetPath,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => data.fallbackBuilder(tokens),
            ),
          ),
          const Spacer(),
          // mono eyebrow: `01/03` 形式
          Text(
            '${data.eyebrowIndex.toString().padLeft(2, '0')}/${OnboardingPage._slideCount.toString().padLeft(2, '0')}',
            style: monoTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.accent,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.02,
              color: neutral.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: neutral.ink2, height: 1.7),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// スライド 1: 傾いた買い物リスト風カード（accent ボーダー + 行）。
class _TiltedListArt extends StatelessWidget {
  final AppThemeExtension tokens;
  const _TiltedListArt({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 背景の角丸 surface2
        Container(
          decoration: BoxDecoration(
            color: tokens.neutral.surface2,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        Transform.rotate(
          angle: -0.06,
          child: Container(
            width: 160,
            height: 180,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.neutral.card,
              borderRadius: BorderRadius.circular(14),
              border: Border(left: BorderSide(color: tokens.accent, width: 3)),
              boxShadow: tokens.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (checked, w) in const [
                  (true, 0.85),
                  (true, 0.65),
                  (false, 0.75),
                  (false, 0.55),
                  (false, 0.7),
                ]) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: checked ? tokens.accent : Colors.transparent,
                            border: Border.all(
                              color:
                                  checked ? tokens.accent : tokens.neutral.ink4,
                              width: 1.4,
                            ),
                          ),
                          child:
                              checked
                                  ? const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color:
                                  checked
                                      ? tokens.neutral.divider2
                                      : tokens.neutral.ink4.withValues(
                                        alpha: 0.35,
                                      ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            margin: EdgeInsets.only(right: 160 * (1 - w)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// スライド 2: dashed orbit 上に 3 つのアバター。
class _AvatarOrbitArt extends StatelessWidget {
  final AppThemeExtension tokens;
  const _AvatarOrbitArt({required this.tokens});

  @override
  Widget build(BuildContext context) {
    const radius = 80.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: tokens.neutral.surface2,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _DashedCirclePainter(
              color: tokens.accent.withValues(alpha: 0.5),
              radius: radius,
            ),
          ),
        ),
        // 中央タグ
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.accent,
            boxShadow: tokens.cardShadow,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.shopping_bag, color: Colors.white, size: 26),
        ),
        // 3 つのアバター（30°, 150°, 270°）
        for (final (deg, label, color) in [
          (270.0, 'A', tokens.accent),
          (30.0, 'B', tokens.neutral.ok),
          (150.0, 'C', tokens.neutral.warn),
        ])
          Transform.translate(
            offset: Offset(
              radius * math.cos(deg * math.pi / 180),
              radius * math.sin(deg * math.pi / 180),
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: tokens.neutral.card, width: 2),
                boxShadow: tokens.cardShadow,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: monoTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// スライド 3: SVG ライクな地図 + 中央 pin の halo パルス。
class _MapHaloArt extends StatefulWidget {
  final AppThemeExtension tokens;
  const _MapHaloArt({required this.tokens});

  @override
  State<_MapHaloArt> createState() => _MapHaloArtState();
}

class _MapHaloArtState extends State<_MapHaloArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: tokens.neutral.surface2,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        // 街区を模した抽象シェイプ
        Positioned(
          left: 24,
          top: 30,
          child: _block(40, 28, tokens.neutral.divider2),
        ),
        Positioned(
          right: 30,
          top: 50,
          child: _block(50, 36, tokens.neutral.divider2),
        ),
        Positioned(
          left: 40,
          bottom: 60,
          child: _block(60, 30, tokens.neutral.divider2),
        ),
        Positioned(
          right: 24,
          bottom: 40,
          child: _block(36, 30, tokens.neutral.divider2),
        ),
        // 中央 halo（パルス）
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final scale = 1.0 + _ctrl.value * 1.6;
            final opacity = (1.0 - _ctrl.value).clamp(0.0, 1.0);
            return Container(
              width: 28 * scale,
              height: 28 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.accent.withValues(alpha: 0.25 * opacity),
              ),
            );
          },
        ),
        // pin
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.accent,
            boxShadow: tokens.cardShadow,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.location_on, color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _block(double w, double h, Color color) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

/// dashed 円を描く CustomPainter。
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedCirclePainter({required this.color, required this.radius});

  static const _dashAngle = 0.18; // radian
  static const _gapAngle = 0.10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    var theta = 0.0;
    while (theta < math.pi * 2) {
      final end = theta + _dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        theta,
        _dashAngle,
        false,
        paint,
      );
      theta = end + _gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color || old.radius != radius;
}

/// 3 ドットページネーション。アクティブのみ横長。
class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _DotsIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == currentIndex ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == currentIndex ? tokens.accent : tokens.neutral.divider,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (i < count - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
