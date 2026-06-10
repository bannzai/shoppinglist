import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_preview_sheet.dart';
import 'package:shoppinglist/style/tokens.dart';

/// preview 用に AIカテゴリ分けの確認・調整シートを即時表示する pseudo page。
/// Function を呼ばずにシートのレイアウト・カテゴリ変更UIをキャプチャする目的。
class AICategorizePreviewSheetPreview extends StatefulWidget {
  const AICategorizePreviewSheetPreview({super.key});

  @override
  State<AICategorizePreviewSheetPreview> createState() =>
      _AICategorizePreviewSheetPreviewState();
}

class _AICategorizePreviewSheetPreviewState
    extends State<AICategorizePreviewSheetPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await showAICategorizePreviewSheet(
        context: context,
        categorized: const [
          (name: 'にんじん', categoryName: '野菜'),
          (name: '玉ねぎ', categoryName: '野菜'),
          (name: '鶏もも肉', categoryName: '肉'),
          (name: '牛乳', categoryName: '乳製品'),
          (name: 'トイレットペーパー', categoryName: '日用品'),
        ],
        existingCategoryNames: const ['野菜', '肉'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.neutral.paper,
      appBar: AppBar(title: const Text('AI Categorize Sheet (Preview)')),
    );
  }
}
