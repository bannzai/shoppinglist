# 0001. 仮想ペアリング方式によるE2Eテスト戦略

## Status

Superseded by [0002](0002-settings-page-developer-options.md)

## Context

グループ招待→参加→データ同期のE2Eテストを実行するため、当初はiOS SimulatorとAndroid Emulatorの2台でMaestroテストを実行する方式を検討した（Issue #105）。しかしAndroid側に以下の問題が発覚し、安定した自動テストの実現が困難であった:

- **API 36 inputText不具合**: Maestroの `inputText` が1キーストロークに10-20秒かかるバグ ([Maestro #2718](https://github.com/mobile-dev-inc/Maestro/issues/2718))
- **debugビルド起動タイムアウト**: ActivityManagerの `PROC_START_TIMEOUT = 10秒` がハードコードされており、Flutter debugビルドのDart VM + Impeller初期化がこれを超過してANRが発生
- **Maestro `-e` 環境変数展開不具合**: `${VARIABLE}` 形式の展開が不安定
- **データ同期問題**: `AppEntityPrepareResolver` が新規ユーザーのために `ShoppingList` を自動作成し、既存グループのデータと競合

「別ユーザーがアイテムを追加し、リアルタイム同期で画面に反映される」シナリオを検証する方法が必要であった。

検討した選択肢:
1. **Android Emulatorの問題を個別に解決する** — Maestro側のバグ修正待ちが必要で、起動タイムアウトはOSレベルのハードコード値のため回避困難
2. **Firebase Functions経由でバックエンドからデータ投入する** — テスト用のFunctions作成が必要で、セキュリティルール検証ができない
3. **アプリ内に仮想ペアリング機能を実装する** — 1台のデバイスで完結し、実際のFirestoreルールを通したデータ操作が可能

## Decision

アプリ内に「開発者オプション（仮想ペアリング）」機能を実装し、1台のiOS Simulatorで「別ユーザーの操作」をシミュレーションする方式を採用した。

### 技術的な決定事項

**デバッグユーザーID**: `{実UID}_debug_1` 形式のIDでFirestoreにドキュメントを作成する。

**Firestoreセキュリティルール**: `string.matches(regex)` (RE2構文) を使用し、`userDocID.matches(request.auth.uid + '_debug_[0-9]+')` でデバッグユーザーIDをマッチする。`parentUserID` フィールド方式は採用しない（既存のドキュメント構造に変更を加えずに済むため）。

**シェイク検出**: `sensors_plus` パッケージの `accelerometerEventStream()` で加速度を監視し、閾値超過時に開発者オプションモーダルを表示する。iOS Simulatorでは `xcrun simctl io booted shake` でトリガー可能。

**kDebugModeガード**: 全てのデバッグ機能コードは `kDebugMode` で囲み、リリースビルドには影響しない。

## Consequences

### 良い点
- iOS Simulator単体で安定したE2Eテストが実現できる
- 実際のFirestoreセキュリティルールを通したデータ操作が検証できる
- Maestroが安定しているiOS Simulatorのみで完結する
- Android固有の問題に依存しない

### 悪い点・トレードオフ
- デバッグ専用のコードがアプリバイナリに含まれる（`kDebugMode` でガード済みのため、リリースビルドではTree-shakingで除去される）
- 実際の2台デバイス間の通信・認証フローは検証できない（Firebase Authの `request.auth.uid` は常に実ユーザーのもの）
- `sensors_plus` パッケージへの依存が追加される
- Firestoreセキュリティルールにデバッグ用のヘルパー関数が残る（本番環境でも有効だが、デバッグユーザーIDの作成にはアプリ内のkDebugMode機能が必要なため実害なし）
