import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/provider/onboarding.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// アプリ初回起動時の 3 スライドオンボーディング。
/// `design_handoff_shopping_list/source/screens-onboarding.jsx` 相当。
///
/// 完走 / スキップで `HasSeenOnboarding.markAsSeen()` を呼び、二度と表示されないようにする。
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  static const _slides = <_OnboardingSlideData>[
    _OnboardingSlideData(
      emoji: '🛒',
      eyebrow: '01 — 共有',
      title: '家族と作る、買い物リスト',
      body: 'メンバー全員でリアルタイムに共有・編集できる。',
    ),
    _OnboardingSlideData(
      emoji: '📸',
      eyebrow: '02 — 入力',
      title: '写真や URL から、まとめて追加',
      body: 'レシピ画像やネット記事を放り込むだけ。',
    ),
    _OnboardingSlideData(
      emoji: '🛍️',
      eyebrow: '03 — 並び順',
      title: 'いつもの並び順で、店舗を回る',
      body: 'カテゴリと店舗ごとに最適な順序で表示。',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = usePageController();
    final index = useState(0);

    Future<void> finish({required String reason}) async {
      analytics.logEvent(name: 'finish_onboarding', parameters: {
        'reason': reason,
        'lastIndex': index.value.toString(),
      });
      await ref.read(hasSeenOnboardingProvider.notifier).markAsSeen();
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
                    style: TextStyle(
                      fontSize: 13,
                      color: tokens.neutral.ink3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: _slides.length,
                onPageChanged: (i) {
                  index.value = i;
                  analytics.logEvent(
                    name: 'view_onboarding_slide',
                    parameters: {'slideIndex': i.toString()},
                  );
                },
                itemBuilder: (context, i) =>
                    _OnboardingSlide(data: _slides[i]),
              ),
            ),
            _DotsIndicator(count: _slides.length, currentIndex: index.value),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                child: AppPill(
                  label: index.value == _slides.length - 1 ? 'はじめる' : '次へ',
                  variant: AppPillVariant.accent,
                  large: true,
                  onPressed: () {
                    if (index.value == _slides.length - 1) {
                      finish(reason: 'complete');
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  final String emoji;
  final String eyebrow;
  final String title;
  final String body;
  const _OnboardingSlideData({
    required this.emoji,
    required this.eyebrow,
    required this.title,
    required this.body,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingSlideData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: neutral.surface2,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              data.emoji,
              style: const TextStyle(fontSize: 72, height: 1.0),
            ),
          ),
          const Spacer(),
          Text(
            data.eyebrow,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06,
              color: tokens.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: neutral.ink2,
                  height: 1.7,
                ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 3 ドットページネーション。アクティブのみ横長。
class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _DotsIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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
