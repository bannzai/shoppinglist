# 0002. 設定画面経由の開発者オプション方式への転換

## Status

Accepted

## Context

ADR 0001 で採用した仮想ペアリング方式の実装中に、シェイク検出によるモーダル表示が以下の技術的制約により実現不可能であることが判明した:

1. **GraalJS Java interop 無効**: Maestroの `runScript` で `java.lang.Runtime.exec()` は使えず、フロー内からシェイクコマンドを実行できない
2. **`xcrun simctl io booted shake` が存在しない**: simctl に shake サブコマンドがなく、シミュレータ外部からのシェイクトリガーが不可能
3. **`sensors_plus` が Simulator のシェイクに非対応**: accelerometer はシミュレータの Device > Shake メニューに反応しない（`motionShake` イベントとは別系統）

さらに実装過程で以下のE2E固有の問題にも対処が必要だった:

- **`launchApp: clearState: false` がアプリを終了→再起動する**: `Future.delayed` コールバックが破棄され、遅延実行パターンが使えない
- **ListTileのセマンティクス結合**: FlutterのListTileが子ウィジェットのセマンティクスを結合するため、Maestroが個別テキストを検出できない
- **AutoDispose StreamProviderの `ref.read` が `AsyncLoading` を返す**: コールバック内での `ref.read` が未監視プロバイダに対して初期状態を返す

検討した選択肢:
1. **シェイク検出の代替手段を探す** — iOS Simulatorでの安定したシェイク検出手段が見つからず断念
2. **設定画面にデバッグ専用タイルを追加する** — Maestroから直接タップ可能で、追加パッケージ不要

## Decision

設定画面に `kDebugMode` 限定の「開発者オプション」ListTileを配置し、タップで開発者オプション画面に遷移する方式を採用した。

### 技術的な決定事項

**設定画面タイル方式**: `sensors_plus` パッケージへの依存を排除し、設定画面最下部に「開発者オプション」タイルを配置。Maestroは `tapOn: "開発者オプション"` で直接アクセスできる。

**Semanticsラッパー**: `Semantics(label: title, excludeSemantics: true)` でListTileをラップし、Maestroのアクセシビリティツリーからテキストを検出可能にした。

**同期実行パターン**: 遅延実行+画面遷移（pop）方式を廃止し、操作を同期的に実行して結果（「完了」or「エラー:」）を画面上に直接表示する方式を採用。`launchApp: clearState: false` によるアプリ再起動後も結果が失われない。

**プロバイダの `ref.watch` 化**: `shoppingListsProvider` 等を `ref.read`（コールバック内）から `ref.watch`（build内）に変更し、AutoDispose StreamProviderが常に監視状態になるようにした。

**Firestoreセキュリティルール**: デバッグユーザー用の `allow delete` ルールを `/users/{userID}` と `/groups/{groupID}/userProfiles/{profileID}` に追加。

**Maestro `--device` オプション**: 複数シミュレータ起動時の誤選択を防ぐため、`run_group_sync_test.sh` でデバイスUDIDを明示指定。

## Consequences

### 良い点
- `sensors_plus` パッケージへの依存が不要になった
- Maestroから確実にアクセスできる（シェイク検出の不安定さを排除）
- 同期実行パターンにより、E2Eテストのタイミング依存を完全に排除
- 6フェーズ全てが安定してパスする

### 悪い点・トレードオフ
- 設定画面にデバッグ用UIが露出する（`kDebugMode` でガード済み）
- Maestroフロー内で設定画面→開発者オプションへの遷移ステップが毎フェーズ必要（スクロール2回+タップ）
- ADR 0001 で想定していたシェイク方式のコードは全て不要になった
