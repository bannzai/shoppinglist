import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_review_sheet.dart';
import 'package:shoppinglist/features/shopping_list/components/fab_action_menu.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/stdlib/navigator.dart';

/// `ShoppingListPage` の右下に配置する展開式 FAB。
/// `design_handoff_shopping_list/source/screens-list.jsx#FAB` 相当。
///
/// 閉時: accent の add_task（アイテム追加）56×56 円。リスト作成の `CreateListFab` と
/// 縦に並べるダブル FAB 構成のメイン側。
/// タップ: 1行追加 / 写真 / URL / テキスト貼り付け のメニューを上方向に展開する。
/// 長押し: 反応しない。
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
    final tokens = context.appTheme;
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    // AI 処理中（実行中バナー表示中）は写真/URL からの抽出を多重起動させない。
    // 画像/URL/カテゴリ分けはどれも同じ aIProcessingProvider・同じバナーを共有するため、
    // いずれかが実行中なら写真/URL アクションを無効化する。
    final isAIProcessing = ref.watch(aIProcessingProvider) != null;
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

    final actions = <FabMenuAction>[
      FabMenuAction(
        icon: Icons.photo_camera_outlined,
        label: '写真から追加',
        // AI 処理中は無効化（dim 表示・タップ不可）。
        onTap: isAIProcessing
            ? null
            : () {
                close();
                _showImagePicker(context, ref, isPremium);
              },
      ),
      FabMenuAction(
        icon: Icons.link,
        label: 'URL から追加',
        // AI 処理中は無効化（dim 表示・タップ不可）。
        onTap: isAIProcessing
            ? null
            : () {
                close();
                _showURLInputDialog(context, ref, isPremium);
              },
      ),
      FabMenuAction(
        icon: Icons.content_paste_go_outlined,
        label: 'テキスト貼り付け',
        // テキスト貼り付けは AI 処理（バナー）を使わないため常に有効。
        onTap: () {
          close();
          _pasteFromClipboard(context, ref);
        },
      ),
      FabMenuAction(
        icon: Icons.add,
        label: '1行追加',
        // 空行を直接追加する最頻操作。AI 処理を使わないため常に有効。
        onTap: () {
          analytics.logEvent(name: 'tap_add_item_fab', parameters: {
            'groupID': groupID,
            'shoppingListID': shoppingListID,
          });
          close();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 展開メニュー。FAB の上に積み、open に応じて下端基準で上方向へ伸縮する。
        FabActionMenu(animation: curve, actions: actions),
        // 長押しは無反応にする。FloatingActionButton(InkWell) は onLongPress 未設定だと
        // 「長押し→指離し」がタップに退化してメニューが開いてしまうため、GestureDetector の
        // 空 onLongPress でジェスチャーアリーナの長押しを勝たせて握りつぶす。
        // タップ（FAB の onPressed）だけがメニュー開閉に効くようにする。
        GestureDetector(
          onLongPress: () {},
          child: FloatingActionButton(
            backgroundColor: tokens.accent,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            // タップでメニューを開閉する。
            onPressed: () {
              // メニュー展開中（x 状態）のタップは閉じるに倒す。
              if (open.value) {
                analytics.logEvent(name: 'tap_close_fab_menu', parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                });
                close();
                return;
              }
              analytics.logEvent(name: 'tap_open_fab_menu', parameters: {
                'groupID': groupID,
                'shoppingListID': shoppingListID,
              });
              open.value = true;
            },
            // 閉時は add_task（アイテム追加）、メニュー展開中は x（閉じる）。
            // AnimatedSwitcher の回転+フェードでアイコン自体を入れ替える。
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween(begin: 0.85, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                open.value ? Icons.close : Icons.add_task,
                key: ValueKey(open.value),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePicker(BuildContext context, WidgetRef ref, bool isPremium) {
    analytics.logEvent(name: 'tap_open_image_picker', parameters: {
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });
    final remaining =
        ref.read(remainingImageRecognitionCountProvider(isPremium: isPremium));
    if (remaining <= 0) {
      final limit = isPremium
          ? premiumMonthlyImageRecognitionLimit
          : freeMonthlyImageRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
              '画像読み取りの月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyImageRecognitionLimit回まで利用できます'}'),
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
      builder: (dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('カメラ'),
                leading: const Icon(Icons.photo_camera),
                onTap: () async {
                  analytics
                      .logEvent(name: 'tap_image_picker_camera', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  });
                  final XFile? photo =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  if (photo == null) {
                    return;
                  }
                  // 写真選択直後に画像選択ダイアログを閉じる。
                  // AI 処理・review sheet は親 context で行う（URL 入力側と統一）。
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    await _addShoppingListItemsFromImage(context, ref, photo);
                  }
                },
              ),
              ListTile(
                title: const Text('フォトライブラリ'),
                leading: const Icon(Icons.photo_album),
                onTap: () async {
                  analytics
                      .logEvent(name: 'tap_image_picker_gallery', parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  });
                  final XFile? photo =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  if (photo == null) {
                    return;
                  }
                  // 写真選択直後に画像選択ダイアログを閉じる。
                  // AI 処理・review sheet は親 context で行う（URL 入力側と統一）。
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    await _addShoppingListItemsFromImage(context, ref, photo);
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
                Navigator.pop(dialogContext);
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
    List<String> rawItems;
    try {
      final file = File(photo.path);
      final base64Image = await base64CompressImage(file);
      rawItems = await functions.generateShoppingListItemsFromImage(
        mimeType: mimeType(file),
        base64Image: base64Image,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return;
    } finally {
      ref.read(aIProcessingProvider.notifier).end();
    }
    if (!context.mounted) {
      return;
    }
    // 既存アイテムに存在しない候補だけ review sheet にかける。
    // 候補が空（画像から読み取れなかった／すべて既存）でも review sheet を開き、
    // 「候補がありませんでした」を表示して画像が読み取れたか判断できるようにする。
    final candidates = rawItems
        .where((e) => !shoppingListItems.any((item) => item.message == e))
        .toList();
    final reviewed = await showAIReviewSheet(
      context: context,
      rawNames: candidates,
      source: 'image',
    );
    if (reviewed == null) {
      return;
    }
    final selected = reviewed.where((c) => c.selected).toList();
    for (var (i, c) in selected.indexed) {
      try {
        await ref.read(addShoppingListItemProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              userID: ref.read(currentUserIDProvider)!,
              message: c.name,
              order: shoppingListItems.nextOrder + i,
              description: null,
              color: null,
            );
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  void _showURLInputDialog(
      BuildContext context, WidgetRef ref, bool isPremium) {
    analytics.logEvent(name: 'tap_open_url_input', parameters: {
      'groupID': groupID,
      'shoppingListID': shoppingListID,
    });
    final remaining =
        ref.read(remainingURLRecognitionCountProvider(isPremium: isPremium));
    if (remaining <= 0) {
      final limit = isPremium
          ? premiumMonthlyURLRecognitionLimit
          : freeMonthlyURLRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          persist: false,
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
    if (text == null) {
      return;
    }
    final lines = text.split('\n').toSet();
    for (final (index, line) in lines.indexed) {
      if (line.trim().isEmpty) {
        continue;
      }
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
                  // ダイアログ上の SnackBar は背後の Scaffold に描画されて
                  // 見えないため、前面に出るグローバルトーストで通知する。
                  if (normalizedURL.isEmpty) {
                    showGlobalToast('URLを入力してください', title: null);
                    return;
                  }
                  final parsedURL = Uri.tryParse(normalizedURL);
                  if (parsedURL == null ||
                      parsedURL.scheme != 'https' ||
                      parsedURL.host.isEmpty ||
                      parsedURL.userInfo.isNotEmpty) {
                    showGlobalToast('有効なHTTPS URLを入力してください', title: null);
                    return;
                  }
                  // 生成の await 中にダイアログが先に閉じられると、遅延した pop が
                  // ホームまで剥がして黒画面になるため、pop は自ルートに限定する (#372)。
                  final navigator = Navigator.of(context);
                  final dialogRoute = ModalRoute.of(context);
                  isLoading.value = true;
                  ref
                      .read(aIProcessingProvider.notifier)
                      .start(AIProcessingType.url);
                  List<String> rawItems;
                  try {
                    rawItems = await functions.generateShoppingListItemsFromURL(
                      url: normalizedURL,
                    );
                  } catch (e) {
                    showGlobalToast(e.toString(), title: null);
                    return;
                  } finally {
                    if (context.mounted) {
                      isLoading.value = false;
                    }
                    ref.read(aIProcessingProvider.notifier).end();
                  }
                  if (!context.mounted) {
                    return;
                  }
                  // URL ダイアログを先に閉じてから review sheet を出す。
                  popRouteSafely(navigator: navigator, route: dialogRoute);
                  if (!context.mounted) {
                    return;
                  }
                  final candidates = rawItems
                      .where((e) => !shoppingListItems
                          .any((existing) => existing.message == e))
                      .toList();
                  if (candidates.isEmpty) {
                    return;
                  }
                  final reviewed = await showAIReviewSheet(
                    context: context,
                    rawNames: candidates,
                    source: 'url',
                  );
                  if (reviewed == null) {
                    return;
                  }
                  final selected = reviewed.where((c) => c.selected).toList();
                  for (var (i, c) in selected.indexed) {
                    try {
                      await ref
                          .read(addShoppingListItemProvider(groupID: groupID))
                          .call(
                            shoppingListID: shoppingListID,
                            userID: ref.read(currentUserIDProvider)!,
                            message: c.name,
                            order: shoppingListItems.nextOrder + i,
                            description: null,
                            color: null,
                          );
                    } catch (e) {
                      debugPrint('Error: $e');
                    }
                  }
                },
          child: const Text('生成'),
        ),
      ],
    );
  }
}
