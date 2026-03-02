import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

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
    final descriptionController = useTextEditingController(
      text: textShoppingListItem.description ?? '',
    );
    final selectedColor = useState<String?>(textShoppingListItem.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(textShoppingListItem.message),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: 32.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // メモセクション
                  const Text(
                    'メモ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                  // カラーセクション
                  const Text(
                    'カラー',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      // 色なしボタン
                      GestureDetector(
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
                                  ? Colors.black
                                  : Colors.grey,
                              width: selectedColor.value == null ? 2 : 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.block,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // プリセットカラー
                      for (final preset in _presetColors)
                        GestureDetector(
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
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: selectedColor.value == preset.hex
                                ? const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  analytics.logEvent(name: 'tap_save_item_detail', parameters: {
                    'groupID': groupID,
                    'itemID': textShoppingListItem.id
                  });
                  final description = descriptionController.text.trim();
                  final docRef = ref
                      .read(groupDatabaseProvider(groupID: groupID))
                      .shoppingListItemsReference(
                        shoppingListID: textShoppingListItem.shoppingListID,
                      )
                      .doc(textShoppingListItem.id);

                  docRef.set(
                    textShoppingListItem.copyWith(
                      description: description.isEmpty ? null : description,
                      color: selectedColor.value,
                    ),
                    SetOptions(merge: true),
                  );

                  Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
