import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// FAB 長押しで展開するメニューの 1 アクション。
class FabMenuAction {
  /// メニュー行の円形ボタンに表示するアイコン。
  final IconData icon;

  /// アイコン左に表示するラベル（ピル型）。
  final String label;

  /// null のときは無効状態（dim 表示・タップ不可）。
  final VoidCallback? onTap;

  FabMenuAction({required this.icon, required this.label, required this.onTap});
}

/// FAB の上に展開するアクションメニュー。`ExpandableFab` / `CreateListFab` で共用する。
///
/// [animation] の値 0→1 に応じて、下端基準で上方向へ伸縮する。
/// レイアウト内に収めることで Stack 境界外オーバーフローによるタップ不可を解消する。
class FabActionMenu extends StatelessWidget {
  /// 開閉アニメーション。呼び出し側の AnimationController（curve 適用済み）を渡す。
  final Animation<double> animation;

  /// 上から順に表示するアクション。
  final List<FabMenuAction> actions;

  const FabActionMenu({
    super.key,
    required this.animation,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomRight,
            heightFactor: t,
            child: Opacity(opacity: t, child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final action in actions) ...[
              _FabActionRow(action: action),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// 展開メニュー 1 行（ラベル + 円形アイコンボタン）。
/// 伸縮アニメーションは親（[FabActionMenu]）の `ClipRect + Align` 側で行うため、
/// この行自体はレイアウト内に常駐し、タップ判定を確実に受け取る。
/// ラベル・余白・アイコンのいずれをタップしても発火するよう、行全体を 1 つのタップ領域にする
/// （アイコンの 44px だけでなくラベルからもタップできるようにする）。
class _FabActionRow extends StatelessWidget {
  final FabMenuAction action;

  const _FabActionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    // onTap が null のときは無効状態。AppPill と同じ opacity 0.5 で dim 表示する。
    final disabled = action.onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _FabActionLabel(label: action.label),
            const SizedBox(width: 10),
            Material(
              color: tokens.neutral.surface2,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: action.onTap,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(action.icon, size: 20, color: tokens.neutral.ink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 展開メニュー行のラベル部分（ピル型の濃色背景 + 白文字）。
class _FabActionLabel extends StatelessWidget {
  final String label;
  const _FabActionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.neutral.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: tokens.neutral.surface,
        ),
      ),
    );
  }
}
