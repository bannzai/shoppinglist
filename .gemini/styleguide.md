# Styleguide
このファイルはGeminiがこのリポジトリで作業する際のガイダンスを提供します。

## Rule
返信は日本語でしてください


## Firebase Firestore

- **group配下の同時書き込み対策**: group配下のドキュメントでユーザーの同時書き込みによりデータが消える可能性がある場合は、`runTransaction` を使用すること

### セキュリティについてチェックする
- Firebase Functions onCall で req.auth のチェックを行なっている
- Firebase Functions onCall でクライアント側は httpsCallable が使用されている

### Entityの命名規則
- /users から始まるpathのcollection,subCollectionのEntityには `User` プレフィックスをつける
- /groups から始まるpathのcollection,subCollectionのEntityには `Group` プレフィックスをつける

### onDocumentCreated,onDocumentUpdated トリガーの禁止
- コードのトレースが難しくなる
- 意図しないタイミングで実行される問題が常に付きまとう

### Document Reference の更新は、{ merge: true }  をつける
- つけてないと指定したフィールド以外消える。ちょっとしたコードの移動で意識せずに消える

### タイムスタンプの扱い
- クライアント側で `DateTime.now()` を使わず `FieldValue.serverTimestamp()` を使用する
- Firestoreドキュメントの更新時は `serverUpdatedDateTime: FieldValue.serverTimestamp()` を必ず付与する
- 新規作成時は `serverCreatedDateTime` と `serverUpdatedDateTime` の両方を付与する

### Composite Document ID
- サブコレクション内のドキュメントIDは、親ドキュメントのIDを含むcomposite形式にする
  - 例: `group_{groupID}_userProfile_{userID}`
- ID生成ロジックはエンティティクラスのstaticメソッドに集約する

### Firebase Functions の呼び出し
- Firebase Functions呼び出しは状態を持たないため、class + Providerでラップせず `functions.xxx()` を直接呼ぶ
- Firestoreへの直接読み書き（Functions経由でない）は引き続きclass + Providerで定義する

## TypeScript (Firebase Functions)

### any 型の回避
- `doc.data()` の戻り値はそのまま使わず、`interface` を定義して `as` で型アサーションする

## エラーメッセージ
- エラーメッセージについては、基本的にそのまま表示する（`e.toString()` の加工・プレフィックス除去等はしない）

## Riverpod

### ref.watch と ref.read の使い分け
- `build` メソッド内では必ず `ref.watch` を使用する。`ref.read` を使うとProviderの値が変化してもWidgetが再ビルドされず、UIに反映されない
- `ref.read` は `onPressed` 等のコールバックや非同期クロージャ内など、build外で一度だけ値を読む場合に使用する
- firestoreのDBに書き込むProviderでは、`ref.read` を使用してクロージャの中で呼ぶ

## Flutter Hooks

### useEffect のコメント必須
- `useEffect` を使用する際は、その直前に目的と依存配列の意図を説明するコメントを追加する
- 特に依存配列に含めなかったものがある場合はその理由を明記する

