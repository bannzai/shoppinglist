import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/receipt/receipt_edit_sheet.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 買い物リスト詳細画面の末尾に表示するレシートセクション。
///
/// チェック済みアイテムが1件以上あるとき（買い物が始まった/終わった後）にのみ
/// 親 [ShoppingListBodyContent] から表示される。レシートの登録・閲覧の導線で、
/// 非プレミアムユーザーがタップした場合は Paywall へ誘導する（プレミアム機能）。
class ReceiptSection extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;

  const ReceiptSection({
    super.key,
    required this.groupID,
    required this.shoppingListID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final receipts = ref
            .watch(receiptsProvider(
                groupID: groupID, shoppingListID: shoppingListID))
            .asData
            ?.value ??
        const [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: tokens.accent),
              const SizedBox(width: 6),
              Text(
                'レシート',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (!isPremium) ...[
                const SizedBox(width: 4),
                Icon(Icons.workspace_premium, size: 16, color: tokens.accent),
              ],
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: const Text('追加'),
                onPressed: () {
                  analytics.logEvent(
                    name: 'tap_add_receipt',
                    parameters: {
                      'groupID': groupID,
                      'shoppingListID': shoppingListID,
                    },
                  );
                  if (!isPremium) {
                    showPaywall(context: context);
                    return;
                  }
                  showReceiptEditSheet(
                    context: context,
                    groupID: groupID,
                    shoppingListID: shoppingListID,
                    receipt: null,
                  );
                },
              ),
            ],
          ),
          if (receipts.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: receipts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final receipt = receipts[index];
                  return GestureDetector(
                    onTap: () {
                      analytics.logEvent(
                        name: 'tap_receipt_thumbnail',
                        parameters: {
                          'groupID': groupID,
                          'receiptID': receipt.id,
                        },
                      );
                      showReceiptEditSheet(
                        context: context,
                        groupID: groupID,
                        shoppingListID: shoppingListID,
                        receipt: receipt,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: receipt.imageURL ?? '',
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 84,
                          height: 84,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          width: 84,
                          height: 84,
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 左下に浮く ProgressPill（page.dart, bottom: 16 + SafeArea, 高さ約30）と
            // サムネが重ならないよう、ピル + ホームインジケータ分の下余白を確保する。
            SizedBox(height: 42 + MediaQuery.of(context).padding.bottom),
          ],
        ],
      ),
    );
  }
}
