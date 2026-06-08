# 0022. 買い物リストの連続追加でソフトキーボードを閉じない: 入力行固定方式

## Status

Accepted

## Context

買い物リスト画面では、各行が編集可能な `TextField`（`TextShoppingListItemWidget` / `TextShoppingListItemTextField`）で、Enter を押すと「現在行を確定 → 末尾に空行を新規作成 → その空行へフォーカスを移動」して連続入力できる、いわゆるインライン入力モデルを採用していた（origin/main）。

しかしこのモデルでは、**Enter のたびに iOS のソフトキーボードが一瞬閉じて開き直す**不具合があった。原因の切り分けは、`WidgetsBindingObserver.didChangeMetrics` 内で `PlatformDispatcher.views.first.viewInsets.bottom / devicePixelRatio` を観測する計測（`Scaffold` は body の `MediaQuery.viewInsets` を 0 にするため MediaQuery 経由では測れない）を iOS Simulator 実機で反復して行い、**独立した2つの原因**を確定した。

1. **`TextInputAction.next` の performAction が入力接続を close→reopen する**（flutter/flutter#84240）。新規行を作らず現在行を `update` するだけでも単独で全閉する。
2. **Firestore ストリームで新規生成された行へフォーカスを「移譲」する瞬間**に、移譲先の `TextInputConnection` が開く前に現在行の接続が閉じ、キーボードが全閉する。`postFrame` でも `150ms` 遅延（要素が settle した後）でも、移譲先が画面内でも、**いずれも全閉する**。標準的な Form（生成時から存在する複数 `TextField` 間の移譲）では閉じないが、動的に生成された行への移譲では閉じる。

検討した選択肢は3つ。

1. **方式A: 楽観的ローカル挿入でモデル完全維持**
   新しい空行を Firestore 往復を待たず同フレームでローカル挿入し、フォーカスを移譲する。origin/main の「フォーカスが新行へ移る」挙動をそのまま保つ案。
   → 原因2の計測（postFrame / 150ms 遅延 / 画面内のいずれでも全閉）から、**動的生成行への移譲はタイミングに関係なくキーボードを閉じる**ことが判明し、原理的に成立しないと判断した。
2. **コンポーザー全面採用**（PR #358 / 別 ADR 案）
   入力欄を下部固定のコンポーザーに分離し、各行は表示専用にする案。
   → 「行＝編集可能 TextField のインライン入力モデルを維持したい」というユーザー要望に反するため不採用（ユーザー拒否済み）。
3. **方式B: 入力行固定（フォーカスを移譲しない）**（採用）

## Decision

方式B（入力行固定）を採用する。各行は引き続き編集可能な `TextField` のままとし、見た目・連続入力の挙動は origin/main と同等に保つ。

- **原因1の対策**: `textInputAction` を `TextInputAction.newline` にし、`onEditingComplete` / `onSubmitted` を使わず、改行が入力されたことを `onChanged` で検知して確定する。これにより performAction を経由させず接続リセットを起こさない。
- **原因2の対策（フォーカスを移譲しない）**: 確定時にフォーカスを新規行へ移譲しない。保存済み `message` が空の行を「入力行」とみなし、入力行で確定したときは、
  - 確定テキストを **別アイテムとして入力行の位置（order）に追加**し、
  - 入力行自体は `nextOrder` へ繰り下げて確定アイテムの下に保ち、**空のままフォーカスを維持**する（次の入力欄として再利用）。
  - 既存アイテム（非空行）の編集確定は内容を `update` し、末尾の入力行へフォーカスを移して続けて追加できるようにする（origin/main の「Enter で次の入力へ」を踏襲）。移譲先は新規生成行ではなく既存の安定した入力行（`GlobalKey` で要素＝入力接続を保持）なのでキーボードは閉じない。入力行が無ければ作成する。フォーカス移譲は `StateProvider`（カウンタ）を介して空の入力行に要求する。
- **要素（入力接続）の保持**: 確定アイテムを入力行の上に挿入すると入力行の list index が 1 つずれる。`ValueKey` だけだと `SliverList` が index ずれ時に要素を再生成して `EditableText` の入力接続を破棄し、キーボードが沈む（実機で約 12pt まで dip）。これを防ぐため、**入力行（空行）には `GlobalKey` を付けて要素（= State = 入力接続）を再生成させず移動で保持**する。確定行（非空）は `ValueKey` のままにする（`ReorderableList` のドラッグ中に対象行の proxy が複製され、`GlobalKey` だと「Duplicate GlobalKey」でクラッシュするため）。あわせて空の入力行はドラッグ並べ替え対象から外す。

結果として、ユーザーから見た挙動は origin/main と同等（入力行は最下部、確定アイテムは上に積まれ、連続入力でキーボードは閉じない）であり、内部的には「フォーカスが新行へ移らず入力行に留まる」点だけが異なる。

## Consequences

### 良い点

- Enter 連続追加でソフトキーボードが閉じなくなり、連続入力が途切れない（実機計測で viewInsets が不動であることを確認）。
- 各行は編集可能な `TextField` のまま・入力欄は最下部のままで、見た目と入力モデルが origin/main と同等に保たれる（コンポーザー分離のような UI 構造変更をしない）。

### トレードオフ・悪い点

- フォーカス移譲は「新規生成された行」へは行えない（接続が切れて閉じる）が、「既存の安定した入力行」へは可能というのが本方式の前提。既存行の編集確定→末尾入力行への移動はこの前提に依存しており、入力行が `GlobalKey` で要素保持されていることが必須。
- 入力行用の `GlobalKey` をモジュールレベルの `Map<String, GlobalKey>` で管理し、一覧から消えた id をビルド時に掃除する。要素保持のための実装上の都合であり、肥大化は掃除で抑える。
- カテゴリ順（グループ）表示時の order 計算はフラット表示を主眼に設計しており、グループ表示では確定アイテムが別カテゴリ節に入る等の差異が出る可能性がある（プレミアム + カテゴリ前提のため未実機検証）。

### 関連

- flutter/flutter#84240（performAction 後の入力接続リセット）
- PR #358 / コンポーザー全面採用案（不採用）
- `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart`
- `lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart`
