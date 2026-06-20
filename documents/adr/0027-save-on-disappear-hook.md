# 0027. 画面離脱・アプリ background 時の自動保存に useOnDisappear hook を使う

## Status
Accepted

## Context
アイテム詳細シート（`text_shopping_list_item_detail_bottom_sheet.dart`）には「保存」ボタンがあり、説明・カラー・写真の変更は保存ボタンを押すまで永続化されなかった。押さずにシートを閉じる／アプリを離れると入力が失われる。カテゴリ編集画面（`group_category_edit/page.dart`）も同様で、カテゴリ名はキーボードの「完了」（`onSubmitted`）を押した時だけ保存されていた（色・アイコン・キーワードは操作時に即時保存）。

「保存ボタンを押さなくても、画面を離れる時・アプリが離れる時に変更があれば保存してほしい」という要件を、複数の詳細画面で再利用できる形で実現する必要があった。あわせて手動の「保存」ボタン／「保存しました」フィードバックは廃止する。

実装方式を検討する中で、hooks_riverpod 固有の制約が判明した。

- `useEffect` の cleanup（dispose 相当の処理）は **Widget の unmount 後**に実行される。
  `hooks_riverpod` の element は `class _HookConsumerElement extends ConsumerStatefulElement with HookElement` で、
  `HookElement.unmount()` が `super.unmount()`（= `context.mounted` を false にする）の**後**に hook の dispose を呼ぶ
  （`flutter_hooks/lib/src/framework.dart`）。
- `WidgetRef.read` は `_assertNotDisposed()` で `context.mounted == false` のとき
  `StateError('Cannot use "ref" after the widget was disposed.')` を投げる
  （`flutter_riverpod/lib/src/consumer.dart`）。
- つまり「画面離脱時(dispose)に保存する」処理の中で `ref` / `BuildContext` を参照すると例外になる。
- さらに、アプリのバックグラウンド移行（`AppLifecycleState.paused`）では Widget は tree に残るため dispose されず、
  dispose だけでは「アプリが離れる時」をカバーできない。

## Decision
再利用可能な hook `useOnDisappear`（`lib/utils/hooks/use_on_disappear.dart`）を導入し、次の方針で実装する。

1. **dispose と paused の両方で callback を発火する。** 画面離脱（戻る・別画面遷移・モーダルを閉じる）は
   `useEffect` の cleanup、アプリの background 移行は `AppLifecycleListener(onStateChange: paused)` で検知する。
   1 つの hook に集約し、要件「画面を離れる時」「アプリが離れる時」の両方を満たす。
2. **callback 内では `ref` / `BuildContext` を使わせない。** callback は unmount 後にも呼ばれるため。
   保存に必要な処理（`call` クラス）は呼び出し側が build 時に `ref.watch` でキャプチャして closure に閉じ込める
   （例: `final update = ref.watch(...Provider); useOnDisappear(() => update.call(...));`）。
   `ref.watch` で取得した plain object（`GroupDatabase` を保持する `call` クラス）は provider の dispose 後も
   Firestore 書き込みに使えるため、fire-and-forget で安全に保存できる。
3. **callback は毎 build 最新へ差し替える（`useRef`）。** `useEffect` を `const []` で 1 度だけ張りつつ、
   dispose/paused 時には最新 build の closure を呼ぶ。これにより closure が掴む `category` は常に直近 build の値
   （= 直近で永続化された色/アイコンを含む）になり、`copyWith(name:)` + `merge:true` での古い値の上書きを防ぐ。

### 却下した代替案
- **`PopScope.onPopInvokedWithResult`**: pop は Widget mounted 中に走るため closure 内で `ref.read` が安全に使え、
  さらに provider から最新値を読めるので競合も完全に排除できる。しかし background は別途
  `AppLifecycleListener` で扱う必要があり、保存ロジックが 2 箇所に分かれる。離脱経路を 1 つの hook に
  一本化する `useOnDisappear` の方がシンプルで再利用しやすいため不採用。
- **dispose のみの hook**: background（`paused`）では dispose されないため「アプリが離れる時」をカバーできず不採用。

## Consequences
- **良い点**: 「離脱時に未保存入力を保存する」共通パターンを hook として再利用できる。カテゴリ名以外でも、
  buffered な入力を持つ詳細画面に同じ手法を適用できる。
- **制約**: `useOnDisappear` の callback 内で `ref` / `BuildContext` を参照してはいけない（unmount 後に呼ばれ
  StateError になる）。保存に必要なものは build 時にキャプチャする。この制約は hook の doc コメントに明記している。
- **軽微な限界**: 色/アイコンを変更した「同一フレーム内（< 16ms）」に離脱した場合のみ、provider の再 emit が
  間に合わず closure の `category` が旧値のままになり、`copyWith(name:)` + `merge:true` で旧色を書き戻す理論上の
  競合がある。色/アイコン変更は provider 再 emit → 再 build を伴い、人間の操作間隔ではフレームをまたぐため
  実質発生しない。完全排除には離脱時に `ref` で最新値を読む必要があるが、dispose 時は `ref` 不可のため、
  「最新 closure を呼ぶ」設計で実用上十分に抑止する方を選んだ。

## 参照
- `lib/utils/hooks/use_on_disappear.dart`
- `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart`（保存ボタン廃止＋自動保存。写真アップロード等の async 値は dispose 前に同期キャプチャし、削除時は `skipSave` で自動保存を抑止）
- `lib/features/group_category_edit/page.dart`
- `test/features/group_category_edit/auto_save_on_disappear_test.dart`
- `test/features/shopping_list/components/shopping_list_items/item_detail_auto_save_on_disappear_test.dart`
- 既存パターン: `lib/features/shopping_list/page.dart`（`useEffect` + `AppLifecycleListener(onStateChange: paused)`）
- 関連 ADR: [0022](0022-shopping-list-keyboard-fixed-input-row.md)（Flutter widget ライフサイクル系の設計判断）
