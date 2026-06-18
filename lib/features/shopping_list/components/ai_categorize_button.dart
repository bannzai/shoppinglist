import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_preview_sheet.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 未分類アイテムを AI でカテゴリ分けするボタン。
///
/// 未分類アイテムがあるときに呼び出し側がリスト上部に表示する。
/// タップで残回数チェック → Function 呼び出し → プレビューシート → 登録 まで担う。
/// [categoryAxisID] は現在表示中の軸（無ければ null = デフォルト軸を作成）。
class AICategorizeButton extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? categoryAxisID;
  final List<GroupShoppingListItem> uncategorizedItems;
  final List<String> existingCategoryNames;

  const AICategorizeButton({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.categoryAxisID,
    required this.uncategorizedItems,
    required this.existingCategoryNames,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AI 処理中（実行中バナー表示中）は連打・多重実行を防ぐためボタンを無効化する。
    // 画像/URL/カテゴリ分けはどれも同じ aIProcessingProvider・同じバナーを共有するため、
    // いずれかが実行中なら無効化する。
    final isAIProcessing = ref.watch(aIProcessingProvider) != null;
    return Padding(
      // リスト先頭のカテゴリセクションと密着しないよう下側に余白を確保する。
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: AppPill(
        label: '自動でカテゴリ分け（${uncategorizedItems.length}件）',
        icon: Icons.auto_fix_high,
        variant: AppPillVariant.accent,
        expanded: true,
        onPressed: isAIProcessing ? null : () => _run(context, ref),
      ),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref) async {
    analytics.logEvent(
      name: 'tap_ai_categorize',
      parameters: {
        'groupID': groupID,
        'shoppingListID': shoppingListID,
        'itemCount': uncategorizedItems.length.toString(),
      },
    );

    final isPremium =
        ref.read(customerInfoProvider).asData?.value.isPremium ?? false;
    final remaining = ref.read(
      remainingCategorizeCountProvider(isPremium: isPremium),
    );
    if (remaining <= 0) {
      final limit =
          isPremium
              ? premiumMonthlyCategorizeLimit
              : freeMonthlyCategorizeLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            '自動カテゴリ分けの月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyCategorizeLimit回まで利用できます'}',
          ),
          action:
              isPremium
                  ? null
                  : SnackBarAction(
                    label: 'アップグレード',
                    onPressed: () => showPaywall(context: context),
                  ),
        ),
      );
      return;
    }

    ref.read(aIProcessingProvider.notifier).start(AIProcessingType.categorize);
    List<({String name, String categoryName})> categorized;
    try {
      categorized = await functions.categorizeShoppingListItems(
        itemNames: uncategorizedItems.map((e) => e.message).toList(),
        existingCategoryNames: existingCategoryNames,
      );
    } catch (e, st) {
      if (context.mounted) {
        showErrorSnackBar(context, e, st);
      }
      return;
    } finally {
      ref.read(aIProcessingProvider.notifier).end();
    }
    if (!context.mounted) {
      return;
    }

    final reviewed = await showAICategorizePreviewSheet(
      context: context,
      categorized: categorized,
      existingCategoryNames: existingCategoryNames,
    );
    if (reviewed == null) {
      return;
    }
    final included = reviewed.where((c) => c.included).toList();
    if (included.isEmpty) {
      return;
    }

    try {
      await ref
          .read(aiCategorizeApplyProvider(groupID: groupID))
          .call(
            groupID: groupID,
            userID: ref.read(currentUserIDProvider)!,
            categoryAxisID: categoryAxisID,
            assignments:
                included
                    .map(
                      (c) => (
                        itemName: c.itemName,
                        categoryName: c.categoryName,
                      ),
                    )
                    .toList(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            persist: false,
            content: Text('${included.length}件をカテゴリに登録しました'),
          ),
        );
      }
    } catch (e, st) {
      if (context.mounted) {
        showErrorSnackBar(context, e, st);
      }
    }
  }
}
