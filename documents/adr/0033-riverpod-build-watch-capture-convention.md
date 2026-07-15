# 0033. Riverpod の Provider 取得は build 内 ref.watch + 変数キャプチャに統一する

## Status

Accepted

## Context

#486「画像登録が完了せず反映されない」の根本原因は、widget が unmount された後に `WidgetRef` を使ったことだった。

- 写真から追加フローは AI レビューシートを `await` した後に `ref.read(addShoppingListItemProvider...)` で Firestore 追加を実行していた
- レビューシート操作中にキーボードが表示されると `isKeyboardVisible` により FAB がツリーから外れて unmount される
- unmount 後の `ref` 使用は flutter_riverpod が `StateError('Cannot use "ref" after the widget was disposed.')` を throw する（`_assertNotDisposed` は `context.mounted` を見て無条件 throw する。debug/release 共通）
- この例外が `catch (e) { debugPrint(...) }` に握りつぶされ、「プレビューは出るが完了しても 1 件も追加されない」というユーザーから見て原因不明の機能不全になった

当時の規約（旧 riverpod-rules.md / coding-conventions.md / CLAUDE.md）は「`ref.watch` は状態の同期に、`ref.read` は機能・操作 Provider にコールバック内で使う」と定めており、この規約に従う限り同型のバグ（await 後の ref アクセス）が構造的に発生し得た。実際、単純 grep で 44 箇所とされていたコールバック内 `ref.read` は、dart formatter の改行分割を考慮した multiline 検索では 108 箇所 / 37 ファイルに存在した。

## Decision

コールバック（クロージャ）内での `ref.read` を原則禁止し、次の構造に統一する。

1. Provider の取得は、状態 Provider・機能 Provider（call クラス）を問わず build 内で `ref.watch` して**ローカル変数にキャプチャ**する
2. `onPressed` 等のコールバックは、キャプチャした変数のみを参照する（コールバック内で新たに `ref.read` / `ref.watch` を呼ばない）
3. ヘルパーメソッドは `WidgetRef` を引数に取らず、必要なインスタンス・値を引数で受け取る

ref へのアクセスが「必ず mount 中（build 中）」に限定されるため、unmount 後 ref 使用による StateError はコードの書き方として発生し得なくなる。call クラスはプレーンなオブジェクトなので、キャプチャ済みインスタンスは widget unmount 後・provider autoDispose 後も安全に動作する。

検討した代替案:

- **コールバック冒頭（await 前）で ref.read して変数に確保する**（#486 の局所対処）: 同原理だが「await より前」という位置制約を人間が守り続ける必要があり、レビューでの検出も難しい。build 側に寄せれば構造で保証できるため不採用
- **コールバック内 ref.read の継続 + lint 強制**: riverpod_lint 2.6.5 に該当ルールがなく、custom_lint の自作が必要。規約変更のほうが根本的なため不採用（lint 強制は将来のフォローアップ候補として残す）

例外として次の 4 パターンは維持する（各箇所に意図を説明する既存コメントあり）:

- `initState` の `ref.listenManual` リスナー内 read（keepAlive service。App ルートで実質 unmount されない）
- keepAlive Notifier の**メソッド**内 `ref.read`（Ref は Notifier のライフサイクルに束縛。標準パターン）
- `await ref.read(xxxProvider.future)` による**操作時点**の async 取得（build watch ではロード中誤判定・不要な再描画が起きるケース）
- **選択時点の最新値**が必要な read（build 時キャプチャでは非同期保存直後の鮮度が失われるケース）

## Consequences

- 良い点: #486 のバグクラス（unmount 後 ref 使用 → StateError 握りつぶし）が構造的に発生しなくなる。回帰 widget test（copy_multiline_text_button_test.dart）で「await 中に unmount してもコールバックが完走する」「旧規約なら StateError になる」の両方を固定した
- 注意点: `ref.watch(xxxProvider.notifier)` でキャプチャした notifier は、autoDispose provider が破棄されると使用時に例外になる。「誰かが watch し続けている」または keepAlive が前提（対象 provider のライフサイクルは issue #492 の分類プランで全数確認済み）
- 注意点: キャプチャした値はクロージャ生成時点のもので、長い await 中の値変化には追従しない。「操作時点の最新値」が必要なケースは例外パターンとして設計時に意識する
- トレードオフ: build 時に provider が構築されるため、テストでは遷移先ページが watch する provider の override が必要になる（従来はコールバック実行まで遅延されていた）
- 未実施: 規約の機械的強制（custom_lint 自作ルール / CI の grep チェック）。await 後の `ref.invalidate`（developer_options に 2 箇所残存）は ref.read ではないため本規約の対象外とした

## 参照

- Issue: #486（発端のバグ）、#492（規約見直しの提案・分類・実装）
- 規約本文: `.claude/rules/riverpod-rules.md`
- https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/WidgetRef/read.html
- https://riverpod.dev/docs/concepts2/consumers
