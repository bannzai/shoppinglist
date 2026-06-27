# 0031. Cloud Functions の region を asia-northeast1 に統一し Firestore/Storage とコロケーションする

## Status
Accepted

## Context
Cloud Functions（GenKit / `onCallGenkit`）が region 未指定のまま Firebase Functions のデフォルトである `us-central1`（米アイオワ）にデプロイされていた。一方で Firestore（default DB）と Cloud Storage（`*.firebasestorage.app`）は `asia-northeast1`（東京）にある。

この分散構成により、米国の Functions が東京の Firestore / Storage を読み書きするクロスリージョン通信が発生していた。画像アップロード（Storage 連携）や Firestore 書き込みのたびに往復レイテンシと下りリージョン間通信費が乗る。

`us-central1` に乗っていたのは技術的制約ではなく、region を明示指定しておらず Firebase Functions のデフォルトに落ちていただけだった（クライアント側には「Genkit は us-central1 にしか対応していない」という誤ったコメントも残っていた）。

リリース前であり、利用者影響なくデプロイ構成を変更できる今のうちに是正する判断が必要になった。なお当プロジェクトは dev/prod を別 Firebase プロジェクトに分離しており（[0030](0030-separate-dev-prod-firebase-projects.md)）、Firestore の region 構成も明示管理している（[0028](0028-dev-environment-firestore-named-database.md)）ため、Functions の region も同様に明示管理の対象とするのが一貫している。

## Decision
全 Functions を `asia-northeast1`（東京）にデプロイし、Firestore / Storage とコロケーションする。

- Firebase Functions 側（`firebase/functions/src/index.ts`）のエントリで `setGlobalOptions({ region: "asia-northeast1" })` を呼び、全関数に共通適用する。個別の `onCallGenkit` に毎回 region を書くより Single Source of Truth になる。`setGlobalOptions` は各 function モジュールの `require` より前に評価される必要があるため、エントリ最上部に置く。
- クライアント側（`lib/utils/functions/firebase_function.dart`）の `FirebaseFunctions.instanceFor(region: ...)` も `asia-northeast1` に合わせる。Functions と client の region がズレると `httpsCallable` が解決できず呼び出しが失敗するため、必ず同時に変更する。

### 検討した代替案
1. **`us-central1` のまま据え置き**: クロスリージョンのレイテンシ・通信費が継続するため不採用。
2. **各 `onCallGenkit` の opts に個別で `region` を指定**: 17関数すべてに同じ値を重複記述することになり SSOT に反する。これは「`setGlobalOptions` の region が gen2 で反映されない既知の事象（firebase/firebase-functions#1502）」が起きた場合のフォールバック手段として位置づけ、主たる手段にはしない。

### 前提
AI 呼び出しは `googleAI()`（Gemini Developer API / API キー認証、`generativelanguage.googleapis.com` のグローバルエンドポイント）であり Vertex AI ではない。したがって Functions の region を変えてもモデル呼び出しは壊れない。

## Consequences
### 良い点
- Functions ↔ Firestore / Storage がすべて `asia-northeast1` に揃い、クロスリージョン往復が排除される。レイテンシとリージョン間通信費が削減される。
- region 指定が `setGlobalOptions` の1箇所に集約され、新しい関数を追加しても自動的に東京リージョンになる。

### 悪い点・トレードオフ・注意点
- gen2 関数は region をインプレース変更できない。`firebase deploy` は region 変更を検知し、新 region への作成 + 旧 `us-central1` 関数の削除を行う。デプロイ時に削除プロンプトの承認が必要。
- デプロイは dev → prod の順で行い、各デプロイ後に `gcloud functions list` で全関数の region が `asia-northeast1` になっていること、旧 `us-central1` 関数が残っていないことを必ず確認する。`setGlobalOptions` の region が反映されない場合は上記フォールバック（個別 region 指定）に切り替える。
- クライアントと Functions の region は常に一致させる必要がある。今後 region を変える場合は両方を同時に変更する。

## 参考
- Issue #456
- https://firebase.google.com/docs/functions/locations
- https://genkit.dev/docs/firebase/
- firebase/firebase-functions#1502（setGlobalOptions の region 適用に関する既知の注意点）
