import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';

class ImagePickerButton extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;

  const ImagePickerButton({super.key, required this.memoID, required this.memoRows});

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
                        final XFile? photo = await imagePicker.pickImage(source: ImageSource.camera);

                        if (photo != null) {
                          if (context.mounted) {
                            await _addMemoRows(context, ref, photo, memoRows);
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
                        final XFile? photo = await imagePicker.pickImage(source: ImageSource.gallery);
                        if (photo != null) {
                          if (context.mounted) {
                            await _addMemoRows(context, ref, photo, memoRows);
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

  Future<void> _addMemoRows(BuildContext context, WidgetRef ref, XFile photo, List<MemoRow> memoRows) async {
    final file = File(photo.path);
    final base64Image = await base64CompressImage(file);
    final memoRawRows = await functions.generateMemoRowsFromImage(
      mimeType: mimeType(file),
      base64Image: base64Image,
    );
    debugPrint('memoRawRows: $memoRawRows');

    final distincted = memoRawRows.toSet().toList();

    for (var (i, e) in distincted.indexed) {
      if (memoRows.any((memoRow) => memoRow is TextMemoRow && memoRow.message == e)) {
        continue;
      }

      try {
        await ref.read(addTextMemoRowProvider).call(
              memoID: memoID,
              message: e,
              order: memoRows.nextOrder + i,
            );
      } catch (e) {
        // エラーが発生しても次の凍レーションを継続する
        debugPrint('Error: $e');
      }
    }
  }
}
