import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/image/storage_image.dart';
import 'package:shoppinglist/entity/group_shopping_list_source_image.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 「写真から追加」（AI 画像認識）で保存した元画像のサムネイル一覧。
///
/// 買い物リスト上部に横スクロールで表示し、タップで拡大表示する。
/// 元画像が1枚もない場合は何も表示しない。
/// 元画像は最大 [maxShoppingListSourceImageCount] 枚（超過分はサーバー側で
/// 古い順に削除される）で、保存日時の新しい順に並ぶ（Issue #530）。
class SourceImageStrip extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;

  const SourceImageStrip({
    super.key,
    required this.groupID,
    required this.shoppingListID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceImages =
        ref
            .watch(
              sourceImagesProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
              ),
            )
            .asData
            ?.value ??
        const [];
    if (sourceImages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        // AppPill(レシート導線)より控えめに収まる高さ。3:2横写真のサムネでも
        // 被写体が判別できる最小サイズとして 56 を採用。
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sourceImages.length,
          separatorBuilder: (context, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final sourceImage = sourceImages[index];
            return GestureDetector(
              onTap: () {
                analytics.logEvent(
                  name: 'tap_source_image',
                  parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                    'sourceImageID': sourceImage.id,
                  },
                );
                _showFullScreenSourceImage(context, sourceImage: sourceImage);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: StorageImage(
                  storagePath: sourceImage.storagePath,
                  width: 56,
                  height: 56,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 元画像をピンチズーム可能なダイアログで拡大表示する。
  void _showFullScreenSourceImage(
    BuildContext context, {
    required GroupShoppingListSourceImage sourceImage,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: InteractiveViewer(
            maxScale: 5,
            child: StorageImage(
              storagePath: sourceImage.storagePath,
              width: double.infinity,
              // 縦長の手書きメモ写真も全体が収まるよう画面高の6割を確保する。
              height: MediaQuery.sizeOf(dialogContext).height * 0.6,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
