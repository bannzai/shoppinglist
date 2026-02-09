import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';

class ImagePickerButton extends HookConsumerWidget {
  final String shoppingListID;
  final List<ShoppingListItem> shoppingListItems;

  const ImagePickerButton(
      {super.key,
      required this.shoppingListID,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        final imagePicker = ImagePicker();

        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('カメラ'),
                      leading: const Icon(Icons.photo_camera),
                      onTap: () async {
                        final XFile? photo = await imagePicker.pickImage(
                            source: ImageSource.camera);

                        if (photo != null) {
                          if (context.mounted) {
                            await _addShoppingListItems(
                                context, ref, photo, shoppingListItems);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('フォトライブラリ'),
                      leading: const Icon(Icons.photo_album),
                      onTap: () async {
                        final XFile? photo = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (photo != null) {
                          if (context.mounted) {
                            await _addShoppingListItems(
                                context, ref, photo, shoppingListItems);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('閉じる'),
                  ),
                ],
              );
            });
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Icon(Icons.photo),
      ),
    );
  }

  Future<void> _addShoppingListItems(BuildContext context, WidgetRef ref,
      XFile photo, List<ShoppingListItem> shoppingListItems) async {
    final file = File(photo.path);
    final base64Image = await base64CompressImage(file);
    final rawItems = await functions.generateShoppingListItemsFromImage(
      mimeType: mimeType(file),
      base64Image: base64Image,
    );
    debugPrint('rawItems: $rawItems');

    final distincted = rawItems.toSet().toList();

    for (var (i, e) in distincted.indexed) {
      if (shoppingListItems.any((item) =>
          item is TextShoppingListItem && item.message == e)) {
        continue;
      }

      try {
        await ref.read(addTextShoppingListItemProvider).call(
              shoppingListID: shoppingListID,
              message: e,
              order: shoppingListItems.nextOrder + i,
            );
      } catch (e) {
        // エラーが発生しても次の凍レーションを継続する
        debugPrint('Error: $e');
      }
    }
  }
}
