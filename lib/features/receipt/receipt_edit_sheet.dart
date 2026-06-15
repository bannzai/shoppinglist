import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/group_shopping_list_receipt.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/navigator.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// レシートの新規登録・編集シートを表示する。
///
/// [receipt] が null のときは新規登録、非null のときはそのレシートの閲覧/編集/削除。
Future<void> showReceiptEditSheet({
  required BuildContext context,
  required String groupID,
  required String shoppingListID,
  required GroupShoppingListReceipt? receipt,
}) {
  return appShowModalBottomSheet(
    context: context,
    builder: (context) => _ReceiptEditSheet(
      groupID: groupID,
      shoppingListID: shoppingListID,
      receipt: receipt,
    ),
  );
}

/// レシートの画像・金額・メモを編集するシート本体。
class _ReceiptEditSheet extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final GroupShoppingListReceipt? receipt;

  const _ReceiptEditSheet({
    required this.groupID,
    required this.shoppingListID,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider);
    final selectedPhoto = useState<XFile?>(null);
    final imageURL = useState<String?>(receipt?.imageURL);
    final isSaving = useState<bool>(false);
    final amountController = useTextEditingController(
      text: receipt?.amount?.toString() ?? '',
    );
    final memoController = useTextEditingController(text: receipt?.memo ?? '');

    // 新規登録は写真必須。編集時は既存画像があるため未選択でも保存できる。
    final canSave = receipt != null || selectedPhoto.value != null;

    Future<void> pickImage(ImageSource source) async {
      final photo = await ImagePicker().pickImage(source: source);
      if (photo == null) {
        return;
      }
      selectedPhoto.value = photo;
    }

    void showImageSourceSheet() {
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
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('フォトライブラリから選択'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }

    Future<void> save() async {
      analytics.logEvent(
        name:
            receipt == null ? 'tap_save_new_receipt' : 'tap_save_edit_receipt',
        parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
      );
      final userID = currentUserID;
      if (userID == null) {
        return;
      }
      // 画像アップロード等の await 中にシートが閉じられても、pop はこのシート自身の
      // ルートに限定する（黒画面対策 #372 と同じ）。
      final navigator = Navigator.of(context);
      final sheetRoute = ModalRoute.of(context);
      isSaving.value = true;
      try {
        final amount = int.tryParse(amountController.text.trim());
        final memo = memoController.text.trim();

        if (receipt == null) {
          // 新規: receiptID を採番 → 画像アップロード → ドキュメント作成の順。
          // 画像アップロードに失敗した場合はドキュメントを作らないため孤児が残らない。
          final receiptID = ref
              .read(groupDatabaseProvider(groupID: groupID))
              .newReceiptReference(shoppingListID: shoppingListID)
              .id;
          final file = File(selectedPhoto.value!.path);
          final uploadedImageURL = await functions.uploadReceiptImage(
            groupID: groupID,
            shoppingListID: shoppingListID,
            receiptID: receiptID,
            mimeType: mimeType(file),
            base64Image: await base64CompressImage(file),
          );
          await ref.read(addReceiptProvider(groupID: groupID)).call(
                shoppingListID: shoppingListID,
                receiptID: receiptID,
                createUserID: userID,
                imageURL: uploadedImageURL,
                amount: amount,
                memo: memo.isEmpty ? null : memo,
              );
        } else {
          // 編集: 画像が差し替えられていればアップロードして URL を更新する。
          var nextImageURL = imageURL.value;
          if (selectedPhoto.value != null) {
            final file = File(selectedPhoto.value!.path);
            nextImageURL = await functions.uploadReceiptImage(
              groupID: groupID,
              shoppingListID: shoppingListID,
              receiptID: receipt!.id,
              mimeType: mimeType(file),
              base64Image: await base64CompressImage(file),
            );
          }
          await ref.read(updateReceiptProvider(groupID: groupID)).call(
                receipt: receipt!.copyWith(
                  imageURL: nextImageURL,
                  amount: amount,
                  memo: memo.isEmpty ? null : memo,
                ),
              );
        }

        popRouteSafely(navigator: navigator, route: sheetRoute);
      } catch (e) {
        // シート上の SnackBar は背後の Scaffold に隠れるため、前面トーストで通知する。
        showGlobalToast(e.toString(), title: null);
      } finally {
        if (context.mounted) {
          isSaving.value = false;
        }
      }
    }

    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              receipt == null ? 'レシートを追加' : 'レシート',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _ReceiptImageField(
              selectedPhoto: selectedPhoto.value,
              imageURL: imageURL.value,
              onTapChange: showImageSourceSheet,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '金額',
                prefixText: '¥ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: memoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'メモ',
                hintText: '店名や購入品などのメモ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: (!canSave || isSaving.value) ? null : save,
              child: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

/// レシート画像のプレビュー / 選択フィールド。
class _ReceiptImageField extends StatelessWidget {
  final XFile? selectedPhoto;
  final String? imageURL;
  final VoidCallback onTapChange;

  const _ReceiptImageField({
    required this.selectedPhoto,
    required this.imageURL,
    required this.onTapChange,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPhoto != null) {
      return _preview(
        context,
        Image.file(
          File(selectedPhoto!.path),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }
    if (imageURL != null) {
      return _preview(
        context,
        CachedNetworkImage(
          imageUrl: imageURL!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const SizedBox(
            height: 220,
            child: Center(child: Icon(Icons.broken_image, size: 48)),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTapChange,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('レシートを撮影 / 選択'),
      ),
    );
  }

  Widget _preview(BuildContext context, Widget child) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onTapChange,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.8),
              ),
              child: const Icon(Icons.edit, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
