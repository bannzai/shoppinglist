import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/receipt/receipt_edit_sheet.dart';
import 'package:shoppinglist/features/receipt/receipt_image.dart';
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
          // 非プレミアムはレシート全体が Paywall 対象のため、サムネ（画像内容）も
          // 表示しない。プレミアムのみ登録済みサムネを横スクロールで表示する。
          if (isPremium && receipts.isNotEmpty) ...[
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
                      child: ReceiptImage(
                        storagePath: receipt.storagePath,
                        width: 84,
                        height: 84,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
