import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_review_sheet.dart';
import 'package:shoppinglist/style/tokens.dart';

/// preview 用に AI review sheet を即時表示する pseudo page。
/// `design_handoff_shoppinglist/preview/widgets-and-micro.jsx#MicroAIProgress` の
/// 確定までを画面でキャプチャする目的。
class AIReviewSheetPreview extends StatefulWidget {
  const AIReviewSheetPreview({super.key});

  @override
  State<AIReviewSheetPreview> createState() => _AIReviewSheetPreviewState();
}

class _AIReviewSheetPreviewState extends State<AIReviewSheetPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await showAIReviewSheet(
        context: context,
        rawNames: const ['牛乳', 'パン', '卵', 'にんじん', '玉ねぎ'],
        source: 'preview',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.neutral.paper,
      appBar: AppBar(title: const Text('AI Review Sheet (Preview)')),
    );
  }
}
