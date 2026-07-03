import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';

/// カテゴリ画面の空状態に表示する、カテゴリ機能の価値訴求カード。
///
/// カテゴリは「買ったものを自動でグループ分け」＋「店ごとの並び替え」を担う本アプリの
/// キラー機能だが、空状態が「カテゴリを追加」ボタンだけだと初見ユーザーに価値が伝わらない。
/// そのため見出し・具体的ユースケースを文章とアイコンで示す。
///
/// 軸が1件もない初回空状態（`axes.isEmpty`）と、軸はあるがカテゴリ0件の空状態
/// （`categories.isEmpty`）の両方で使い回す。
///
/// [onAddCategory] が非nullのとき「＋ カテゴリを追加」ボタンを表示する。画面側に
/// 追加導線（FloatingActionButton 等）が既にある場合は null を渡してボタンを省く。
class CategoryEmptyState extends StatelessWidget {
  /// 「＋ カテゴリを追加」ボタンのタップ時コールバック。
  /// null のときボタンを表示しない（画面側の別導線で追加する想定）。
  final VoidCallback? onAddCategory;

  const CategoryEmptyState({super.key, required this.onAddCategory});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: neutral.surface2,
            borderRadius: BorderRadius.circular(AppThemeExtension.radiusCard),
            border: Border.all(color: neutral.divider, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.accentSoft,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.label_outline,
                  size: 28,
                  color: tokens.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '買ったものを自動でグループ分け',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: neutral.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const _CategoryUseCaseRow(
                icon: Icons.auto_awesome,
                text:
                    '「野菜」に トマト・玉ねぎ を登録すると、'
                    'リストで自動的に野菜セクションにまとまります',
              ),
              // 店舗ごとの並び順はファーストリリースでは非表示のため訴求も出さない (issue #465)。
              if (shoppingLocationFeatureEnabled) ...[
                const SizedBox(height: 12),
                const _CategoryUseCaseRow(
                  icon: Icons.storefront,
                  text:
                      '店ごとにカテゴリの並び順を変えられるので、'
                      '売り場の動線どおりに回れます',
                ),
              ],
              if (onAddCategory != null) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: onAddCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('カテゴリを追加'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 価値訴求カード内の具体的ユースケース1行（先頭アイコン＋説明文）。
class _CategoryUseCaseRow extends StatelessWidget {
  /// 行頭に表示するアイコン。
  final IconData icon;

  /// ユースケースの説明文。
  final String text;

  const _CategoryUseCaseRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final neutral = context.appTheme.neutral;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: neutral.ink3),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: neutral.ink2, height: 1.5),
          ),
        ),
      ],
    );
  }
}
