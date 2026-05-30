「買い物リスト」という買い物リストを管理できるアプリを作成しようとしています

このアプリはFlutter製でバックエンドにはFirebaseを採用しています。認証・DB・バックエンドロジック・AIの処理、プッシュ通知等すべてFirebaseファミリーのインフラで構築されます

- Flutterのコード: @lib/
- Firebase のコード: @firebase/

あなたにはこの「買い物リスト」の開発の手伝い、および相談にのっていただきたいです

## Plan時に考慮すること
- 必ず実装修正内容の動作確認のチェックリストを作ってください。それを確認するテストも後述する検証方法を参考に用意して検証完了までを行ってください
- プランファイルには必ず具体的な実装コード提案（コードブロック）を含めること。説明のみのプランは不可
- プランファイル末尾に `.claude/rules/plan-checklist.md` のチェックリストを追記すること

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

### Firebase
firebase/ ディレクトリ配下についてです。主にbackendで動くFirebase Functionsの設定です。クライアントから呼ぶ処理は GenKit を使って定義します。AIを使わなくてもGenKitでonCallの関数を定義します。なぜならAPI コンソールがついてきて検証がしやすいから

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
- Deployはユーザーが行うので禁止

### コーディング規約
- Entityのフィールド名は省略せず、長くても実態がわかる名前をつける（例: `categoryID` ではなく `groupShoppingListItemCategoryID`）
- FirestoreのDBをクライアントから操作する場合は、`call` 関数を定義したclassを通じて行う（例: `ShoppingListAdd`, `CreateGroup` など。Providerからそのclassのインスタンスを返却する）
- 関数の引数は原則 `{required}` でラベルが呼び出し元につくようにする
- コンストラクタの引数も nullable であっても `required` をつける。ただしtimestamp等のメタデータフィールドは除く
- firestoreのDBに書き込むProviderでは、ref.readを使用してClosureの中で呼ぶ
- エラーメッセージについては、基本的にそのまま表示する（`e.toString()` の加工・プレフィックス除去等はしない）
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する

### テスト方針
- 実装後は手動テスト前に必ず、ユニットテスト・MaestroによるE2Eテストを実行する。該当するものがなければテストを新規作成をする。作成・実行が難しい場合はユーザーに報告する

### プロジェクト構成・ドキュメント方針
- 実装のことは全てコード上のコメントに記載する
- GenKitのFunctionsの検証のために引数は、Functionsの定義位置に記載する
- 細かい点は既存の構成を汲み取って欲しい。原則、機能(Feature)ごとにディレクトリを切っている。 {feature}/README.md にその機能の説明・使用方法・役割を書いていく。必要があればそのREADMEを参照する
- コーディング規約・ルールは `.claude/rules/` ディレクトリに配置する（Claude Code rules機能で自動ロード）
- プロジェクト仕様書・ADR等のドキュメントは `documents/` ディレクトリに配置する
- CLAUDE.mdには基本的にコーディング規約等は書かない。コンテキストを圧迫するから
