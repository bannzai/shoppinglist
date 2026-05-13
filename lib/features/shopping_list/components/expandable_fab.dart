import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// `ShoppingListPage` の右下に配置する展開式 FAB。
/// `design_handoff_shopping_list/source/screens-list.jsx#FAB` 相当。
///
/// 閉時: accent の plus 56×56 円。タップで 4 メニューが上に展開する。
/// メニュー: 写真から追加 / URL から追加 / テキスト貼り付け / 空行を追加。
/// 写真と URL は AI を使うため、ラベルに小さな「AI」バッジを表示する。
class ExpandableFab extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const ExpandableFab({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final open = useState(false);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
    final curve = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
      [controller],
    );

    useEffect(() {
      if (open.value) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [open.value]);

    void close() => open.value = false;

    final actions = <_FabAction>[
      _FabAction(
        icon: Icons.photo_camera_outlined,
        label: '写真から追加',
        ai: true,
        onTap: () {
          close();
          _showImagePicker(context, ref);
        },
      ),
      _FabAction(
        icon: Icons.link,
        label: 'URL から追加',
        ai: true,
        onTap: () {
          close();
          _showURLInputDialog(context, ref);
        },
      ),
      _FabAction(
        icon: Icons.content_paste_go_outlined,
        label: 'テキスト貼り付け',
        onTap: () {
          close();
          _pasteFromClipboard(context, ref);
        },
      ),
      _FabAction(
        icon: Icons.add,
        label: '空行を追加',
        primary: true,
        onTap: () {
          close();
          analytics.logEvent(name: 'tap_add_item_fab', parameters: {
            'groupID': groupID,
            'shoppingListID': shoppingListID,
          });
          ref.read(addShoppingListItemProvider(groupID: groupID)).call(
                shoppingListID: shoppingListID,
                userID: ref.read(currentUserIDProvider)!,
                message: '',
                order: shoppingListItems.nextOrder,
                description: null,
                color: null,
              );
        },
      ),
    ];

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (open.value)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
            ),
          ),
        for (final (i, action) in actions.indexed)
          _ActionRow(
            action: action,
            animation: curve,
            offset: (actions.length - i) * 60.0,
          ),
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) => Transform.rotate(
            angle: controller.value * 0.785,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.accent,
                // 仕様: accent 影 (alpha 0.35) と内側ハイライト (Flutter で再現可な範囲)。
                boxShadow: [
                  BoxShadow(
                    color: tokens.accent.withValues(alpha: 0.35),
                    offset: const Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    analytics.logEvent(name: 'tap_toggle_fab', parameters: {
                      'groupID': groupID,
                      'shoppingListID': shoppingListID,
                      'open': (!open.value).toString(),
                    });
                    open.value = !open.value;
                  },
                  child: const Center(
                    child: Icon(Icons.add, size: 26, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePicker(BuildContext context, WidgetRef ref) {
    analytics.logEvent(name: 'tap_open_image_picker', parameters: {
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });
    final isPremium =
        ref.read(customerInfoProvider).asData?.value.isPremium ?? false;
    final remaining =
        ref.read(remainingImageRecognitionCountProvider(isPremium: isPremium));
    if (remaining <= 0) {
      final limit = isPremium
          ? premiumMonthlyImageRecognitionLimit
          : freeMonthlyImageRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'AI画像認識の月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyImageRecognitionLimit回まで利用できます'}'),
          action: isPremium
              ? null
              : SnackBarAction(
                  label: 'アップグレード',
                  onPressed: () => showPaywall(context: context),
                ),
        ),
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
                        'shoppingListID': shoppingListID,
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
                        'shoppingListID': shoppingListID,
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
                  'shoppingListID': shoppingListID,
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
    ref.read(aIProcessingProvider.notifier).start(AIProcessingType.image);
    try {
      final file = File(photo.path);
      final base64Image = await base64CompressImage(file);
      final rawItems = await functions.generateShoppingListItemsFromImage(
        mimeType: mimeType(file),
        base64Image: base64Image,
      );
      final distinct = rawItems.toSet().toList();
      for (var (i, e) in distinct.indexed) {
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
    } finally {
      ref.read(aIProcessingProvider.notifier).end();
    }
  }

  void _showURLInputDialog(BuildContext context, WidgetRef ref) {
    analytics.logEvent(name: 'tap_open_url_input', parameters: {
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });
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
              'URL読み取りの月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyURLRecognitionLimit回まで利用できます'}'),
          action: isPremium
              ? null
              : SnackBarAction(
                  label: 'アップグレード',
                  onPressed: () => showPaywall(context: context),
                ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => _URLInputDialog(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListItems: shoppingListItems,
      ),
    );
  }

  Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
    analytics.logEvent(name: 'tap_paste_multiline', parameters: {
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null) return;
    final lines = text.split('\n').toSet();
    for (final (index, line) in lines.indexed) {
      if (line.trim().isEmpty) continue;
      if (shoppingListItems.any((item) => item.message == line)) continue;
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

class _FabAction {
  final IconData icon;
  final String label;
  final bool ai;
  final bool primary;
  final VoidCallback onTap;
  _FabAction({
    required this.icon,
    required this.label,
    this.ai = false,
    this.primary = false,
    required this.onTap,
  });
}

class _ActionRow extends StatelessWidget {
  final _FabAction action;
  final Animation<double> animation;
  final double offset;

  const _ActionRow({
    required this.action,
    required this.animation,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final translateY = -offset * animation.value;
        return Transform.translate(
          offset: Offset(0, translateY),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: IgnorePointer(
              ignoring: animation.value < 0.5,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ActionLabel(label: action.label, ai: action.ai),
            const SizedBox(width: 10),
            Container(
              width: action.primary ? 56 : 44,
              height: action.primary ? 56 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // 仕様: 副ボタンは surface（surface2 ではない）+ 1px divider border + 影。
                color: action.primary ? tokens.accent : tokens.neutral.surface,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F1B1813),
                    offset: Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: action.primary
                    ? const CircleBorder()
                    : CircleBorder(
                        side: BorderSide(color: tokens.neutral.divider)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: action.onTap,
                  child: Center(
                    child: Icon(
                      action.icon,
                      // 仕様: 副ボタンのアイコンは 18px。
                      size: action.primary ? 24 : 18,
                      color: action.primary ? Colors.white : tokens.neutral.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final String label;
  final bool ai;
  const _ActionLabel({required this.label, required this.ai});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.neutral.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.neutral.surface,
            ),
          ),
          if (ai) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: tokens.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// URL を入力して AI で買い物リストアイテムを生成するダイアログ。
/// 旧 `ShoppingListAppBar._URLInputDialog` を移植したもの。
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
                    'shoppingListID': shoppingListID,
                  });
                  Navigator.pop(context);
                },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: isLoading.value
              ? null
              : () async {
                  analytics.logEvent(name: 'tap_submit_url', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  });
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
                  isLoading.value = true;
                  ref
                      .read(aIProcessingProvider.notifier)
                      .start(AIProcessingType.url);
                  try {
                    final rawItems =
                        await functions.generateShoppingListItemsFromURL(
                      url: normalizedURL,
                    );
                    final distinct = rawItems.toSet().toList();
                    for (var (i, e) in distinct.indexed) {
                      final item = e.trim();
                      if (item.isEmpty || item.length > 100) continue;
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
                    ref.read(aIProcessingProvider.notifier).end();
                  }
                },
          child: const Text('生成'),
        ),
      ],
    );
  }
}
