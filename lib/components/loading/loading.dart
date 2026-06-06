import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/environment.dart';

class Loading extends StatelessWidget {
  const Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (Environment.disableWidgetAnimation) {
      return Center(
        child: Container(
          color: colorScheme.secondary,
          width: 40,
          height: 40,
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(colorScheme.secondary)),
    );
  }
}

class ScaffoldLoading extends StatelessWidget {
  const ScaffoldLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Loading(),
    );
  }
}

/// 認証〜ホーム到達までの Resolver 連鎖が解決待ちの間に表示する起動ローディング画面。
///
/// テーマの `neutral.paper` を背景に敷き（黒地ではなくアプリと地続きの和紙色にする）、
/// 中央で買い物カゴがぽよんと弾むアニメーションと、波打つように順に躍る 3 つのドットを表示する。
///
/// 連鎖は段が解決するたびに表示中の LaunchLoading のツリー位置（祖先 Widget の型構成）が
/// 変わる。key 無しだと Flutter は element を再利用できず内部の AnimationController が
/// 破棄・再生成され、アニメーションが 0 から再スタートして「ぶつ切り」に見える。
/// [LaunchLoading.shared] は連鎖全段で共有する単一の GlobalKey を付与するため、段をまたいで
/// element が reparent され State が保持されてアニメーションが連続する。
///
/// 注意: [LaunchLoading.shared] は単一 GlobalKey のため、複数の AppResolvers 連鎖
/// （AppResolvers でラップされる appShowModalBottomSheet 等）が同フレームで LaunchLoading を
/// 描画すると GlobalKey 重複アサーションが発生しうる。通常はルート連鎖が解決済み（HomePage 表示）
/// の間にモーダルが開くため同時には起きないが、ルート連鎖が再 loading するケースでは起こり得る。
class LaunchLoading extends HookWidget {
  const LaunchLoading({super.key});

  /// 認証〜ホーム連鎖の各段で共有する単一の GlobalKey を付与する LaunchLoading。
  /// 段をまたいで element を reparent させ、アニメーションを途切れず連続させたい連鎖で使う。
  LaunchLoading.shared() : super(key: _sharedKey);

  /// 連鎖全段で共有する単一の GlobalKey。
  static final _sharedKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = tokens.accent;

    final bounce =
        useAnimationController(duration: const Duration(milliseconds: 560));
    // カゴのバウンス: reverse 往復で上下に弾ませる。マウント時に 1 度だけ開始すれば
    // 以降はループが継続するため依存配列は空にする。テスト時（disableWidgetAnimation）は
    // ループを開始せず静止状態にしてスナップショットを安定させる。
    useEffect(() {
      if (!Environment.disableWidgetAnimation) {
        bounce.repeat(reverse: true);
      }
      return null;
    }, const []);

    final dots =
        useAnimationController(duration: const Duration(milliseconds: 1100));
    // ドットの波: 0→1 のループ進行を 3 ドットへ位相をずらして配り、左から順に躍らせる。
    // 同じ理由で依存配列は空、テスト時はループを開始しない。
    useEffect(() {
      if (!Environment.disableWidgetAnimation) {
        dots.repeat();
      }
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: bounce,
              child:
                  Icon(Icons.shopping_basket_rounded, size: 56, color: accent),
              builder: (context, child) {
                final t = Curves.easeInOut.transform(bounce.value);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 持ち上がるほど上へ移動する（接地→ジャンプ→接地）
                    Transform.translate(
                      offset: Offset(0, -16 * t),
                      child: child,
                    ),
                    const SizedBox(height: 10),
                    // 影: 持ち上がるほど横に縮んで薄く、接地時に広がって濃くなる
                    Transform.scale(
                      scaleX: 1 - 0.35 * t,
                      child: Container(
                        width: 44,
                        height: 7,
                        decoration: BoxDecoration(
                          // 影は常に暗色（墨色）で描く。
                          color: const Color(0xFF1B1813)
                              .withValues(alpha: 0.20 - 0.12 * t),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            AnimatedBuilder(
              animation: dots,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    // index ごとに位相をずらした三角波（0→1→0）で大きさと濃さを変える
                    final phase = (dots.value - index * 0.2) % 1.0;
                    final wave = 1 - (phase * 2 - 1).abs();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Transform.scale(
                        scale: 0.7 + 0.5 * wave,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.35 + 0.55 * wave),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              '準備中...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: tokens.neutral.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
