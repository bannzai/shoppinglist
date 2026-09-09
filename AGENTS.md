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
- 動作確認は、極力あなたが行うこと。 /sim-manager skill を使用して動作確認をすること
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
