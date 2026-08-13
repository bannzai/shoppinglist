import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/receipt/receipt_edit_sheet.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 買い物リスト上部（AIカテゴリ分けボタンの直上）に表示するレシート登録/編集の導線。
///
/// チェック済みアイテムが1件以上あるとき（買い物が始まった/終わった後）にのみ
/// 親 [ShoppingListBodyContent] から表示される。以前はリスト最下部（footer）に
/// 登録済みレシートのサムネ一覧（`ReceiptThumbnails`）を併設していたが、サムネ一覧は
/// 廃止し、レシートの有無をこのボタンのラベルで表現するように一本化した。
///   - 未登録: 「レシートを追加」（新規登録シートを開く）
///   - 登録済み: 「レシートを編集」（既存レシートの編集シートを開く）
/// レシートは設計上1リストに複数枚保持できるが、UI では先頭（最新）の1枚のみを編集対象に
/// する（`receipts.isEmpty` のみで出し分ける）。AIカテゴリ分けボタン（accent 塗りつぶしで
/// 目立つ）より主張を抑えるため soft（accent 薄塗り）トーンの控えめな pill にする。
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
    // レシートの実体（画像・金額・メモ）はプレミアムのみ扱えるため、編集導線は
    // プレミアムかつ登録済みのときだけ出す。非プレミアムは常に追加導線（→ Paywall）。
    final existingReceipt =
        isPremium && receipts.isNotEmpty ? receipts.first : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      // AIカテゴリ分けボタンと同じ全幅 pill の形にそろえる。非プレミアムの王冠は
      // ボタン内（label の末尾）に収める。色は soft（accent 薄塗り）で控えめにする。
      child: AppPill(
        label:
            existingReceipt == null
                ? context.l10n.receiptAdd
                : context.l10n.receiptEdit,
        icon: Icons.receipt_long,
        trailingIcon: isPremium ? null : Icons.workspace_premium,
        variant: AppPillVariant.soft,
        expanded: true,
        onPressed: () {
          analytics.logEvent(
            name:
                existingReceipt == null
                    ? 'tap_add_receipt'
                    : 'tap_edit_receipt',
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
            receipt: existingReceipt,
          );
        },
      ),
    );
  }
}
