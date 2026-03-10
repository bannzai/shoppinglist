「買い物リスト」という買い物リストを管理できるアプリを作成しようとしています

このアプリはFlutter製でバックエンドにはFirebaseを採用しています。認証・DB・バックエンドロジック・AIの処理、プッシュ通知等すべてFirebaseファミリーのインフラで構築されます

- Flutterのコード: @lib/
- Firebase のコード: @firebase/

あなたにはこの「買い物リスト」の開発の手伝い、および相談にのっていただきたいです

### Flutter
iOS,Androidアプリをサポートします。Firebase の設定ファイルは flutterfireの.jsonを定義する方法を使用せずに、iOSではGoogleService-Info.plist,Androidでは、google-service.jsonの配置を行い構成します

#### ビルド・テスト・検証方法
- コード生成: `dart run build_runner build` (freezed/json_serializable/riverpod_generator の生成ファイルを更新)
- iOS ビルド: `flutter build ios`
- Android ビルド: `flutter build apk` または `flutter build appbundle`
- テスト実行: `flutter test`
- 静的解析: `flutter analyze`

### Firebase
firebase/ ディレクトリ配下についてです。主にbackendで動くFirebase Functionsの設定です。クライアントから呼ぶ処理は GenKit を使って定義します。AIを使わなくてもGenKitでonCallの関数を定義します。なぜならAPI コンソールがついてきて検証がしやすいから

#### ビルド・テスト・検証方法
以下のコマンドは全て `firebase/functions/functions/` ディレクトリで実行する

- Linter (ESLint + Prettier): `npm run lint` (自動修正: `npm run lint:fix`)
- ビルド: `npm run build` (内部で `tsc` を実行)
- ユニットテスト: `npm test` (Jest)
- Firebase Emulator での検証: `npm run serve` (ビルド後に Emulator 起動)
- GenKit Dev Server での検証: `npm run genkit:start` (API コンソール付きで起動、関数を直接呼び出して検証可能)
