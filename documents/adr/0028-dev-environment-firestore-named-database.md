# 0028. dev 環境を Firestore named database `development` で用意し dart-define で接続切替

## Status
Superseded by [[0030-separate-dev-prod-firebase-projects]] (Issue #410)

named database `development` + dart-define `FIRESTORE_DATABASE_ID` 方式は、バックエンド(`admin.firestore()`)が named DB 非対応で dev と整合しないため廃止し、別 Firebase プロジェクトによる完全分離(本 ADR の選択肢A)へ移行した。

## Context
ADR 0027 でお問い合わせ送信時に「問い合わせ時点の DB スナップショット」を `inquiries/{id}.snapshotJson` に保存し、復元コマンドで書き戻せるようにした。しかしこのアプリは Firebase プロジェクトが `shopping-list-prod-a615c` の1つだけで、dev 専用の DB が存在しなかった。そのため復元先が本番 `(default)` データベースしかなく、「問い合わせユーザーの状態を再現する」ために復元すると本番データを汚すリスクがあった。

不具合再現のために、本番に触れずスナップショットを復元・閲覧できる dev 環境の DB が必要になった。検討した選択肢:

1. **別 Firebase プロジェクト** (`shopping-list-dev`): 完全分離だが、GoogleService-Info / google-services.json / Secret / flavor を二重管理する必要があり重い。
2. **Firestore Emulator**: 既存コードに `Flavor.LOCAL`（"for development with firebase:emulators"）の口があるが、永続性がなくローカル起動が前提。
3. **同一プロジェクト内の Firestore named database**: 1プロジェクトに複数 Firestore データベースを持てる機能。`(default)` とは別に `development` データベースを作る。認証は1つ（同プロジェクト）で済み、復元も `(default)`→`development` を同一クレデンシャルで行える。

また、アプリをどの DB に向けるかの切替方式も決める必要があった。現状 `lib/main.dart` は `kDebugMode` で `Flavor.DEVELOP` を設定しており、**debug ビルドは本番 `(default)` のデータを見て開発している**。flavor 連動（debug=dev DB）にすると既存の開発フローが空の dev DB を見ることになり破壊的。

## Decision

### 1. dev DB は同一プロジェクト内の named database `development`
別プロジェクトや Emulator ではなく、`shopping-list-prod-a615c` 内に Firestore named database `development` を作成する（`gcloud firestore databases create --database=development --location=asia-northeast1`、`(default)` と同リージョン）。
- 名前は当初 `dev` を希望したが Firestore の制約（database_id は4〜63文字）で不可のため、`Flavor.DEVELOP` に合わせて `development` とした。

### 2. アプリの接続先は中央アクセサ + dart-define オプトイン
`FirebaseFirestore.instance` の直書き（32箇所）を中央アクセサ `lib/utils/firestore/firestore.dart` の `firestore` getter に置換する。接続先は dart-define `FIRESTORE_DATABASE_ID` で切り替える。
- 未指定（空文字）→ `(default)`（本番）。`development` 指定時のみ named database に接続。
- flavor 連動ではなく**明示オプトイン**にした理由: 現状 debug ビルドが本番データで開発しているため、debug=dev DB にすると既存開発が壊れる。再現したい時だけ `--dart-define=FIRESTORE_DATABASE_ID=development` で切り替える非破壊方式にする。
- `.vscode/launch.json` に dev DB 用の起動構成を追加（実行時引数と launch.json を同期する規約に従う）。

### 3. firebase.json を配列化し両 DB にルール/インデックスを配布
`firestore` 設定をオブジェクトから配列にし、`(default)` と `development` の両方へ同じ `firestore.rules` / `firestore.indexes.json` をデプロイする。これがないと `development` は既定 deny でアプリが読み書きできない。

### 4. 復元先を `development` にし、スナップショットを Slack にも残す
復元コマンド `script-restore-inquiry-snapshot` の書き先を既定で `development` にし、本番 `(default)` を汚さない（`(default)` への書き込みは `ALLOW_PROD_RESTORE=true` を要求）。読み元は問い合わせ ID（`(default)` の inquiries から）または `--file`（Slack 添付のスナップショット JSON をダウンロードしたもの）。
- ADR 0027 で Bot Token を選んだ狙い通り、Slack 通知のスレッドにスナップショット JSON をファイル添付する（`files:write` スコープが必要）。これにより担当者は Slack からスナップショットを取得し `--file` で `development` に復元して再現できる。

## Consequences
- 本番に触れずに問い合わせ時点の状態を `development` へ復元して再現できる。復元は同一プロジェクト・単一クレデンシャルで完結する。
- 既存の debug 開発（本番データ参照）は不変。dev DB を使う時だけ dart-define を付ける明示運用になる。
- Firestore アクセスが中央アクセサ `firestore` に一本化され、今後の接続先切替（環境追加等）が一箇所で済む。新規コードは `FirebaseFirestore.instance` ではなく `firestore` を使うこと。
- `development` データベースは同一プロジェクトに属するため、課金・割り当ては本番プロジェクトに合算される（完全な課金分離が必要なら別プロジェクト化が必要）。
- `development` 用にルール/インデックスのデプロイ（`firebase deploy --only firestore`）が必要。怠るとアプリが dev DB を read/write できない。
- Slack ファイル添付には Bot に `files:write` スコープ追加と再インストールが必要。添付失敗は通知本体の成否に影響させない（best-effort）。
- スナップショットは本番ユーザーの uid のまま `development` に復元される。dev の別ユーザーで「自分のデータ」として再現するには uid 載せ替えが別途必要（今回は未対応）。
