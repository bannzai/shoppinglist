import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart';
import 'package:shoppinglist/provider/recently_added_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// 既存アイテムの編集を Enter で確定した後、末尾の入力行（空行）へフォーカスを戻すための
/// 要求シグナル。値はインクリメントされるカウンタで、空の入力行はこの変化を購読して自身を
/// requestFocus する。フォーカス移譲先が「新規生成行」ではなく既存の安定した入力行
/// （GlobalKey で要素=入力接続を保持）なので、移譲してもソフトキーボードは閉じない。
final shoppingListInputRowFocusRequestProvider = StateProvider<int>((ref) => 0);

/// 買い物リストの 1 行。
/// `design_handoff_shopping_list/source/screens-list.jsx#ItemRow` 相当。
///
/// 構造:
/// - 円形 Checkbox（22px stroke 1.5px、チェック ON で pop アニメ scale 1→1.2→1）
/// - TextField（編集中フォーカス枠なし）
/// - 詳細アイコン
///
/// focused 中または手入力直後は、左端に 2px の accent ボーダーと accentSoft の背景を出す。
/// checked 時はテキスト色 `t.checked` + 取り消し線、Checkbox 内 accent 塗り。
class TextShoppingListItemWidget extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  final int? reorderIndex;

  /// 未分類アイテムの行に「カテゴリ +」ボタンを出すか。タップで [GroupCategoryPage] の
  /// カテゴリ選択モードへ遷移し、このアイテムを既存カテゴリへ割り当てられる。
  /// カテゴリにマッチ済み(分類済み)の行・入力行(空メッセージ)では false にする。
  final bool showAddCategoryButton;

  const TextShoppingListItemWidget({
    super.key,
    required this.groupID,
    required this.textShoppingListItem,
    required this.shoppingListItems,
    required this.reorderIndex,
    this.showAddCategoryButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
    final textEditingController = useTextEditingController(
      text: textShoppingListItem.message,
    );
    final isEditing = useState(false);

    // Provider は build で watch してローカルにキャプチャし、コールバック・listener はこの変数を
    // 参照する（コールバック内 ref.read 禁止）。これらは下の `[]` deps useEffect が登録する
    // FocusNode listener が捕捉するため、useEffect より前に宣言する。
    final currentUserID = ref.watch(currentUserIDProvider)!;
    final groupDatabase = ref.watch(groupDatabaseProvider(groupID: groupID));
    final updateShoppingListItem = ref.watch(
      updateShoppingListItemProvider(groupID: groupID),
    );
    final toggleShoppingListItemCheck = ref.watch(
      toggleShoppingListItemCheckProvider(groupID: groupID),
    );
    final restoreShoppingListItem = ref.watch(
      restoreShoppingListItemProvider(groupID: groupID),
    );
    final deleteShoppingListItem = ref.watch(
      deleteShoppingListItemProvider(groupID: groupID),
    );
    final recentlyAddedShoppingListItemID = ref.watch(
      recentlyAddedShoppingListItemProvider(
        textShoppingListItem.shoppingListID,
      ),
    );

    // 初回に空行(入力行)へフォーカスし、フォーカスの有無を isEditing に同期する。加えて、
    // フォーカスが外れた瞬間に「入力途中テキストの確定 or 空行の削除」を行い、常駐する空入力行を
    // 残さない。依存配列は空 — FocusNode のライフサイクルに listener を 1 度だけ登録するため。
    // listener が参照する textShoppingListItem は初回 build 値に固定されるが、削除に使う
    // id/shoppingListID は不変で、確定比較が古い message を見ても起きるのは冪等な再更新だけ
    // なので問題ない。
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (textShoppingListItem.message.isEmpty) {
          focusNode.requestFocus();
        }
      });
      void listener() {
        isEditing.value = focusNode.hasFocus;
        if (focusNode.hasFocus) {
          return;
        }
        final text = textEditingController.text.trim();
        if (text.isEmpty) {
          // 空のままフォーカスが外れた行は削除する(入力行・既存問わず中身がないので残さない)。
          // Backspace 削除と同じく一時行の掃除なので物理削除する。
          groupDatabase
              .shoppingListItemsReference(
                shoppingListID: textShoppingListItem.shoppingListID,
              )
              .doc(textShoppingListItem.id)
              .delete();
        } else if (text != textShoppingListItem.message) {
          // 入力/編集途中のテキストをフォーカス喪失時に確定保存する。Enter 確定が走った直後は
          // message==text となりこの分岐は skip される(二重更新を避ける)。
          updateShoppingListItem.call(
            shoppingListID: textShoppingListItem.shoppingListID,
            item: textShoppingListItem.copyWith(message: text),
            editedByUserID: currentUserID,
          );
        }
      }

      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, []);

    // 既存アイテムの編集を Enter 確定した後など、入力行へフォーカスを戻す要求(カウンタ増加)を
    // 受けたら、空行(入力行)を再フォーカスする。依存配列はカウンタのみ — 要求のたびに一度実行する。
    // 確定済みアイテムが消えた id の GlobalKey 掃除等とは無関係に、空行のみ反応する。
    final inputRowFocusRequest = ref.watch(
      shoppingListInputRowFocusRequestProvider,
    );
    useEffect(() {
      if (inputRowFocusRequest > 0 && textShoppingListItem.message.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textShoppingListItem.message.isEmpty &&
              focusNode.context != null) {
            focusNode.requestFocus();
          }
        });
      }
      return null;
    }, [inputRowFocusRequest]);

    // 入力行がフォーカス中に、キーボード表示(viewInsets 変化)や Enter 確定で確定アイテムが
    // 挿入されて入力行が下へ繰り下がる(order 変化)と、入力行がキーボードの裏に隠れて入力中の
    // 文字が見えなくなる(Issue #429)。これらの変化のたびに入力行を可視領域の下端へスクロールし、
    // 入力中の行を常に見えるようにする。プログラムによる ensureVisible のアニメーションは
    // dragDetails を持たないため、ReorderableListView の keyboardDismissBehavior.onDrag を
    // 誤発火させず、フォーカス(ソフトキーボード表示)も維持される(fix-350 の挙動を壊さない)。
    //
    // keyboardInset は入力行(空メッセージ)でだけ viewInsets を購読する。確定行はキーボードの
    // 高さに依存させず、キーボード開閉のたびに全行が再ビルドされるのを避ける。
    final keyboardInset =
        textShoppingListItem.message.isEmpty
            ? MediaQuery.viewInsetsOf(context).bottom
            : 0.0;
    // 目的: 入力行をキーボード上端の可視領域へ追従させる。
    // 依存配列: キーボード高さ・入力行の order・編集状態。レイアウトに影響する変化だけで追従させ、
    // 各文字のテキスト編集では再実行しない(文字単位のキャレット追従は EditableText が担うため)。
    useEffect(() {
      if (textShoppingListItem.message.isEmpty && isEditing.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final scrollContext = focusNode.context;
          if (scrollContext != null) {
            Scrollable.ensureVisible(
              scrollContext,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
      return null;
    }, [keyboardInset, textShoppingListItem.order, isEditing.value]);

    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final isChecked =
        textShoppingListItem.status == GroupShoppingListItemStatus.checked;
    // 空のメッセージ(新規入力待ちの行・未保存の編集中の行)はチェック対象にしない。
    // チェックボックスのタップ・右スワイプの両方を無効化するための判定。
    final isEmptyMessage = textShoppingListItem.message.trim().isEmpty;
    final focused = isEditing.value;
    final isRecentlyAdded =
        recentlyAddedShoppingListItemID == textShoppingListItem.id;
    // チェック済み行に背景は塗らない（screens-list.jsx#ItemRow は checked でも transparent）。
    // divider2 半透過を塗るとカテゴリヘッダーの surface とほぼ同色になり、チェックを入れると
    // セクションの境界が見分けられなくなる（Issue #374）。チェック状態は Checkbox 塗り +
    // 取り消し線 + checked 文字色で表現する。
    final emphasized = focused || isRecentlyAdded;
    final backgroundColor =
        emphasized
            ? tokens.accentSoft.withValues(alpha: 0.6)
            : Colors.transparent;

    // ReorderableListView のドラッグ移動中に Material が必要
    final content = Material(
      color: backgroundColor,
      // 行の長押しは ReorderableDelayedDragStartListener（並び替えドラッグ）に委ねる。
      // 以前あった長押し context menu(複製/メモ/削除)は、長押しジェスチャが並び替え
      // ドラッグと競合してドラッグ開始を阻害するため廃止した。削除は左スワイプ、
      // カテゴリ変更・削除は末尾の詳細アイコン(more_horiz)から行う。
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: emphasized ? tokens.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: textShoppingListItem.message,
              child: _CircleCheckbox(
                checked: isChecked,
                color: tokens.accent,
                // 空行は onChanged を null にしてタップを無効化する。
                onChanged:
                    isEmptyMessage
                        ? null
                        : (_) {
                          analytics.logEvent(
                            name: 'tap_toggle_item_checkbox',
                            parameters: {
                              'groupID': groupID,
                              'shoppingListID':
                                  textShoppingListItem.shoppingListID,
                              'itemID': textShoppingListItem.id,
                            },
                          );
                          toggleShoppingListItemCheck.call(
                            shoppingListID: textShoppingListItem.shoppingListID,
                            item: textShoppingListItem,
                            userID: currentUserID,
                          );
                        },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // 固定高さ(44)を付けると複数行 TextField(maxLines: 7) が枠を上端から
              // 埋めて文字が上にずれる。高さを与えず Row の crossAxisAlignment.center
              // に縦中央化を任せる（GhostItemRow と同じ仕組み）。行の高さは末尾の
              // IconButton(最小 48px) が確保するため、タップ領域は維持される。
              child: SizedBox(
                width: double.infinity,
                child: TextShoppingListItemTextField(
                  groupID: groupID,
                  textEditingController: textEditingController,
                  focusNode: focusNode,
                  textShoppingListItem: textShoppingListItem,
                  shoppingListItems: shoppingListItems,
                  isEditing: isEditing.value,
                ),
              ),
            ),
            if (showAddCategoryButton) ...[
              const SizedBox(width: 8),
              AddCategoryChip(
                onTap: () {
                  analytics.logEvent(
                    name: 'tap_add_category_from_item_row',
                    parameters: {
                      'groupID': groupID,
                      'itemID': textShoppingListItem.id,
                    },
                  );
                  // 既存行を Enter 未確定で編集中のままチップを押した場合、build 時点の
                  // 古い message ではなく入力欄の最新テキストでカテゴリ選択を開く。push に伴う
                  // フォーカス喪失で同じ値が確定保存される(FocusNode listener)ため、選択先の
                  // キーワード追加と保存後の message が一致する。空のときは保存済み値に委ねる。
                  final editedMessage = textEditingController.text.trim();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GroupCategoryPage(
                            groupID: groupID,
                            selectionForItem:
                                editedMessage.isEmpty
                                    ? textShoppingListItem
                                    : textShoppingListItem.copyWith(
                                      message: editedMessage,
                                    ),
                          ),
                    ),
                  );
                },
              ),
            ],
            IconButton(
              tooltip: context.l10n.shoppingListItemDetailTooltip,
              onPressed: () {
                analytics.logEvent(
                  name: 'tap_open_item_detail',
                  parameters: {
                    'groupID': groupID,
                    'itemID': textShoppingListItem.id,
                  },
                );
                appShowModalBottomSheet(
                  context: context,
                  // シートの中身はカテゴリ行と削除のみで少ないため、90% 固定高では
                  // なくコンテンツ高にフィットさせる（Issue #464）。
                  fitContentHeight: true,
                  builder: (context) {
                    return TextShoppingListItemDetailBottomSheet(
                      groupID: groupID,
                      textShoppingListItem: textShoppingListItem,
                    );
                  },
                );
              },
              icon: Icon(
                Icons.more_horiz,
                size: 20,
                color: isChecked ? neutral.ink4 : neutral.ink3,
              ),
            ),
          ],
        ),
      ),
    );

    final widget =
        reorderIndex != null
            ? ReorderableDelayedDragStartListener(
              index: reorderIndex!,
              child: content,
            )
            : content;

    return Dismissible(
      key: ValueKey(textShoppingListItem.id),
      // 空行は右スワイプでのチェックを禁止し、左スワイプ削除のみ許可する。
      direction:
          isEmptyMessage
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
      // i-8 右スワイプでチェックトグル: `design_handoff_shopping_list/README.md` §8
      background: Container(
        color: neutral.ok,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      // i-7 左スワイプ削除
      secondaryBackground: Container(
        color: neutral.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 右スワイプ: チェック状態をトグルし、行は残す
          final wasChecked =
              textShoppingListItem.status ==
              GroupShoppingListItemStatus.checked;
          analytics.logEvent(
            name: 'swipe_toggle_shopping_list_item',
            parameters: {
              'groupShoppingListItemID': textShoppingListItem.id,
              'before': wasChecked.toString(),
            },
          );
          try {
            // チェックボックスのタップと同じく Provider 経由でトグルする。直接 update だと
            // status しか書けず、チェック時の checkedByUserID / lastCheckedDateTime が
            // 更新されない。lastCheckedDateTime を書かないと create_list_spotlight の
            // 条件2(チェック後1時間経過の再訪ナッジ)が成立しなくなる(Issue #494)。
            await toggleShoppingListItemCheck.call(
              shoppingListID: textShoppingListItem.shoppingListID,
              item: textShoppingListItem,
              userID: currentUserID,
            );
          } catch (e, st) {
            if (context.mounted) {
              showErrorSnackBar(context, e, st);
            }
          }
          return false;
        }
        // 左スワイプ: 削除
        analytics.logEvent(
          name: 'swipe_delete_shopping_list_item',
          parameters: {'groupShoppingListItemID': textShoppingListItem.id},
        );
        // 削除が成功すると Stream 更新でこの Widget は dispose され context.mounted が
        // false になり得る。await 後に SnackBar 表示ができるよう ScaffoldMessenger は
        // await 前に捕捉しておく（復元用 call クラスは build で watch 済み）。
        final messenger = ScaffoldMessenger.of(context);
        final l10n = context.l10n;
        try {
          await deleteShoppingListItem.call(
            shoppingListID: textShoppingListItem.shoppingListID,
            itemID: textShoppingListItem.id,
          );
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                persist: false,
                content: Text(l10n.shoppingListItemDeleted),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: l10n.commonUndo,
                  onPressed: () {
                    analytics.logEvent(
                      name: 'undo_swipe_delete_shopping_list_item',
                      parameters: {
                        'groupShoppingListItemID': textShoppingListItem.id,
                      },
                    );
                    restoreShoppingListItem.call(
                      shoppingListID: textShoppingListItem.shoppingListID,
                      item: textShoppingListItem,
                    );
                  },
                ),
              ),
            );
          return true;
        } catch (e, st) {
          logError(e, st);
          messenger.showSnackBar(
            SnackBar(content: Text(describeError(l10n, e, st).message)),
          );
          return false;
        }
      },
      child: widget,
    );
  }
}

/// 未分類アイテムの行に表示する「カテゴリ +」ショートカットボタン。
///
/// タップで [GroupCategoryPage] のカテゴリ選択モード(`selectionForItem`)へ push する。
/// 一覧でカテゴリを選ぶと、アイテム名がそのカテゴリの完全一致キーワードに追記され、
/// このアイテムがそのカテゴリへ分類される（割り当て処理は [GroupCategoryPage] 側に集約）。
class AddCategoryChip extends StatelessWidget {
  /// 「カテゴリ +」タップ時に実行する遷移処理。
  final VoidCallback onTap;

  const AddCategoryChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    // 背景の装飾は Ink に持たせ、その内側の InkWell でタップ波紋を描く。
    // InkWell の child に背景色付き Container を置くと波紋が Container に隠れるため
    // (Material のインクは子の手前に描かれない)、Ink + InkWell + Padding 構成にする。
    return Semantics(
      button: true,
      label: context.l10n.shoppingListAddCategoryLabel,
      child: Ink(
        decoration: BoxDecoration(
          color: tokens.accentSoft.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tokens.accent.withValues(alpha: 0.4)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.commonCategory,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.accentInk,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.add, size: 14, color: tokens.accentInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 円形チェックボックス。`AppCheckbox` を ItemRow 用にラップしたもの。
/// チェック ON 時の pop アニメ + チェック中はカテゴリ色（指定があれば）で塗る。
class _CircleCheckbox extends StatefulWidget {
  final bool checked;
  final Color color;
  // null の場合はチェック不可(空行)。タップを無効化し、見た目も薄くする。
  final ValueChanged<bool>? onChanged;
  const _CircleCheckbox({
    required this.checked,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_CircleCheckbox> createState() => _CircleCheckboxState();
}

class _CircleCheckboxState extends State<_CircleCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 220),
    vsync: this,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant _CircleCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.checked && widget.checked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final disabled = widget.onChanged == null;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => widget.onChanged!(!widget.checked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.checked ? widget.color : Colors.transparent,
            border: Border.all(
              color:
                  widget.checked
                      ? widget.color
                      : (disabled
                          ? tokens.neutral.divider2
                          : tokens.neutral.ink4),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child:
              widget.checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
        ),
      ),
    );
  }
}

class TextShoppingListItemTextField extends HookConsumerWidget {
  final String groupID;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final GroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  final bool isEditing;
  const TextShoppingListItemTextField({
    super.key,
    required this.groupID,
    required this.textEditingController,
    required this.focusNode,
    required this.textShoppingListItem,
    required this.shoppingListItems,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider)!;
    // Provider は build で watch してローカルにキャプチャし、onKey / onChanged はこの変数を参照する
    // （コールバック内 ref.read 禁止）。
    final groupDatabase = ref.watch(groupDatabaseProvider(groupID: groupID));
    final addShoppingListItem = ref.watch(
      addShoppingListItemProvider(groupID: groupID),
    );
    final shoppingListItemBatchUpdate = ref.watch(
      shoppingListItemBatchUpdateProvider(groupID: groupID),
    );
    final updateShoppingListItem = ref.watch(
      updateShoppingListItemProvider(groupID: groupID),
    );
    final inputRowFocusRequestNotifier = ref.watch(
      shoppingListInputRowFocusRequestProvider.notifier,
    );
    final recentlyAddedShoppingListItemNotifier = ref.watch(
      recentlyAddedShoppingListItemProvider(
        textShoppingListItem.shoppingListID,
      ).notifier,
    );
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final isChecked =
        textShoppingListItem.status == GroupShoppingListItemStatus.checked;

    // RawKeyboardListener 用の FocusNode。build のたびに `FocusNode()` を生成すると、
    // onSubmitted の Firestore 書き込み → Stream 反映で本 Widget が再ビルドされた際に
    // TextField のフォーカス親ノードが作り替えられ、Enter 連打中にキーボードが
    // 閉じ開きする一因になる（かつ dispose されずリークする）。useFocusNode で安定させる。
    final keyboardListenerFocusNode = useFocusNode();

    // KeyboardListener は Mac ハードウェアキーボードにしか反応せず、
    // iOS / Android のソフトキーボードの Backspace を拾えない。
    // 代替 SDK API が安定するまでは RawKeyboardListener を維持する。
    // ignore: deprecated_member_use
    return RawKeyboardListener(
      focusNode: keyboardListenerFocusNode,
      onKey: (event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace &&
            textEditingController.text.isEmpty) {
          groupDatabase
              .shoppingListItemsReference(
                shoppingListID: textShoppingListItem.shoppingListID,
              )
              .doc(textShoppingListItem.id)
              .delete();
        }
      },
      child: TextField(
        controller: textEditingController,
        focusNode: focusNode,
        minLines: 1,
        maxLines: 7,
        // Enter で確定する際、actionable な textInputAction（next/done 等）を使うと
        // EditableText.performAction が入力接続を close→reopen（flutter#84240）し、iOS では
        // Enter のたびにソフトキーボードが一瞬閉じて開き直す。これを避けるため action は
        // newline にして performAction を経由させず、改行が入力されたことを onChanged で
        // 検知して確定する（fix-350 で iOS 実機計測して確定した原因対策）。
        textInputAction: TextInputAction.newline,
        // 非編集(未フォーカス)の行では長押しのテキスト選択を無効化し、長押しを並び替え
        // ドラッグ(ReorderableDelayedDragStartListener の DelayedMultiDragGestureRecognizer)
        // に渡す。有効なままだと TextField の長押し選択がジェスチャアリーナで勝ち、行を
        // 長押ししても iOS 標準の選択メニューが出てドラッグを開始できない(iOS 実機で確認)。
        // 編集中(フォーカス時)は通常どおりテキスト選択を許可する。
        enableInteractiveSelection: isEditing,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          hintText: context.l10n.shoppingListItemMemoHint,
        ),
        cursorColor: tokens.accent,
        cursorWidth: 1.5,
        cursorOpacityAnimates: true,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.16,
          color: isChecked ? neutral.checked : neutral.ink,
          decoration:
              isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: neutral.ink4,
          decorationThickness: 1.2,
        ),
        // 改行(Enter)を onChanged で検知して確定する。newline では performAction が
        // 走らないため onSubmitted は使わない。
        //
        // キーボード維持の肝（fix-350 で iOS 実機計測して確定）:
        // 「Firestore ストリームで新規生成された行へフォーカスを移譲する」瞬間に
        // 入力接続が切れてソフトキーボードが全閉する。これを避けるため、本方式では
        // 入力行（保存済み message が空の行）のフォーカスを移譲しない。確定テキストは
        // 別アイテム E として入力行の位置に追加し、入力行自体は空のままフォーカスを
        // 保ち、次の入力欄として再利用する（E は非空なので auto-focus されない）。
        onChanged: (String v) async {
          if (!v.contains('\n')) {
            return;
          }
          final value = v.replaceAll('\n', '').trim();
          // 改行は確定の合図でありテキストには残さない。
          textEditingController.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
          analytics.logEvent(
            name: 'submit_item_text',
            parameters: {'groupID': groupID, 'itemID': textShoppingListItem.id},
          );

          // 保存済み message が空 = 新規入力用の入力行。非空 = 既存アイテムの編集中。
          final isInputRow = textShoppingListItem.message.isEmpty;

          if (value.isEmpty) {
            // 空のまま確定。既存アイテムを空にした場合のみ削除し、入力行(元から空)は
            // 何もせず入力欄として残す。
            if (!isInputRow) {
              groupDatabase
                  .shoppingListItemReference(
                    shoppingListID: textShoppingListItem.shoppingListID,
                    itemID: textShoppingListItem.id,
                  )
                  .delete();
            }
            return;
          }

          if (isInputRow) {
            // 入力行: 確定テキストを別アイテム E として入力行の位置(order)へ追加し、
            // 入力行(C)は nextOrder へ繰り下げて E の下に保つ。入力行は空のまま
            // フォーカスを維持する（移譲しないのでキーボードは閉じない）。
            final submissionSequence =
                recentlyAddedShoppingListItemNotifier.beginSubmission();
            final addShoppingListItemFuture = addShoppingListItem.call(
              shoppingListID: textShoppingListItem.shoppingListID,
              userID: currentUserID,
              message: value,
              order: textShoppingListItem.order,
              description: null,
              color: null,
            );
            shoppingListItemBatchUpdate.call(
              shoppingListID: textShoppingListItem.shoppingListID,
              shoppingListItems: [
                textShoppingListItem.copyWith(
                  order: shoppingListItems.nextOrder,
                ),
              ],
            );
            textEditingController.clear();
            final addedShoppingListItem = await addShoppingListItemFuture;
            if (context.mounted) {
              recentlyAddedShoppingListItemNotifier.highlightIfLatest(
                submissionSequence: submissionSequence,
                shoppingListItemID: addedShoppingListItem.id,
              );
            }
          } else {
            // 既存アイテムの編集確定: 内容を更新し、末尾の入力行へフォーカスを移して
            // 続けて追加できるようにする(origin/main の「Enter で次の入力へ」を踏襲)。
            // 移譲先は新規生成行ではなく既存の安定した入力行(GlobalKey で要素保持)なので
            // キーボードは閉じない。入力行が無ければ新規作成する。
            updateShoppingListItem.call(
              shoppingListID: textShoppingListItem.shoppingListID,
              item: textShoppingListItem.copyWith(message: value),
              editedByUserID: currentUserID,
            );
            final hasInputRow = shoppingListItems.any(
              (item) =>
                  item.id != textShoppingListItem.id &&
                  item.message.trim().isEmpty,
            );
            if (hasInputRow) {
              inputRowFocusRequestNotifier.state++;
            } else {
              addShoppingListItem.call(
                shoppingListID: textShoppingListItem.shoppingListID,
                userID: currentUserID,
                message: '',
                order: shoppingListItems.nextOrder,
                description: null,
                color: null,
              );
            }
          }
        },
      ),
    );
  }
}
