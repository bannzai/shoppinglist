import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// プレミアムプランへのアップグレード画面。
///
/// 現在 RevenueCat Offering の monthly / annual / lifetime Package を提示し、
/// 選択された Package で `purchaseProvider.call()` 経由で RC に購入リクエストを送る。
/// Debug ビルドでは `Secret.revenueCatTestStorePublicAPIKey` 経由で RC Test Store の
/// mock purchase modal が表示される（実課金なし）。
class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('プレミアムプラン')),
      body: offerings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) {
          final monthly = ref.watch(monthlyPackageProvider);
          final annual = ref.watch(annualPackageProvider);
          final lifetime = ref.watch(lifetimePackageProvider);
          if (monthly == null && annual == null && lifetime == null) {
            return const Center(
              child: Text('現在ご利用いただけるプランがありません'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('プレミアムにアップグレードすると全機能が解放されます'),
              ),
              const SizedBox(height: 8),
              if (monthly != null) _PaywallPackageTile(package: monthly),
              if (annual != null) _PaywallPackageTile(package: annual),
              if (lifetime != null) _PaywallPackageTile(package: lifetime),
            ],
          );
        },
      ),
    );
  }
}

/// 1 つの Package を行として表示し、タップで購入フローを起動するタイル。
///
/// ElevatedButton に `Key('paywall_subscribe_{packageType}')` を付与しており、
/// Maestro E2E から id 指定で tap できるようにしている。
class _PaywallPackageTile extends ConsumerWidget {
  const _PaywallPackageTile({required this.package});

  final Package package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(package.storeProduct.title),
        subtitle: Text(package.storeProduct.priceString),
        trailing: ElevatedButton(
          key: Key('paywall_subscribe_${package.packageType.name}'),
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
      ),
    );
  }
}
