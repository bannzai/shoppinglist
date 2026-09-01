# firestore-rules-test

`firebase/firestore.rules` の内容を Firestore Emulator 上で自動検証する単体テストパッケージです。
`@firebase/rules-unit-testing` + Jest を `firebase emulators:exec` から実行し、各パスの許可・拒否を検証します。

bannzai/medicalarm#243 の同名パッケージの移植です（bannzai/shoppinglist#501 参照）。

## 前提

- **Java JDK 21 以上**（Firestore Emulator の実行に必要。Firebase CLI 15.x は JDK 21 未満を拒否します）
  - デフォルトの `java` が 21 未満の場合は `JAVA_HOME` を JDK 21+ に向けてから実行します。
    例: `export JAVA_HOME=$(/usr/libexec/java_home -v 21)`
    （Homebrew の場合は `export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`）
- **Firebase CLI**（`firebase` コマンドが PATH にあること。`emulators:exec` を使用します）
- **Node.js**（`npm` が使えること）

## セットアップ

```
cd firebase/firestore-rules-test
npm install
```

## 実行

```
cd firebase/firestore-rules-test
npm test
```

デフォルトの `java` が JDK 21 未満の環境では、先に `JAVA_HOME` を JDK 21+ に設定してから `npm test` を実行してください（上記「前提」参照）。

`npm test` は `firebase emulators:exec --only firestore --project demo-shoppinglist 'jest'` を実行します。

- `--project demo-shoppinglist`: `demo-` 接頭辞により実プロジェクト・認証情報なしの demo モードで Emulator が起動します。
- Emulator 設定（`firestore.rules` の場所）は親ディレクトリの `firebase/firebase.json` を Firebase CLI が自動検出します。
- テスト本体は `emulators:exec` が子プロセスに渡す `FIRESTORE_EMULATOR_HOST` から Emulator の接続先を取得し、
  `firebase/firestore.rules` を読み込んで検証します。

## 検証しているケース

`firestore.rules` の全パスについて、認証状態（本人 / 他人 / 未認証）とグループメンバーシップ・所有者判定ごとの
許可・拒否を検証します。

1. **users ツリー（本人のみ）**: 本人は `users/{uid}`・`privates`・`aiUsage` を read/write 可。他人・未認証は拒否。
2. **デバッグユーザーパターン**: `{uid}_debug_{数字}` は本人が操作可。他人の debug user・数字でない suffix は拒否。
3. **groupInvitations**: 認証済みでも read/write 全拒否（Functions Admin SDK 経由のみ）。
4. **inquiries**: 認証済みでも read/write 全拒否（submitInquiry Function 経由のみ）。
5. **groups 本体**: メンバーは read/update/delete 可。create はクライアントから拒否（createGroup Function 経由のみ）。非メンバー・未認証は拒否。
6. **groups/{id}/userProfiles・shoppingLocations**: メンバーは read/write 可。非メンバー・未認証は拒否。
7. **groups/{id}/shoppingLists と items**: メンバーは read/write 可。非メンバーは拒否。
8. **groups/{id}/shoppingLists/{id}/receipts**: メンバーは read/create/update 可。**メンバーでも delete は拒否**。非メンバーは拒否。
9. **groups/{id}/userCategoryAxes**: 現在のグループメンバーが所有する軸は取り込み用に read 可。所有者を `userID` で限定したクエリは許可し、限定しないクエリと削除済みメンバーの残存軸は拒否。create/update/delete は所有者（`userID` 一致）のみ可で、updateによる所有者変更も拒否。
10. **userCategoryAxes/{id}/categories**: 9 と同じく現在のグループメンバーが所有し、親軸が存在して所有者も一致するカテゴリは read 可。所有者を限定しないクエリ、削除済みメンバーの残存カテゴリ、親軸削除後の残存カテゴリは拒否し、write は所有者のみ可。

## 対象外

- `firebase/storage.rules`（Storage のルール）はこのパッケージの検証対象外です。レシート画像等の Storage アクセスは
  Cloud Functions 経由で制御します。
