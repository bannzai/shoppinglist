import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/features/shopping_list/utils/export_text_formatter.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class ShoppingListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingList> shoppingLists;
  final GroupShoppingList? shoppingList;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> sortByCategory;
  final List<GroupShoppingListItem> shoppingListItems;
  final void Function(String newID) onShoppingListIDChanged;
  const ShoppingListAppBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLists,
    required this.shoppingList,
    required this.showChecked,
    required this.sortByCategory,
    required this.shoppingListItems,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = this.shoppingList;
    final shoppingListDelete =
        ref.watch(shoppingListDeleteProvider(groupID: groupID));
    final axesAsync = ref.watch(groupCategoryAxesProvider(groupID: groupID));
    final hasCategories = axesAsync.maybeWhen(
        data: (axes) => axes.isNotEmpty, orElse: () => false);
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final remainingImageRecognitionCount =
        ref.watch(remainingImageRecognitionCountProvider(isPremium: isPremium));
    return AppBar(
      title: DropdownButton<String>(
        value: shoppingListID,
        underline: const SizedBox.shrink(),
        dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
        style: Theme.of(context).textTheme.titleLarge,
        items: shoppingLists
            .map((sl) => DropdownMenuItem(
                  value: sl.id,
                  child: Text(sl.name),
                ))
            .toList(),
        onChanged: (newID) {
          if (newID != null) {
            analytics.logEvent(name: 'tap_confirm_list_picker', parameters: {
              'groupID': groupID,
              'selectedShoppingListID': newID,
            });
            onShoppingListIDChanged(newID);
          }
        },
      ),
      actions: [
        if (shoppingList != null) ...[
          IconButton(
            tooltip: 'リスト設定',
            onPressed: () {
              analytics.logEvent(name: 'tap_open_list_setting', parameters: {
                'groupID': groupID,
                'shoppingListID': shoppingListID
              });
              FocusScope.of(context).unfocus();
              appShowModalBottomSheet(
                context: context,
                builder: (context) {
                  return ShoppingListSettingPage(
                    groupID: groupID,
                    shoppingListID: shoppingListID,
                    shoppingList: shoppingList,
                    onDelete: () {
                      shoppingListDelete(shoppingListID: shoppingListID);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.settings),
          ),
          PopupMenuButton<String>(
            tooltip: 'メニュー',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'add_list':
                  analytics.logEvent(
                      name: 'tap_open_add_list_sheet',
                      parameters: {'groupID': groupID});
                  FocusScope.of(context).unfocus();
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return _AddShoppingListBottomSheet(
                        groupID: groupID,
                        shoppingList: shoppingList,
                        shoppingListID: shoppingListID,
                        shoppingListItems: shoppingListItems,
                        onShoppingListIDChanged: onShoppingListIDChanged,
                      );
                    },
                  );
                  break;
                case 'image':
                  _showImagePicker(context, ref,
                      isPremium: isPremium,
                      remainingImageRecognitionCount:
                          remainingImageRecognitionCount);
                  break;
                case 'url':
                  _showURLInputDialog(context, ref);
                  break;
                case 'paste':
                  _pasteFromClipboard(context, ref);
                  break;
                case 'export':
                  _exportShoppingList(context: context, ref: ref);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'add_list',
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('買い物リストを追加'),
                ),
              ),
              PopupMenuItem(
                value: 'image',
                child: ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('画像から追加'),
                ),
              ),
              PopupMenuItem(
                value: 'url',
                child: ListTile(
                  leading: Icon(Icons.link),
                  title: Text('URLから追加'),
                ),
              ),
              PopupMenuItem(
                value: 'paste',
                child: ListTile(
                  leading: Icon(Icons.content_paste_go),
                  title: Text('テキスト貼り付け'),
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.ios_share),
                  title: Text('リストをエクスポート'),
                ),
              ),
            ],
          ),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                avatar: const Icon(Icons.check, size: 18),
                showCheckmark: false,
                label: const Text('チェック済み表示'),
                selected: showChecked.value,
                onSelected: (value) {
                  analytics.logEvent(name: 'toggle_show_checked', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                    'value': value.toString()
                  });
                  showChecked.value = value;
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(Icons.check, size: 18),
                showCheckmark: false,
                label: const Text('カテゴリ順'),
                selected: sortByCategory.value,
                onSelected: hasCategories
                    ? (value) {
                        analytics.logEvent(
                            name: 'toggle_sort_by_category',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID': shoppingListID,
                              'value': value.toString()
                            });
                        sortByCategory.value = value;
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, WidgetRef ref,
      {required bool isPremium, required int remainingImageRecognitionCount}) {
    analytics.logEvent(
        name: 'tap_open_image_picker',
        parameters: {'groupID': groupID, 'shoppingListID': shoppingListID});

    // AI画像認識の回数制限チェック
    if (remainingImageRecognitionCount <= 0) {
      final limit = isPremium
          ? premiumMonthlyImageRecognitionLimit
          : freeMonthlyImageRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'AI画像認識の月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyImageRecognitionLimit回まで利用できます'}')),
      );
      return;
    }

    final imagePicker = ImagePicker();

    showDialog(
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
                  final XFile? photo =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    if (context.mounted) {
                      await _addShoppingListItemsFromImage(context, ref, photo);
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
                  final XFile? photo =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  if (photo != null) {
                    if (context.mounted) {
                      await _addShoppingListItemsFromImage(context, ref, photo);
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
                analytics.logEvent(name: 'cancel_image_picker', parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID
                });
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addShoppingListItemsFromImage(
      BuildContext context, WidgetRef ref, XFile photo) async {
    final file = File(photo.path);
    final base64Image = await base64CompressImage(file);
    final rawItems = await functions.generateShoppingListItemsFromImage(
      mimeType: mimeType(file),
      base64Image: base64Image,
    );
    debugPrint('rawItems: $rawItems');

    final distincted = rawItems.toSet().toList();

    for (var (i, e) in distincted.indexed) {
      if (shoppingListItems.any((item) => item.message == e)) {
        continue;
      }

      try {
        await ref.read(addShoppingListItemProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              userID: ref.read(currentUserIDProvider)!,
              message: e,
              order: shoppingListItems.nextOrder + i,
              description: null,
              color: null,
            );
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  void _showURLInputDialog(BuildContext context, WidgetRef ref) {
    analytics.logEvent(
        name: 'tap_open_url_input',
        parameters: {'groupID': groupID, 'shoppingListID': shoppingListID});

    final isPremium =
        ref.read(customerInfoProvider).asData?.value.isPremium ?? false;
    final remaining =
        ref.read(remainingURLRecognitionCountProvider(isPremium: isPremium));
    if (remaining <= 0) {
      final limit = isPremium
          ? premiumMonthlyURLRecognitionLimit
          : freeMonthlyURLRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'URL読み取りの月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyURLRecognitionLimit回まで利用できます'}')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return _URLInputDialog(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingListItems: shoppingListItems,
        );
      },
    );
  }

  Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
    analytics.logEvent(
        name: 'tap_paste_multiline',
        parameters: {'groupID': groupID, 'shoppingListID': shoppingListID});
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null) {
      final lines = text.split('\n').toSet();
      for (final (index, line) in lines.indexed) {
        if (shoppingListItems.any((item) => item.message == line)) {
          continue;
        }
        await ref.read(addShoppingListItemProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              userID: ref.read(currentUserIDProvider)!,
              message: line,
              order: shoppingListItems.nextOrder + index,
              description: null,
              color: null,
            );
      }
    }
  }

  /// 買い物リストをテキスト形式でOS標準の共有シートに送信する。
  Future<void> _exportShoppingList({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    // ユーザー操作ごとに共有シート表示と分析送信を行うため、この処理は非冪等。
    final isPremium =
        ref.read(customerInfoProvider).asData?.value.isPremium ?? false;
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('リストのエクスポートはプレミアム機能です。プレミアムにアップグレードすると利用できます')),
      );
      return;
    }

    analytics.logEvent(name: 'tap_export_shopping_list', parameters: {
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });

    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) {
        throw StateError('共有シートの表示位置を取得できませんでした');
      }

      await SharePlus.instance.share(
        ShareParams(
          text: buildShoppingListExportText(
            shoppingListName: shoppingList?.name ?? '',
            shoppingListItems: shoppingListItems,
          ),
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}

class _AddShoppingListBottomSheet extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingList shoppingList;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  final void Function(String newID) onShoppingListIDChanged;

  const _AddShoppingListBottomSheet({
    required this.groupID,
    required this.shoppingList,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.onShoppingListIDChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final groups = userGroupsAsync.asData?.value ?? [];
    final selectedGroupID = useState(groupID);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (groups.length > 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                initialValue: selectedGroupID.value,
                decoration: const InputDecoration(
                  labelText: 'グループ',
                  border: OutlineInputBorder(),
                ),
                items: groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.name ?? 'グループ'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedGroupID.value = value;
                  }
                },
              ),
            ),
          ],
          ListTile(
            title: const Text('買い物リストを追加'),
            onTap: () async {
              analytics.logEvent(name: 'tap_create_new_list', parameters: {
                'groupID': groupID,
                'selectedGroupID': selectedGroupID.value
              });
              try {
                final newShoppingList = await ref
                    .read(
                        shoppingListAddProvider(groupID: selectedGroupID.value))
                    .call(
                      createUserID: shoppingList.createUserID,
                      groupID: selectedGroupID.value,
                      shoppingLocationID: null,
                      duplicatedFromGroupShoppingListID: null,
                    );
                if (selectedGroupID.value == groupID) {
                  onShoppingListIDChanged(newShoppingList.id);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } on ShoppingListLimitExceededException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                  Navigator.pop(context);
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('買い物リストの作成に失敗しました')),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('現在の買い物リストを複製'),
            onTap: () async {
              analytics.logEvent(name: 'tap_duplicate_list', parameters: {
                'groupID': groupID,
                'selectedGroupID': selectedGroupID.value,
                'sourceShoppingListID': shoppingList.id
              });
              try {
                final newShoppingList = await ref
                    .read(shoppingListDuplicateProvider(
                        groupID: selectedGroupID.value))
                    .call(
                      createUserID: shoppingList.createUserID,
                      groupID: selectedGroupID.value,
                      sourceShoppingList: shoppingList,
                      shoppingListItems: shoppingListItems,
                    );
                if (selectedGroupID.value == groupID) {
                  onShoppingListIDChanged(newShoppingList.id);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } on ShoppingListLimitExceededException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                  Navigator.pop(context);
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('買い物リストの複製に失敗しました')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// URLを入力してAIで買い物リストアイテムを生成するダイアログ。
class _URLInputDialog extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const _URLInputDialog({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlController = useTextEditingController();
    final isLoading = useState(false);

    return AlertDialog(
      title: const Text('URLから買い物リストを生成'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: urlController,
            keyboardType: TextInputType.url,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'https://example.com/recipe',
              labelText: 'URL',
            ),
            enabled: !isLoading.value,
          ),
          if (isLoading.value) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value
              ? null
              : () {
                  analytics.logEvent(name: 'cancel_url_input', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID
                  });
                  Navigator.pop(context);
                },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: isLoading.value
              ? null
              : () async {
                  final normalizedURL = urlController.text.trim();
                  if (normalizedURL.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URLを入力してください')),
                    );
                    return;
                  }
                  final parsedURL = Uri.tryParse(normalizedURL);
                  if (parsedURL == null ||
                      parsedURL.scheme != 'https' ||
                      parsedURL.host.isEmpty ||
                      parsedURL.userInfo.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('有効なHTTPS URLを入力してください')),
                    );
                    return;
                  }
                  analytics.logEvent(name: 'tap_submit_url', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  });
                  isLoading.value = true;
                  try {
                    final rawItems =
                        await functions.generateShoppingListItemsFromURL(
                      url: normalizedURL,
                    );
                    final distincted = rawItems.toSet().toList();
                    for (var (i, e) in distincted.indexed) {
                      final item = e.trim();
                      if (item.isEmpty || item.length > 100) {
                        continue;
                      }
                      if (shoppingListItems
                          .any((existing) => existing.message == item)) {
                        continue;
                      }
                      try {
                        await ref
                            .read(addShoppingListItemProvider(groupID: groupID))
                            .call(
                              shoppingListID: shoppingListID,
                              userID: ref.read(currentUserIDProvider)!,
                              message: item,
                              order: shoppingListItems.nextOrder + i,
                              description: null,
                              color: null,
                            );
                      } catch (e) {
                        debugPrint('Error: $e');
                      }
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  } finally {
                    if (context.mounted) {
                      isLoading.value = false;
                    }
                  }
                },
          child: const Text('生成'),
        ),
      ],
    );
  }
}
