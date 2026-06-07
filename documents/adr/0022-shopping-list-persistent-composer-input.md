# 0022. 買い物リストの入力を統一コンポーザー方式にする

## Status

Accepted

## Context

買い物リストのアイテム入力は「1 行 = 1 アイテム = 1 TextField」方式だった。各行が編集可能な `TextField`（`maxLines: 7`, `textInputAction: TextInputAction.next`）で、Enter（`onSubmitted`）押下で現在行を保存しつつ末尾に空アイテムを Firestore へ追加し、新しい空行が `requestFocus` でフォーカスを得る、という連続追加フローだった。

この方式では「Enter で次アイテムを作成するたびにソフトキーボードが開閉する」不具合があった。iOS シミュレータで `viewInsets.bottom`（キーボード高さ）を時系列計測した結果、原因が **2 つ独立して** 存在することを確認した。

- **H1（接続リセット）**: `EditableText.performAction` は `next` / `done` / `go` / `send` など `shouldUnfocus=true` のアクションに対し、`onSubmitted` の後に必ず `_scheduleRestartConnection()` を呼ぶ。これは `TextInputConnection` を close→再 attach し、iOS では入力ビュー切替＝キーボードのリセットになる（[flutter/flutter#84240](https://github.com/flutter/flutter/issues/84240)）。
- **H2（フォーカス移譲）**: 別 Widget の `TextField` へフォーカスが移ると、旧フィールドの接続 close と新フィールドの接続 open が同期せず、キーボードが一旦下がってから上がる。

実機計測での各案の挙動:

| 方式 | H1 | H2 | 結果(viewInsets) |
|---|---|---|---|
| `next` + `onEditingComplete:(){}`（旧 production） | あり | あり | 1005→5.7→1005 開閉 |
| 永続フィールド + `done` 単体 | あり | なし | 1005→0.5→1005 開閉 |
| per-row + 改行検知 | なし | あり | 1005→0.5→1005 開閉 |
| 永続フィールド + 改行検知 | なし | なし | **1005 のまま=維持** |

補足: `TextInputAction.unspecified` / `none` は multiline で Return が改行挿入になり `onSubmitted` が発火しない（要素検査で `value:"test\n"` を確認）。`none` は iOS 非対応で debug assert にも掛かる。よって「actionable なアクションを使いつつ restart を避ける textInputAction」は存在しない。

## Decision

入力を **統一「コンポーザー」方式** に変更する。H1・H2 の両方を回避できる唯一の構成（永続単一フィールド + 改行検知）を採る。

- リストの各行は **表示専用**にする（チェック / スワイプ / 並べ替え / 長押しメニュー / 詳細は維持。行内でのテキスト直接編集は廃止）。行テキストのタップで編集モードに入る。
- スクロール領域の **外（直下）に固定**した、破棄されない単一の `TextField`（コンポーザー）を唯一の入力欄とし、追加・編集の両方をここで行う。スクロール領域の中に置くと再構築で作り直され H2 が再発するため、外に固定する。
- Enter は `TextInputAction.newline` で改行を挿入させ、`onChanged` で末尾改行を検知して確定する（`performAction` を経由しないため H1 が起きない）。確定後は入力欄を空に戻しフォーカスを保つ。
- 編集対象は `editingShoppingListItemIDProvider`（null=追加モード）で表現し、行タップでセット、コンポーザーが購読してテキストを読み込む。確定すると追加モードへ戻す。フォーカス喪失（キーボード離脱）で内容を反映。編集中に空で確定/離脱したアイテムは削除する。
- FAB はキーボード表示中は隠し、タップでコンポーザーへフォーカスする。

実装: `lib/features/shopping_list/components/shopping_list_items/shopping_list_composer.dart`、`lib/provider/shopping_list_composer_state.dart`、`lib/features/shopping_list/page.dart`（コンポーザー配置・FAB 制御）。

採用理由: 静的推論では「永続フィールド化（候補 A）」だけで直ると見えたが、実機計測で H1 が独立要因と判明し否定された。H1・H2 を同時に潰せるのはこの構成のみで、実機で連続追加・編集中もキーボードが一度も閉じないことを `viewInsets` 不変で確認した。

## Consequences

### 良い点
- Enter 連続追加・編集中にソフトキーボードが閉じない（本来の要件を満たす）。入力欄が常に同じ位置にあり、長いリストでも入力位置がぶれない。
- 入力フィールドが常に 1 つだけになり、行ごとの `FocusNode` / `TextEditingController` / `RawKeyboardListener` が不要になって行 Widget が単純化する。

### トレードオフ・悪い点
- 既存アイテムの**行内インライン編集を廃止**し、編集は下部コンポーザーに集約する UX 変更を伴う（行タップ→コンポーザーに読み込み）。
- 空行 + Backspace での行削除（Mac ハードキーボードのみ）は廃止。削除はスワイプ / 長押しメニュー / 編集で空にして確定、で代替する。
- 既存の Maestro flow は入力導線（「タップで入力開始」行の廃止・コンポーザー化）と「行テキストタップ=編集（チェック切替ではない）」に追従が必要（別途 maestro 追従パス）。`shared/anonymous_sign_in.yaml` の到達確認のみ `アイテムを追加` へ修正済み。

### 関連
- `documents/adr/0021-drop-dark-mode-light-only.md`
- flutter/flutter#84240（submit 時のソフトキーボード reset）
