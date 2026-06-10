# 0025. 買い物リストアイテムの長押しを並び替えドラッグに統一する

## Status
Accepted

## Context
買い物リストのアイテムを「長押しで D&D 並び替え」できるようにしたい。並び替えの土台
（`ReorderableList` + `order` フィールド昇順 + `ShoppingListItemBatchUpdate` によるバッチ保存）と、
確定行を `ReorderableDelayedDragStartListener`（長押し→ドラッグ開始）でラップする実装は既に存在した。

しかし実機（iOS Simulator）で確認すると、アイテムを長押ししても並び替えドラッグが始まらなかった。
原因は 2 つの長押し競合である:

1. **長押し context menu との競合**: 行に `GestureDetector.onLongPress` で「複製 / メモを追加 / 削除」を
   出す BottomSheet（i-6）が付いており、長押しがメニュー表示に消費されていた。
2. **TextField のテキスト選択との競合**: 行のメッセージは常時 `TextField` で表示している
   （[[0022-shopping-list-keyboard-fixed-input-row]] の「入力行固定方式」では、行の要素＝入力接続を保持して
   ソフトキーボードを閉じないために TextField を常設している）。この TextField の長押しテキスト選択
   （`DelayedMultiDragGestureRecognizer` ではなく `LongPressGestureRecognizer`）が、ジェスチャアリーナで
   並び替えの遅延ドラッグに勝ち、iOS 標準の選択メニュー（Paste / Select All / Scan Text）を表示して
   フォーカス（編集モード）に入ってしまう。

つまり「複製メニューを消す」だけでは長押し D&D は成立せず、TextField のテキスト選択との競合も
解消する必要があった。

## Decision
長押しジェスチャの用途を「並び替えドラッグ」に一本化する。

- **複製等の長押し context menu（`_showLongPressMenu`）を廃止**する。複製の導線は廃止、メモ・カラー編集は
  行末尾の詳細アイコン（`more_horiz`）から、削除は左スワイプから行う。
- **非編集（未フォーカス）の行では TextField の `enableInteractiveSelection` を `false` にする**
  （`enableInteractiveSelection: isEditing`）。これにより未フォーカス行の長押しはテキスト選択を起こさず、
  `ReorderableDelayedDragStartListener` の遅延ドラッグへ渡る。編集中（フォーカス時）は通常どおり
  テキスト選択を許可する。

並び替えはフラット表示（カテゴリ順 OFF）でのみ有効とし、カテゴリ順表示（`_GroupedListView`）は従来どおり
D&D 非対象（`reorderIndex: null`）のまま据え置く。

## Consequences
- **良い点**
  - アイテムを長押しするだけで並び替えドラッグが始まる（実機で確認）。複製メニューや iOS テキスト選択
    メニューに奪われない。
  - 長押しの用途が 1 つ（並び替え）に統一され、ジェスチャの意図が明確になる。
  - [[0022-shopping-list-keyboard-fixed-input-row]] のキーボード固定入力（常設 TextField）を壊さずに両立できる。
- **トレードオフ / 注意点**
  - 未フォーカス行を長押ししてもテキストを選択・コピーできない（タップして編集モードに入れば選択可能）。
    長押し＝並び替えを優先した結果。
  - アイテムの「複製」機能は廃止された（リスト全体の複製機能は別経路で存続）。
  - カテゴリ順表示では D&D 並び替えは依然として無効。カテゴリ順での並び替えが必要になった場合は別途検討する。
  - `enableInteractiveSelection: isEditing` は「未フォーカス行の長押し選択を切る」前提に依存する。将来この
    条件を安易に変えると長押し D&D がテキスト選択に奪われて回帰するため、コード上にも理由をコメントしてある。
