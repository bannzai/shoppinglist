import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/receipt/receipt_edit_sheet.dart';
import 'package:shoppinglist/features/receipt/receipt_image.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 買い物リスト上部（AIカテゴリ分けボタンの直上）に表示するレシート登録の導線。
///
/// チェック済みアイテムが1件以上あるとき（買い物が始まった/終わった後）にのみ
/// 親 [ShoppingListBodyContent] から表示される。以前はリスト最下部（footer）に
/// 出していたが、リストが長いと気づきにくいため、AIカテゴリ分けボタンと同じ上部
/// エリアに移した。AIカテゴリ分けボタン（accent 塗りつぶしで目立つ）より主張を抑える
/// ため soft（accent 薄塗り）トーンの控えめな pill にする。
/// 非プレミアムユーザーがタップした場合は Paywall へ誘導する（プレミアム機能）。
class ReceiptAddButton extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;

  const ReceiptAddButton({
    super.key,
    required this.groupID,
    required this.shoppingListID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      // AIカテゴリ分けボタンと同じ全幅 pill の形にそろえる。非プレミアムの王冠は
      // ボタン内（label の末尾）に収める。色は soft（accent 薄塗り）で控えめにする。
      child: AppPill(
        label: 'レシートを追加',
        icon: Icons.receipt_long,
        trailingIcon: isPremium ? null : Icons.workspace_premium,
        variant: AppPillVariant.soft,
        expanded: true,
        onPressed: () {
          analytics.logEvent(
            name: 'tap_add_receipt',
            parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
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
    );
  }
}

/// 買い物リスト最下部（footer）に表示する登録済みレシートのサムネイル一覧。
///
/// プレミアムかつレシートが1件以上あるときのみ中身を表示する（それ以外は何も
/// 表示しない）。非プレミアムはレシート全体が Paywall 対象のため、サムネ（画像内容）も
/// 表示しない。サムネをタップすると該当レシートの編集シートを開く。
class ReceiptThumbnails extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;

  const ReceiptThumbnails({
    super.key,
    required this.groupID,
    required this.shoppingListID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final receipts =
        ref
            .watch(
              receiptsProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
              ),
            )
            .asData
            ?.value ??
        const [];

    if (!isPremium || receipts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: tokens.accent),
              const SizedBox(width: 6),
              // 黒文字だと周囲から浮くため、アイコンと同じ accent 色で見出しをまとめる。
              Text(
                'レシート',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: tokens.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
                      parameters: {'groupID': groupID, 'receiptID': receipt.id},
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
      ),
    );
  }
}
