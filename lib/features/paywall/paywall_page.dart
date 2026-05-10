import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// プレミアムプランへのアップグレード画面。
///
/// `design_handoff_shopping_list/source/screens-settings.jsx#PaywallPage` 相当。
///
/// 現在 RevenueCat Offering の monthly / annual / lifetime Package を提示し、
/// 選択された Package で `purchaseProvider.call()` 経由で RC に購入リクエストを送る。
class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final offerings = ref.watch(offeringsProvider);

    return Scaffold(
      backgroundColor: neutral.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
        backgroundColor: neutral.surface,
      ),
      body: offerings.when(
        loading: () => const _LoadingBody(),
        error: (e, _) => _ErrorBody(
          exception: e,
          onRetry: () {
            analytics.logEvent(name: 'tap_paywall_retry');
            ref.invalidate(offeringsProvider);
          },
        ),
        data: (_) {
          final monthly = ref.watch(monthlyPackageProvider);
          final annual = ref.watch(annualPackageProvider);
          final lifetime = ref.watch(lifetimePackageProvider);
          if (monthly == null && annual == null && lifetime == null) {
            return const _NoPlansBody();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _Hero(),
              const SizedBox(height: 24),
              const _FeatureGrid(),
              const SizedBox(height: 24),
              if (monthly != null) _PaywallPackageTile(package: monthly),
              if (annual != null)
                _PaywallPackageTile(package: annual, recommended: true),
              if (lifetime != null) _PaywallPackageTile(package: lifetime),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'いつでもキャンセル可能・自動更新は購入後 24 時間前まで',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: neutral.ink3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// プレミアムタイトル + crown のヒーロー。
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tokens.accent, const Color(0xFF7C2A07)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: tokens.accent.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'プレミアムにアップグレード',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: tokens.neutral.ink,
            letterSpacing: -0.015,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '全機能を解放して、家族みんなで気持ちよく使えます。',
          style: TextStyle(
            fontSize: 13,
            color: tokens.neutral.ink2,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

/// 6 項目の特典リスト。
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _features = [
    (Icons.location_on_outlined, '店舗ごとの並び順'),
    (Icons.photo_camera_outlined, '写真からのアイテム抽出（月 50 回）'),
    (Icons.auto_fix_high, 'URL からのアイテム抽出（月 50 回）'),
    (Icons.palette_outlined, '5 色のテーマカラー'),
    (Icons.ios_share_outlined, 'リストのエクスポート'),
    (Icons.all_inclusive, 'リスト保存期間が無制限'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.neutral.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.neutral.divider, width: 0.5),
      ),
      child: Column(
        children: [
          for (final (icon, label) in _features) ...[
            _FeatureRow(icon: icon, label: label),
            if (label != _features.last.$2) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Icon(icon, size: 18, color: tokens.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              color: tokens.neutral.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(Icons.check_circle, size: 16, color: tokens.neutral.ok),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorBody extends StatelessWidget {
  final Object exception;
  final VoidCallback onRetry;
  const _ErrorBody({required this.exception, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tokens.neutral.dangerSoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📡', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(exception.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: tokens.neutral.ink2)),
            const SizedBox(height: 16),
            AppPill(
              label: '再試行',
              variant: AppPillVariant.accent,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPlansBody extends StatelessWidget {
  const _NoPlansBody();
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          '現在ご利用いただけるプランがありません',
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.neutral.ink2),
        ),
      ),
    );
  }
}

/// 1 つの Package を行として表示し、ボタンタップで購入フローを起動するタイル。
class _PaywallPackageTile extends ConsumerWidget {
  const _PaywallPackageTile({required this.package, this.recommended = false});

  final Package package;
  final bool recommended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: neutral.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: recommended ? tokens.accent : neutral.divider,
          width: recommended ? 1.5 : 0.5,
        ),
        boxShadow: recommended
            ? [
                BoxShadow(
                  color: tokens.accent.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        package.storeProduct.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: neutral.ink,
                        ),
                      ),
                    ),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: tokens.accentSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'お得',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tokens.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  package.storeProduct.priceString,
                  style: TextStyle(
                    fontSize: 13,
                    color: neutral.ink2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            key: Key('paywall_subscribe_${package.packageType.name}'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  recommended ? tokens.accent : neutral.surface2,
              foregroundColor: recommended ? Colors.white : neutral.ink,
              shape: const StadiumBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () async {
              analytics.logEvent(
                name: 'tap_paywall_subscribe',
                parameters: {'packageType': package.packageType.name},
              );
              try {
                final completed =
                    await ref.read(purchaseProvider).call(package);
                if (!context.mounted) return;
                if (completed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('購入ありがとうございました')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('購入'),
          ),
        ],
      ),
    );
  }
}
