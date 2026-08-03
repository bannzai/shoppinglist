import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_shopping_list_source_image.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_review_sheet.dart';
import 'package:shoppinglist/features/shopping_list/components/fab_action_menu.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_fab_menu.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/image/image.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/stdlib/navigator.dart';

/// `ShoppingListPage` の右下に配置する展開式 FAB。
/// `design_handoff_shopping_list/source/screens-list.jsx#FAB` 相当。
///
/// 閉時: accent の add_task（アイテム追加）56×56 円。
/// タップ: 空行を 1 件追加する（最頻操作をワンタップにする。Issue #462）。
/// 長押し: 写真 / URL / テキスト貼り付け のメニューを上方向に展開する。
/// リスト作成は上部バー(`ListTopBar`)の `CreateListMenuButton` が担う(Issue #461)。
/// キーボード表示中も隠さず表示し続け、タップ・長押しでキーボードを閉じる(Issue #498)。
class ExpandableFab extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  /// ソフトキーボード表示中か。page.dart が Scaffold の外側で viewInsets から判定して
  /// 渡す(Scaffold body 内では resizeToAvoidBottomInset により viewInsets が 0 に潰れる
  /// ため、この widget 内では自前判定できない)。表示中はタップ・長押しでキーボードを
  /// 閉じる(Issue #498)。
  final bool isKeyboardVisible;

  const ExpandableFab({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.isKeyboardVisible,
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
    // 状態 Provider は build 内で watch して変数として参照する（callback 内で read しない）。
    final currentUserID = ref.watch(currentUserIDProvider);
    // 開閉状態は `shoppingListFabMenuProvider` に一元化している。
    // スクロール開始等の外部イベントからも close されるため、widget ローカルでは持たない。
    final open = ref.watch(shoppingListFabMenuProvider);
    final addShoppingListItem = ref.watch(
      addShoppingListItemProvider(groupID: groupID),
    );
    final aiProcessingNotifier = ref.watch(aIProcessingProvider.notifier);
    final fabMenuNotifier = ref.watch(shoppingListFabMenuProvider.notifier);
    final remainingImageRecognition = ref.watch(
      remainingImageRecognitionCountProvider(isPremium: isPremium),
    );
    final remainingURLRecognition = ref.watch(
      remainingURLRecognitionCountProvider(isPremium: isPremium),
    );
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

    // 共有状態から導出した open の変化に合わせてアニメを駆動する。
    // 依存配列は open のみ — 開閉の変化イベントだけで forward/reverse を切り替える。
    useEffect(() {
      if (open) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [open]);

    void close() => fabMenuNotifier.close();

    final actions = <FabMenuAction>[
      FabMenuAction(
        icon: Icons.photo_camera_outlined,
        label: '写真から追加',
        // AI 処理中は無効化（dim 表示・タップ不可）。
        onTap:
            isAIProcessing
                ? null
                : () {
                  close();
                  _showImagePicker(
                    context,
                    isPremium: isPremium,
                    remainingImageRecognition: remainingImageRecognition,
                    aiProcessingNotifier: aiProcessingNotifier,
                    addShoppingListItem: addShoppingListItem,
                    currentUserID: currentUserID,
                  );
                },
      ),
      FabMenuAction(
        icon: Icons.link,
        label: 'URL から追加',
        // AI 処理中は無効化（dim 表示・タップ不可）。
        onTap:
            isAIProcessing
                ? null
                : () {
                  close();
                  _showURLInputDialog(
                    context,
                    isPremium: isPremium,
                    remainingURLRecognition: remainingURLRecognition,
                  );
                },
      ),
      FabMenuAction(
        icon: Icons.content_paste_go_outlined,
        label: 'テキスト貼り付け',
        // テキスト貼り付けは AI 処理（バナー）を使わないため常に有効。
        onTap: () {
          close();
          _pasteFromClipboard(
            context,
            addShoppingListItem: addShoppingListItem,
            currentUserID: currentUserID,
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
        // 長押しでメニューを開閉する。FloatingActionButton(InkWell) は onLongPress 未設定だと
        // 「長押し→指離し」がタップに退化して空行追加が走ってしまうため、GestureDetector の
        // onLongPress でジェスチャーアリーナの長押しを勝たせ、メニュー開閉に割り当てる。
        GestureDetector(
          onLongPress: () {
            // キーボード表示中の長押しはキーボードを閉じてからメニューを開閉する
            // (Issue #498)。入力途中テキストの確定保存・空の入力行の削除はフォーカス
            // 喪失を検知する行側の listener (text_shopping_list_item.dart) が担う。
            if (isKeyboardVisible) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
            // メニュー展開中（x 状態）の長押しは閉じるに倒す。
            if (open) {
              analytics.logEvent(
                name: 'long_press_close_fab_menu',
                parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                },
              );
              close();
              return;
            }
            analytics.logEvent(
              name: 'long_press_open_fab_menu',
              parameters: {
                'groupID': groupID,
                'shoppingListID': shoppingListID,
              },
            );
            fabMenuNotifier.open();
          },
          child: FloatingActionButton(
            backgroundColor: tokens.accent,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            // タップで空行を 1 件追加する。
            onPressed: () {
              // メニュー展開中（x 状態）のタップは追加せず閉じるに倒す。
              if (open) {
                analytics.logEvent(
                  name: 'tap_close_fab_menu',
                  parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  },
                );
                // メニュー展開中でも「キーボード表示中の FAB タップはキーボードを
                // 閉じる」(Issue #498)を保つ(メニュー表示中に入力行をタップして
                // キーボードが開き直っているケース)。
                if (isKeyboardVisible) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
                close();
                return;
              }
              // キーボード表示中のタップはキーボードを閉じる操作に割り当てる
              // (Issue #498)。空行を追加すると新規行の autofocus
              // (text_shopping_list_item.dart) でキーボードが開き直ってしまうため
              // 追加はしない。入力途中テキストの確定保存・空の入力行の削除は
              // フォーカス喪失を検知する行側の listener が担う。
              if (isKeyboardVisible) {
                analytics.logEvent(
                  name: 'tap_fab_close_keyboard',
                  parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  },
                );
                FocusManager.instance.primaryFocus?.unfocus();
                return;
              }
              analytics.logEvent(
                name: 'tap_add_item_fab',
                parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                },
              );
              addShoppingListItem.call(
                shoppingListID: shoppingListID,
                userID: currentUserID!,
                message: '',
                order: shoppingListItems.nextOrder,
                description: null,
                color: null,
              );
            },
            // 閉時は add_task（アイテム追加）、メニュー展開中は x（閉じる）。
            // AnimatedSwitcher の回転+フェードでアイコン自体を入れ替える。
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder:
                  (child, animation) => RotationTransition(
                    turns: Tween(begin: 0.85, end: 1.0).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
              child: Icon(
                open ? Icons.close : Icons.add_task,
                key: ValueKey(open),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePicker(
    BuildContext context, {
    required bool isPremium,
    required int remainingImageRecognition,
    required AIProcessing aiProcessingNotifier,
    required AddShoppingListItem addShoppingListItem,
    required String? currentUserID,
  }) {
    analytics.logEvent(
      name: 'tap_open_image_picker',
      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
    );
    if (remainingImageRecognition <= 0) {
      final limit =
          isPremium
              ? premiumMonthlyImageRecognitionLimit
              : freeMonthlyImageRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            '画像読み取りの月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyImageRecognitionLimit回まで利用できます'}',
          ),
          action:
              isPremium
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
                  analytics.logEvent(
                    name: 'tap_image_picker_camera',
                    parameters: {
                      'groupID': groupID,
                      'shoppingListID': shoppingListID,
                    },
                  );
                  final XFile? photo = await imagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo == null) {
                    return;
                  }
                  // 写真選択直後に画像選択ダイアログを閉じる。
                  // AI 処理・review sheet は親 context で行う（URL 入力側と統一）。
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    await _addShoppingListItemsFromImages(
                      context,
                      photos: [photo],
                      aiProcessingNotifier: aiProcessingNotifier,
                      addShoppingListItem: addShoppingListItem,
                      currentUserID: currentUserID,
                    );
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
                    },
                  );
                  // 手書きメモが複数枚に分かれているケースに対応するため複数選択を
                  // 許可する。上限は元画像の保存上限（5枚）に合わせる（Issue #530）。
                  final List<XFile> photos = await imagePicker.pickMultiImage(
                    limit: maxShoppingListSourceImageCount,
                  );
                  if (photos.isEmpty) {
                    return;
                  }
                  // 写真選択直後に画像選択ダイアログを閉じる。
                  // AI 処理・review sheet は親 context で行う（URL 入力側と統一）。
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    await _addShoppingListItemsFromImages(
                      context,
                      photos: photos,
                      aiProcessingNotifier: aiProcessingNotifier,
                      addShoppingListItem: addShoppingListItem,
                      currentUserID: currentUserID,
                    );
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
                    'shoppingListID': shoppingListID,
                  },
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addShoppingListItemsFromImages(
    BuildContext context, {
    required List<XFile> photos,
    required AIProcessing aiProcessingNotifier,
    required AddShoppingListItem addShoppingListItem,
    required String? currentUserID,
  }) async {
    aiProcessingNotifier.start(AIProcessingType.image);
    final rawItems = <String>[];
    Object? generationError;
    StackTrace? generationStackTrace;
    try {
      // pickMultiImage(limit:) はプラットフォームによって上限が効かないことが
      // あるため、元画像の保存上限（5枚）にクライアント側でも絞る。
      for (final photo in photos.take(maxShoppingListSourceImageCount)) {
        try {
          final file = File(photo.path);
          final base64Image = await base64CompressImage(file);
          // 生成に使った元画像はサーバー側で買い物リストに保存される（Issue #530）。
          rawItems.addAll(
            await functions.generateShoppingListItemsFromImage(
              mimeType: mimeType(file),
              base64Image: base64Image,
              groupID: groupID,
              shoppingListID: shoppingListID,
            ),
          );
        } catch (e, st) {
          // 月次利用回数の上限など、1枚目の失敗理由は残りの枚数でも解消しない
          // ことが多いため、以降の生成は打ち切って利用回数の消費を止める。
          generationError = e;
          generationStackTrace = st;
          break;
        }
      }
    } finally {
      aiProcessingNotifier.end();
    }
    if (!context.mounted) {
      return;
    }
    if (generationError != null) {
      showErrorSnackBar(context, generationError, generationStackTrace);
      // 失敗前の画像から抽出済みの候補が1件もなければ review sheet は開かない。
      if (rawItems.isEmpty) {
        return;
      }
    }
    // 既存アイテムに存在しない候補だけ review sheet にかける。
    // 候補が空（画像から読み取れなかった／すべて既存）でも review sheet を開き、
    // 「候補がありませんでした」を表示して画像が読み取れたか判断できるようにする。
    await reviewAndAddAICandidates(
      context: context,
      addShoppingListItem: addShoppingListItem,
      shoppingListID: shoppingListID,
      userID: currentUserID!,
      shoppingListItems: shoppingListItems,
      candidateNames:
          rawItems
              .where((e) => !shoppingListItems.any((item) => item.message == e))
              .toList(),
      source: 'image',
    );
  }

  void _showURLInputDialog(
    BuildContext context, {
    required bool isPremium,
    required int remainingURLRecognition,
  }) {
    analytics.logEvent(
      name: 'tap_open_url_input',
      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
    );
    if (remainingURLRecognition <= 0) {
      final limit =
          isPremium
              ? premiumMonthlyURLRecognitionLimit
              : freeMonthlyURLRecognitionLimit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            'URL読み取りの月間利用回数（$limit回）に達しました${isPremium ? '' : '。プレミアムにアップグレードすると月$premiumMonthlyURLRecognitionLimit回まで利用できます'}',
          ),
          action:
              isPremium
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
      builder:
          (context) => _URLInputDialog(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
          ),
    );
  }

  Future<void> _pasteFromClipboard(
    BuildContext context, {
    required AddShoppingListItem addShoppingListItem,
    required String? currentUserID,
  }) async {
    analytics.logEvent(
      name: 'tap_paste_multiline',
      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
    );
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
      await addShoppingListItem.call(
        shoppingListID: shoppingListID,
        userID: currentUserID!,
        message: line,
        order: shoppingListItems.nextOrder + index,
        description: null,
        color: null,
      );
    }
  }
}

/// AI 抽出候補を review sheet（プレビュー）にかけ、確定した選択分をリストへ追加する。
/// 写真 / URL フロー共通の確定処理。
///
/// review sheet 表示中に呼び出し元 widget は unmount され得る（画面遷移・リスト切替等。
/// URL ダイアログは sheet 表示前に pop 済み）。unmount 後に WidgetRef を使うと
/// StateError で追加が全件失敗する(#486)ため、ref には依存せず、呼び出し元が
/// build 時に確保した [addShoppingListItem]・[userID] を受け取る。
Future<void> reviewAndAddAICandidates({
  required BuildContext context,
  required AddShoppingListItem addShoppingListItem,
  required String shoppingListID,
  required String userID,
  required List<GroupShoppingListItem> shoppingListItems,
  required List<String> candidateNames,
  required String source,
}) async {
  final reviewed = await showAIReviewSheet(
    context: context,
    rawNames: candidateNames,
    source: source,
  );
  if (reviewed == null) {
    return;
  }
  final selected = reviewed.where((c) => c.selected).toList();
  for (var (i, c) in selected.indexed) {
    try {
      await addShoppingListItem.call(
        shoppingListID: shoppingListID,
        userID: userID,
        message: c.name,
        order: shoppingListItems.nextOrder + i,
        description: null,
        color: null,
      );
    } catch (e) {
      // 1 件の追加失敗で残りが止まらないよう、失敗はログに残して続行する。
      debugPrint('Error: $e');
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
    final addShoppingListItem = ref.watch(
      addShoppingListItemProvider(groupID: groupID),
    );
    final aiProcessingNotifier = ref.watch(aIProcessingProvider.notifier);
    final currentUserID = ref.watch(currentUserIDProvider);

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
          onPressed:
              isLoading.value
                  ? null
                  : () {
                    analytics.logEvent(
                      name: 'cancel_url_input',
                      parameters: {
                        'groupID': groupID,
                        'shoppingListID': shoppingListID,
                      },
                    );
                    Navigator.pop(context);
                  },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed:
              isLoading.value
                  ? null
                  : () async {
                    analytics.logEvent(
                      name: 'tap_submit_url',
                      parameters: {
                        'groupID': groupID,
                        'shoppingListID': shoppingListID,
                      },
                    );
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
                    aiProcessingNotifier.start(AIProcessingType.url);
                    List<String> rawItems;
                    try {
                      rawItems = await functions
                          .generateShoppingListItemsFromURL(url: normalizedURL);
                    } catch (e, st) {
                      showGlobalErrorToast(e, st);
                      return;
                    } finally {
                      if (context.mounted) {
                        isLoading.value = false;
                      }
                      aiProcessingNotifier.end();
                    }
                    if (!context.mounted) {
                      return;
                    }
                    // URL ダイアログを先に閉じてから review sheet を出す。
                    popRouteSafely(navigator: navigator, route: dialogRoute);
                    if (!context.mounted) {
                      return;
                    }
                    final candidates =
                        rawItems
                            .where(
                              (e) =>
                                  !shoppingListItems.any(
                                    (existing) => existing.message == e,
                                  ),
                            )
                            .toList();
                    if (candidates.isEmpty) {
                      return;
                    }
                    await reviewAndAddAICandidates(
                      context: context,
                      addShoppingListItem: addShoppingListItem,
                      shoppingListID: shoppingListID,
                      userID: currentUserID!,
                      shoppingListItems: shoppingListItems,
                      candidateNames: candidates,
                      source: 'url',
                    );
                  },
          child: const Text('生成'),
        ),
      ],
    );
  }
}
