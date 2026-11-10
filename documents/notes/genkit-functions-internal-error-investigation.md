---
scope: repository
recorded: 2026-11-10
---
# GenKit の Functions が `INTERNAL` を返す時は、入力が null でないかと Cloud Logging の実際のエラーを確かめる

Issue #385 の検証中に、`revokePromotionalPremium` がクライアントに `[firebase_functions/internal] INTERNAL` を返した。調べて分かったこと。

- **引数なしの `.call()` は入力が null になる**: Dart の `httpsCallable(...).call()` を引数なしで呼ぶと data が `null` になり、`inputSchema: z.object({})` の検証が `(root): must be object` で失敗する。flow の中の try/catch より手前 (入力の検証) で失敗するため、NG のレスポンスではなく `INTERNAL` になる。引数が無い関数でも `.call(<String, dynamic>{})` で空のオブジェクトを渡す (`lib/utils/functions/firebase_function.dart` の `revokePromotionalPremium` がこの形)
- **実際のエラーは Cloud Logging で読む**: クライアントには `INTERNAL` しか出ない。`gcloud logging read 'resource.labels.service_name="<関数名を小文字にしたもの>" timestamp>="<時刻>"' --project <プロジェクト ID>` で ValidationError などの中身が読める (プロジェクト ID は `firebase/.firebaserc`)。`firebase functions:log` は監査ログが混ざり、時刻も遅れるため向かない
- **デプロイされているコードの版の見分け方**: インスタンスの起動時のログに、secret を持たない関数ごとの警告 `Genkit function for X is not bound to any secret` が全関数ぶん出る。版の間で関数の追加・削除がある時は、この関数名の一覧で、どの版のコードがデプロイされているかを見分けられる (関数の中身だけを変えた版どうしは、一覧が同じになるため見分けられない)

**なぜ:** `INTERNAL` は原因を示さないため、クライアントのログだけでは flow の中の失敗か入力の検証の失敗かを区別できない。

**どう使う:** `INTERNAL` が返ったら、(1) 呼び出しの引数が null になっていないかを見る、(2) Cloud Logging で実際のエラーを読む、(3) 直したはずなのに変わらない時は、関数を足した・消した変更なら起動時の警告の関数名の一覧でデプロイされている版を確かめる。
