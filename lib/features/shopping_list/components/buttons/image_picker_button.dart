import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class ImagePickerButton extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const ImagePickerButton(
      {super.key,
      required this.groupID,
      required this.shoppingListID,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        analytics.logEvent(
            name: 'tap_open_image_picker',
            parameters: {'groupID': groupID, 'shoppingListID': shoppingListID});
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
                        analytics.logEvent(
                            name: 'tap_image_picker_camera',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID
                            });
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
                        analytics.logEvent(
                            name: 'tap_image_picker_gallery',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID
                            });
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
                      analytics.logEvent(
                          name: 'cancel_image_picker',
                          parameters: {
                            'groupID': groupID,
                            'shoppingListID': shoppingListID
                          });
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
      XFile photo, List<GroupShoppingListItem> shoppingListItems) async {
    final file = File(photo.path);
    final base64Image = await base64CompressImage(file);
    final rawItems = await functions.generateShoppingListItemsFromImage(
      mimeType: mimeType(file),
      base64Image: base64Image,
    );
    debugPrint('rawItems: $rawItems');

    final distincted = rawItems.toSet().toList();

    for (var (i, e) in distincted.indexed) {
      if (shoppingListItems.any(
          (item) => item is TextGroupShoppingListItem && item.message == e)) {
        continue;
      }

      try {
        await ref.read(addTextShoppingListItemProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              message: e,
              order: shoppingListItems.nextOrder + i,
              groupShoppingListItemCategoryID: null,
              description: null,
              color: null,
            );
      } catch (e) {
        // エラーが発生しても次の凍レーションを継続する
        debugPrint('Error: $e');
      }
    }
  }
}
