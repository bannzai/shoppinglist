import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/group_category_edit/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/stdlib/navigator.dart';

class _PresetColor {
  final String label;
  final String hex;

  const _PresetColor({required this.label, required this.hex});
}

const _presetColors = [
  _PresetColor(label: '赤', hex: '#F44336'),
  _PresetColor(label: 'オレンジ', hex: '#FF9800'),
  _PresetColor(label: '黄', hex: '#FFEB3B'),
  _PresetColor(label: '緑', hex: '#4CAF50'),
  _PresetColor(label: '青', hex: '#2196F3'),
  _PresetColor(label: '紫', hex: '#9C27B0'),
  _PresetColor(label: 'ピンク', hex: '#E91E63'),
  _PresetColor(label: '灰', hex: '#9E9E9E'),
];

class TextShoppingListItemDetailBottomSheet extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingListItem textShoppingListItem;

  const TextShoppingListItemDetailBottomSheet({
    super.key,
    required this.groupID,
    required this.textShoppingListItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider)!;
    final descriptionController = useTextEditingController(
      text: textShoppingListItem.description ?? '',
    );
    final selectedColor = useState<String?>(textShoppingListItem.color);
    final colorScheme = Theme.of(context).colorScheme;

    // 写真関連の状態
    final originalImageURL = textShoppingListItem.imageURL;
    final imageURL = useState<String?>(textShoppingListItem.imageURL);
    final selectedPhoto = useState<XFile?>(null);
    final removeImageOnSave = useState<bool>(false);
    final isSavingImage = useState<bool>(false);

    // カテゴリは先頭軸(axes.first)のキーワードマッチで動的に決まる(アイテムはカテゴリIDを持たない)。
    // appShowModalBottomSheet は AppResolvers でラップされているため build 内の ref.watch が機能する。
    // 遷移時の ref.read だと AsyncLoading(null) になり得るので、ここで watch して値を確定させる。
    final categoryAxes =
        ref.watch(groupCategoryAxesProvider(groupID: groupID)).valueOrNull ??
            const <GroupCategoryAxis>[];
    final categoryAxis = categoryAxes.firstOrNull;
    final categories = categoryAxis == null
        ? const <GroupCategory>[]
        : ref
                .watch(groupCategoriesProvider(
                    groupID: groupID, categoryAxisID: categoryAxis.id))
                .valueOrNull ??
            const <GroupCategory>[];
    final matchedCategory = categoryAxis == null
        ? null
        : categories.firstWhereOrNull((category) =>
            category.id ==
            findMatchingCategoryID(
                item: textShoppingListItem, categories: categories));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textShoppingListItem.message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // カテゴリセクション。軸が無い(カテゴリ機能未使用)ときは表示しない。
          if (categoryAxis != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'カテゴリ',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(matchedCategory?.name ?? '未分類')),
                TextButton(
                  onPressed: () {
                    analytics.logEvent(
                      name: matchedCategory != null
                          ? 'tap_edit_category_from_item'
                          : 'tap_manage_category_from_item',
                      parameters: {
                        'groupID': groupID,
                        'itemID': textShoppingListItem.id,
                      },
                    );
                    // マッチ時はそのカテゴリの編集ページへ。未分類時はカテゴリ選択
                    // モードの一覧へ誘導し、行タップでこのアイテムを既存カテゴリへ
                    // 割り当てる(アイテム名をそのカテゴリのキーワードに追記する)。
                    // シートは閉じずに push する(戻ればメモ等の編集状態を保持したまま戻れる)。
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => matchedCategory != null
                            ? GroupCategoryEditPage(
                                groupID: groupID,
                                categoryAxisID: categoryAxis.id,
                                categoryID: matchedCategory.id,
                              )
                            : GroupCategoryPage(
                                groupID: groupID,
                                selectionForItem: textShoppingListItem,
                              ),
                      ),
                    );
                  },
                  child: Text(matchedCategory != null ? 'カテゴリを編集' : 'カテゴリを管理'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          // メモセクション
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'メモ',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '補足説明を入力',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          // 写真セクション
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '写真',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          _PhotoSection(
            groupID: groupID,
            itemID: textShoppingListItem.id,
            imageURL: imageURL,
            selectedPhoto: selectedPhoto,
            removeImageOnSave: removeImageOnSave,
            originalImageURL: originalImageURL,
          ),
          const SizedBox(height: 24),
          // カラーセクション
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'カラー',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // 色なしボタン
              Semantics(
                label: '色なし',
                child: GestureDetector(
                  onTap: () {
                    analytics.logEvent(
                        name: 'tap_item_remove_color',
                        parameters: {
                          'groupID': groupID,
                          'itemID': textShoppingListItem.id
                        });
                    selectedColor.value = null;
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor.value == null
                            ? colorScheme.onSurface
                            : colorScheme.outline,
                        width: selectedColor.value == null ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      Icons.block,
                      size: 20,
                      color: colorScheme.outline,
                    ),
                  ),
                ),
              ),
              // プリセットカラー
              for (final preset in _presetColors)
                Semantics(
                  label: preset.label,
                  child: GestureDetector(
                    onTap: () {
                      analytics.logEvent(
                          name: 'tap_item_select_color',
                          parameters: {
                            'groupID': groupID,
                            'itemID': textShoppingListItem.id,
                            'color': preset.hex
                          });
                      selectedColor.value = preset.hex;
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorFromHex(preset.hex),
                        border: Border.all(
                          color: selectedColor.value == preset.hex
                              ? colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: selectedColor.value == preset.hex
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // 保存ボタン
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSavingImage.value
                  ? null
                  : () async {
                      analytics.logEvent(
                          name: 'tap_save_item_detail',
                          parameters: {
                            'groupID': groupID,
                            'itemID': textShoppingListItem.id
                          });
                      // 写真アップロード等の await 中にシートが手動クローズされると、
                      // 遅延した pop がホームまで剥がして黒画面になるため、
                      // pop はこのシート自身のルートに限定する (#372)。
                      final navigator = Navigator.of(context);
                      final sheetRoute = ModalRoute.of(context);
                      isSavingImage.value = true;
                      try {
                        var nextImageURL = imageURL.value;

                        if (selectedPhoto.value != null) {
                          final file = File(selectedPhoto.value!.path);
                          nextImageURL =
                              await functions.uploadShoppingListItemImage(
                            groupID: groupID,
                            shoppingListID: textShoppingListItem.shoppingListID,
                            itemID: textShoppingListItem.id,
                            mimeType: mimeType(file),
                            base64Image: await base64CompressImage(file),
                          );
                        } else if (removeImageOnSave.value &&
                            originalImageURL != null) {
                          await functions.deleteShoppingListItemImage(
                            groupID: groupID,
                            shoppingListID: textShoppingListItem.shoppingListID,
                            itemID: textShoppingListItem.id,
                          );
                          nextImageURL = null;
                        }

                        final description = descriptionController.text.trim();
                        ref
                            .read(updateShoppingListItemProvider(
                                groupID: groupID))
                            .call(
                              shoppingListID:
                                  textShoppingListItem.shoppingListID,
                              item: textShoppingListItem.copyWith(
                                description:
                                    description.isEmpty ? null : description,
                                color: selectedColor.value,
                                imageURL: nextImageURL,
                              ),
                              editedByUserID: currentUserID,
                            );

                        popRouteSafely(navigator: navigator, route: sheetRoute);
                      } catch (e) {
                        // シート上の SnackBar は背後の Scaffold に描画されて
                        // 見えないため、前面に出るグローバルトーストで通知する。
                        showGlobalToast(e.toString(), title: null);
                      } finally {
                        // シートが既に dispose 済み(手動クローズ等)の場合に
                        // 破棄済みの ValueNotifier へ書き込まないようガードする。
                        if (context.mounted) {
                          isSavingImage.value = false;
                        }
                      }
                    },
              child: isSavingImage.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ),
          const SizedBox(height: 12),
          // 削除ボタン
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('このアイテムを削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          analytics.logEvent(
                              name: 'tap_confirm_delete_item',
                              parameters: {
                                'groupID': groupID,
                                'itemID': textShoppingListItem.id
                              });
                          ref
                              .read(groupDatabaseProvider(groupID: groupID))
                              .shoppingListItemsReference(
                                shoppingListID:
                                    textShoppingListItem.shoppingListID,
                              )
                              .doc(textShoppingListItem.id)
                              .delete();
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: Text(
                          '削除',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.error),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('キャンセル'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('削除'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 写真セクションのUI。選択した画像のプレビュー・追加・削除を行う。
class _PhotoSection extends HookConsumerWidget {
  final String groupID;
  final String itemID;
  final ValueNotifier<String?> imageURL;
  final ValueNotifier<XFile?> selectedPhoto;
  final ValueNotifier<bool> removeImageOnSave;
  final String? originalImageURL;

  const _PhotoSection({
    required this.groupID,
    required this.itemID,
    required this.imageURL,
    required this.selectedPhoto,
    required this.removeImageOnSave,
    required this.originalImageURL,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    // ローカル選択画像があればそれを表示
    if (selectedPhoto.value != null) {
      return _buildImagePreview(
        context: context,
        colorScheme: colorScheme,
        ref: ref,
        isPremium: isPremium,
        child: Image.file(
          File(selectedPhoto.value!.path),
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    // サーバー上の画像URLがあれば表示
    if (imageURL.value != null) {
      return _buildImagePreview(
        context: context,
        colorScheme: colorScheme,
        ref: ref,
        isPremium: isPremium,
        child: CachedNetworkImage(
          imageUrl: imageURL.value!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const SizedBox(
            height: 200,
            child: Center(child: Icon(Icons.broken_image, size: 48)),
          ),
        ),
      );
    }

    // 画像がない場合は追加ボタン
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showImageSourceDialog(
            context: context, ref: ref, isPremium: isPremium),
        icon: const Icon(Icons.add_a_photo),
        label: isPremium
            ? const Text('写真を追加')
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('写真を追加'),
                  const SizedBox(width: 6),
                  // 写真添付がプレミアム機能であることを示す王冠。未課金時のみ表示。
                  Icon(
                    Icons.workspace_premium,
                    size: 18,
                    color: context.appTheme.accent,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImagePreview({
    required BuildContext context,
    required ColorScheme colorScheme,
    required WidgetRef ref,
    required bool isPremium,
    required Widget child,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              // 写真を変更
              _CircleIconButton(
                icon: Icons.edit,
                colorScheme: colorScheme,
                onTap: () => _showImageSourceDialog(
                    context: context, ref: ref, isPremium: isPremium),
              ),
              const SizedBox(width: 8),
              // 写真を削除
              _CircleIconButton(
                icon: Icons.delete,
                colorScheme: colorScheme,
                onTap: () {
                  analytics.logEvent(
                      name: 'tap_item_remove_photo',
                      parameters: {'groupID': groupID, 'itemID': itemID});
                  selectedPhoto.value = null;
                  imageURL.value = null;
                  removeImageOnSave.value = originalImageURL != null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog({
    required BuildContext context,
    required WidgetRef ref,
    required bool isPremium,
  }) {
    if (!isPremium) {
      analytics.logEvent(
          name: 'tap_item_photo_non_premium',
          parameters: {'groupID': groupID, 'itemID': itemID});
      // シートが閉じられた後でもアクションからペイウォールを開けるよう、
      // 生存し続ける root Navigator の context を束ねておく。
      final paywallContext = Navigator.of(context, rootNavigator: true).context;
      showGlobalActionToast(
        message: '商品写真の添付はプレミアム機能です',
        actionLabel: 'アップグレード',
        onAction: () => showPaywall(context: paywallContext),
      );
      return;
    }

    analytics.logEvent(
        name: 'tap_item_add_photo',
        parameters: {'groupID': groupID, 'itemID': itemID});

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('フォトライブラリから選択'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 画像を選択する。アップロードは保存ボタン押下時に実行する。
  Future<void> _pickImage({required ImageSource source}) async {
    final photo = await ImagePicker().pickImage(source: source);
    if (photo == null) {
      return;
    }

    selectedPhoto.value = photo;
    imageURL.value = null;
    removeImageOnSave.value = false;
  }
}

/// 画像プレビュー上のアクションボタン。
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface.withValues(alpha: 0.8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
