import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';

class MemoRows extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;
  final AsyncValue<List<MemoRow>> memoRowsAsync;

  const MemoRows({
    super.key,
    required this.memoID,
    required this.memoRows,
    required this.memoRowsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoRows = useState(this.memoRows);

    useEffect(() {
      memoRows.value = memoRowsAsync.asData?.value ?? [];
      return null;
    }, [memoRowsAsync]);

    return Column(
      children: [
        Expanded(
          child: ReorderableList(
            onReorder: (oldIndex, newIndex) {
              // NOTE: ドラッグ時にリストから要素を一時的に削除するため、newIndex が1つずれるのを調整。
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              debugPrint('oldIndex: $oldIndex, newIndex: $newIndex');

              final changedMemoRows = [...memoRows.value];
              final movedItem = changedMemoRows.removeAt(oldIndex);
              changedMemoRows.insert(newIndex, movedItem);

              // 更新したリストに基づき order を再計算
              final orderedMemoRows = changedMemoRows.asMap().entries.map((entry) => entry.value.copyWith(order: entry.key)).toList();

              memoRows.value = [...orderedMemoRows];

              ref.read(memoRowBatchUpdateProvider).call(
                    memoID: memoID,
                    memoRows: orderedMemoRows,
                  );
            },
            itemCount: memoRows.value.length,
            itemBuilder: (context, index) {
              final memoRow = memoRows.value[index];

              return switch (memoRow) {
                TextMemoRow textMemoRow => TextMemo(key: ValueKey(memoRow.id), textMemoRow: textMemoRow, memoRows: memoRows.value),
                LinkMemoRow linkMemoRow => LinkMemo(key: ValueKey(memoRow.id), linkMemoRow: linkMemoRow, memoRows: memoRows.value),
              };
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(addTextMemoRowProvider).call(
                              memoID: memoID,
                              message: '',
                              order: memoRows.value.nextOrder,
                            );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
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
                                          final file = File(photo.path);
                                          final base64Image = await base64CompressImage(file);
                                          final memoRawRows = await functions.generateMemoRowsFromImage(
                                            mimeType: mimeType(file),
                                            base64Image: base64Image,
                                          );
                                          debugPrint('memoRawRows: $memoRawRows');

                                          for (var (i, e) in memoRawRows.indexed) {
                                            try {
                                              await ref.read(addTextMemoRowProvider).call(
                                                    memoID: memoID,
                                                    message: e,
                                                    order: memoRows.value.nextOrder + i,
                                                  );
                                            } catch (e) {
                                              // エラーが発生しても次の凍レーションを継続する
                                              debugPrint('Error: $e');
                                            }
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
                                          final file = File(photo.path);
                                          final base64Image = await base64CompressImage(file);
                                          final memoRawRows = await functions.generateMemoRowsFromImage(
                                            mimeType: mimeType(file),
                                            base64Image: base64Image,
                                          );
                                          debugPrint('memoRawRows: $memoRawRows');

                                          for (var (i, e) in memoRawRows.indexed) {
                                            try {
                                              await ref.read(addTextMemoRowProvider).call(
                                                    memoID: memoID,
                                                    message: e,
                                                    order: memoRows.value.nextOrder + i,
                                                  );
                                            } catch (e) {
                                              // エラーが発生しても次の凍レーションを継続する
                                              debugPrint('Error: $e');
                                            }
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
