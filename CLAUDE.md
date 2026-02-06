「買い物リスト」という買い物リストを管理できるアプリを作成しようとしています

このアプリはFlutter製でバックエンドにはFirebaseを採用しています。認証・DB・バックエンドロジック・AIの処理、プッシュ通知等すべてFirebaseファミリーのインフラで構築されます

- Flutterのコード: @lib/
- Firebase のコード: @firebase/

あなたにはこの「買い物リスト」の開発の手伝い、および相談にのっていただきたいです

### Flutter
iOS,Androidアプリをサポートします。Firebase の設定ファイルは flutterfireの.jsonを定義する方法を使用せずに、iOSではGoogleService-Info.plist,Androidでは、google-service.jsonの配置を行い構成します

#### ビルド・テスト・検証方法
// TODO: Flutterのビルド
// TODO: Flutterのテスト方法

### Firebase
firebase/ ディレクトリ配下についてです。主にbackendで動くFirebase Functionsの設定です。クライアントから呼ぶ処理は GenKit を使って定義します。AIを使わなくてもGenKitでonCallの関数を定義します。なぜならAPI コンソールがついてきて検証がしやすいから

#### ビルド・テスト・検証方法
// TODO: Prettierのlinterの実行
// TODO: npm run build の実行方法
// TODO: Firebase Functions のコードをjestを用いてテスト実行して確認
// TODO: Firebase Functions のコードをテストプロジェクトを用いてテスト実行して確認

#### 規約
Firebase Functions の規約です
- 原則: onDocumentCreated,onDocumentUpdated によるトリガーによる処理を禁止します。コードがトレースしにくくなり、思わぬタイミングで発動してしまうのでコントロールがむず痒いためです
- 原則: クライアントから呼ぶ Functions は GenKit を使用して定義します
- Deployはユーザーが行うので禁止

### プロジェクト構成・ドキュメント方針
- 実装のことは全てコード上のコメントに記載する
- GenKitのFunctionsの検証のために引数は、Functionsの定義位置に記載する
- 細かい点は既存の構成を汲み取って欲しい。原則、機能(Feature)ごとにディレクトリを切っている。 {feature}/README.md にその機能の説明・使用方法・役割を書いていく。必要があればそのREADMEを参照する
- その他、コーディング規約や機能に依存しない全体的な指示やドキュメント、メモは documents/ ディレクトリに配置する
- CLAUDE.mdには基本的にコーディング規約等は書かない。コンテキストを圧迫するから
