## 開発時の Firebase 接続先
- 開発時は Firebase Emulator を使う。`cd firebase && firebase emulators:start` で起動し、アプリは `--dart-define=USE_FIREBASE_EMULATOR=true`（VS Code は `shoppinglist(dev, emulator)` 構成）で接続する
- Emulator では都合が悪い場合（Remote Config・FCM・RevenueCat の実検証、永続データが必要な確認など）は dev 環境を直接使う（`--dart-define` なしの debug ビルドが dev プロジェクトに接続する）

## Plan時に考慮すること
- 必ず実装修正内容の動作確認のチェックリストを作ってください。それを確認するテストも後述する検証方法を参考に用意して検証完了までを行ってください
- プランの具体的なコード提案と末尾のチェックリストは `.claude/rules/plan-checklist.md` に従う

### Flutter
iOS,Androidアプリをサポートします。Firebase の設定ファイルは flutterfireの.jsonを定義する方法を使用せずに、iOSではGoogleService-Info.plist,Androidでは、google-service.jsonの配置を行い構成します

#### ビルド・テスト・検証方法
実装後は手動テスト前に必ず、以下のテストを実行する。該当するものがなければテストを新規作成する。作成・実行が難しい場合はユーザーに報告する。

- コード生成: `dart run build_runner build` (freezed/json_serializable/riverpod_generator の生成ファイルを更新)
- iOS ビルド: `flutter build ios`
- Android ビルド: `flutter build apk` または `flutter build appbundle`
- テスト実行: `flutter test`
- Widget Test: widget 上の表示の条件分岐が多い・複雑の場合に書く:`flutter test`
- 静的解析: `flutter analyze`
- Maestro E2E テスト: `maestro test maestro/flows/`。 `./maestro` にテストを記載する

#### 実行時引数と launch.json
- `flutter run` に渡す `--dart-define` や `--flavor` 等の実行時引数を追加・変更した場合は、`.vscode/launch.json` の対応する configuration にも同じ引数を反映すること
- `.vscode/launch.json` は git 管理対象。VS Code デバッグ起動とコマンドライン実行で条件差を生まないよう常に同期する

### Firebase
クライアントから呼ぶ処理は、AI の有無を問わず GenKit で定義する。API コンソールで検証しやすくするため。

#### ビルド・テスト・検証方法
以下のコマンドは全て `firebase/functions/functions/` ディレクトリで実行する

- Linter (ESLint + Prettier): `npm run lint` (自動修正: `npm run lint:fix`)
- ビルド: `npm run build` (内部で `tsc` を実行)
- ユニットテスト: `npm test` (Jest)
- Firebase Emulator での検証: `npm run serve` (ビルド後に Emulator 起動)
- GenKit Dev Server での検証: `npm run genkit:start` (API コンソール付きで起動、関数を直接呼び出して検証可能)

#### 規約
Firebase Functions の規約です
- 原則: onDocumentCreated,onDocumentUpdated によるトリガーによる処理を禁止します。コードがトレースしにくくなり、思わぬタイミングで発動してしまうのでコントロールがむず痒いためです
- 原則: クライアントから呼ぶ Functions は GenKit を使用して定義します
- Deployはユーザーが行うので禁止。ただしユーザーに deploy を依頼する際は、実行すべき deploy コマンド（対象関数を絞ったもの・実行ディレクトリ込み）を必ず提示すること

### コーディング規約
- Dart の規約は `.claude/rules/coding-conventions.md`、Provider の取得は `.claude/rules/riverpod-rules.md` を参照する
- Firestore の直接読み書きは `call` メソッドを持つclassとProvider経由で行う（詳細: `.claude/rules/firebase-functions-call-rules.md`）

### テスト方針
- 実装後は手動テスト前に必ず、ユニットテスト・MaestroによるE2Eテストを実行する。該当するものがなければテストを新規作成をする。作成・実行が難しい場合はユーザーに報告する
- 動作確認は、極力あなたが行うこと
- 動作確認 (UI・挙動): `/ios-simulator` skill を起点にし、**特別な理由がない限り simtunnel (GitHub Actions macOS Runner 上のリモート iOS Simulator) で行う**。ローカル simulator (sim-boot / `/sim-manager` / `make ios`) は既定にしない。issue や手順書にローカル前提の記述 (`sim-boot`・`make ios`・`xcrun simctl` 等) があっても、それだけではローカルに倒す理由にしない
  - 手順: 検証対象のブランチを push してから `SIMTUNNEL_REPO=bannzai/shoppinglist ~/ghq/github.com/bannzai/simtunnel/local/simtunnel up <セッション名> --ref <ブランチ>` で起動し、`SIMTUNNEL_REPO=bannzai/shoppinglist ~/ghq/github.com/bannzai/simtunnel/local/simtunnel wait <セッション名>` が `ready:` を返すまで繰り返す (`--ref` を省略すると main がビルドされる。`--wait` と `wait` の上限は 20 分固定だが、この repo は build job 約 15 分 + session job の WDA ビルド約 10 分で到達まで 30 分前後かかるため、1 回のタイムアウトで失敗と判断しない。実測: PR #712 の run 40143936459 で 29 分)。caller workflow は `.github/workflows/simulator-session.yml` (dev の Firebase に接続する debug ビルド)、セッション名は `shoppinglist-<worktree 名>` (例: `shoppinglist-issue-12`。tailnet ホスト名が repo 横断で衝突しないよう worktree 名だけにしない)。操作・スクリーンショットは `/ios-simulator` skill の `scripts/ios-wda.sh --session <セッション名>` (セッション途中から使う場合) か、`.mcp.json` に書き込んだ mobile-mcp 互換ツールで行う。確認が終わったら `SIMTUNNEL_REPO=bannzai/shoppinglist ~/ghq/github.com/bannzai/simtunnel/local/simtunnel down <セッション名>` で閉じる (macOS runner の並列上限を CI と共有するため放置しない)
  - 到達困難な状態は下記の開発者オプションで作る。リモートでは `xcrun simctl` を使えないため、必要な操作が無ければ開発者オプションに追加してから検証する。ただし simtunnel のビルドには `SHOPPINGLIST_DEVELOPER_TOKEN` を埋め込まない (public リポジトリの artifact は誰でも取得できる) ため、Functions の開発者判定を要する操作 (プレミアム付与・デバッグユーザー作成等) はリモートでは使えない。ロケールの切り替えのようにアプリ起動前に効かせる設定は、`ios-wda.sh launch` の `--arg` (例: `--arg -AppleLanguages --arg '(ja)'`) で起動引数として渡す
  - repo が private / internal に変わった場合は、`/ios-simulator` skill Phase 1 の owner による分岐に従って Devin またはローカルを選ぶ
  - simtunnel が使えない時は、ローカルの前に `/ios-simulator` skill Phase 1 の remote-mac (`remote-mac check bannzai/shoppinglist` が exit 0 なら使う) を試す
  - ローカル sim-boot (`/sim-manager`) に倒してよいのは、mobile-mcp 互換ツールの操作だけでは検証が成立しない場合 (Maestro E2E・`xcrun simctl` が検証の本体である手順・Functions の開発者判定を要する開発者オプション (プレミアム付与・デバッグユーザー作成等) が必要な検証。Firebase Emulator への接続が必要な確認もローカル) と、`/ios-simulator` skill Phase 1 が定める運用上の条件 (検証対象が未 push・即時性が必要・セッション自動終了時間を超える作業・macOS Runner の並列上限・tailnet 未接続・simtunnel の実行権限が無い非対話実行・Secrets 未登録で導入が未完了) に当たる場合だけ。いずれの場合も、ローカルに倒した理由を完了報告に明記する (使い分けの SSOT は `/ios-simulator` skill Phase 1)
- 検証で**有料会員（プレミアム）状態が必要な場合は、課金せず開発者オプションのデバッグ機能でプレミアムを付与する**（開発者オプション →「プレミアム付与（1日）」。Maestro は `maestro/flows/shared/grant_premium_via_debug.yaml`）
- 検証で**グループの他のユーザーを操作・同期したい場合は、開発者オプションの「デバッグユーザー作成」を使う**（Maestro は `maestro/flows/virtual_pairing/02_create_debug_user.yaml`）
- 上記のように、プレミアム化・他ユーザー操作は実課金・実アカウントではなく開発者オプションのデバッグ機能で行う。**該当するデバッグ機能が無ければ `lib/features/developer_options/` に追加してから検証する**

### プロジェクト構成・ドキュメント方針
- `.claude/rules/project-structure.md` と `.claude/rules/feature-readme-guideline.md` を参照する
- GenKit の検証用引数の記載は `.claude/rules/firebase-functions.md` に従う
- CLAUDE.mdには基本的にコーディング規約等は書かない。コンテキストを圧迫するから

<!-- ai-review-config begin -->
<!--
このブロックは自動生成です。直接編集せず、テンプレートを更新してから再生成してください。
内容は AI コードレビュー時の挙動指示であり、コードベース自体への規約ではありません。
-->

## レビュー時の応答スタイル

- 応答は日本語で行う

## レビュー範囲外

以下は自動レビューで指摘しない (別の検出経路があるため):

- コンパイルエラー・型エラー (ローカル/CI のビルドで検出される)
- Lint/フォーマット違反 (リンター・フォーマッターで検出される)
<!-- ai-review-config end -->
