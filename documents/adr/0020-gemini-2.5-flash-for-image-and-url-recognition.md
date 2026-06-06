# 0020. 画像/URL 認識のモデルに gemini-2.5-flash を採用する

## Status
Accepted

## Context
買い物アイテムを画像・URL から抽出する 2 つの GenKit Function（`generateShoppingListItemsFromImage` / `generateShoppingListItemsFromURL`）と共通の GenKit クライアント（`utils/genkit.ts`）は、これまで `gemini-2.0-flash`（および `gemini-2.0-flash-exp`）を使用していた。

`gemini-2.0-flash` / `gemini-2.0-flash-lite` は **2026-06-01 に deprecated → shutdown** され、本番で次のエラーが発生するようになった。

```
[404 Not Found] This model models/gemini-2.0-flash is no longer available.
Please update your code to use a newer model ...
```

そのため新モデルへの移行が必須となった。要件は「安価」かつ「画像解析（vision 入力）対応」。OpenAI / Gemini の現行モデルを公式価格ページ（2026-06 時点）で比較した。

### 候補の比較（100万トークンあたり USD、画像はトークン課金）

| モデル | 入力 $/1M | 出力 $/1M | 画像入力 | 備考 |
|---|---|---|---|---|
| `gemini-2.5-flash-lite` | 0.10 | 0.40 | ✓ | 全候補で最安 |
| **`gemini-2.5-flash`** | **0.30** | **2.50** | ✓ | flash-lite より一段高精度。採用 |
| `gemini-3.1-flash-lite` | 0.25 | 1.50 | ✓ | 3 系軽量 |
| `gemini-3.5-flash` | 1.50 | 9.00 | ✓ | Google が示す 2.0-flash 後継。高性能だが割高 |
| `gpt-5.4-nano`（OpenAI） | 0.20 | 1.25 | ✓ | OpenAI 最安の vision |
| `gpt-5.4-mini`（OpenAI） | 0.75 | 4.50 | ✓ | — |

公式ソース:
- Gemini API pricing: https://ai.google.dev/gemini-api/docs/pricing
- Gemini API models: https://ai.google.dev/gemini-api/docs/models
- OpenAI API pricing: https://developers.openai.com/api/docs/pricing

## Decision
画像/URL 認識のモデルを **`gemini-2.5-flash`** に統一する。共通クライアントを含む 3 箇所を変更する。

```ts
// firebase/functions/src/functions/utils/genkit.ts
export const ai = genkit({
  plugins: [googleAI()],
  model: "gemini-2.5-flash",
});
```

```ts
// firebase/functions/src/functions/generateShoppingListItemsFromURL/function.ts
const urlRecognitionModel =
  process.env.URL_RECOGNITION_MODEL ?? "googleai/gemini-2.5-flash";
```

```ts
// firebase/functions/src/functions/generateShoppingListItemsFromImage/function.ts
const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
});
```

### 判断基準（なぜ flash-lite ではなく flash か）
- **出力コストはこのタスクではほぼ効かない**: ここでの output（出力トークン）は「抽出された買い物アイテムの一覧（短いテキスト/JSON）」であり、1 回あたり数百トークン規模と小さい。仮に 1 回 600 トークン出力しても `gemini-2.5-flash`（出力 $2.50/1M）で約 $0.0015/回、`flash-lite`（$0.40/1M）で約 $0.00024/回。差は **1 回あたり 0.1 円少々**にとどまる。
- **体験に効くのは抽出精度**: コスト差が無視できる範囲なので、画像/HTML からの抽出精度を優先して一段賢い `gemini-2.5-flash` を選ぶ方が費用対効果が良い。
- **既存スタックの維持**: すでに GenKit + GoogleAI プラグイン構成のため、モデル文字列の差し替えだけで済む（ドロップイン）。OpenAI へ乗り換えるとプラグイン・認証・トークン課金体系の変更で工数が増えるため、今回は Gemini を維持する。
- **`gemini-3.5-flash` は不採用**: Google は 2.0-flash の後継として 3.5-flash を提示するが、$1.50/$9.00 と本タスクには過剰・割高。

## Consequences
- **利点**: 廃止モデル起因の 404 が解消し、抽出精度を確保したまま移行できる。コスト増は出力が小さいため実質軽微。
- **検証**: `npm run lint` / `npm run build`（tsc）/ `npm test`（15 suites・116 tests）すべてパスを確認済み。
- **切り替え余地**: URL 認識は `URL_RECOGNITION_MODEL` 環境変数で上書き可能なまま。コスト最優先に振りたい場合は `gemini-2.5-flash-lite` に、より高精度が必要なら 3 系へ環境変数/定数で変更できる。
- **将来の廃止リスク**: 2.0 系の shutdown と同様、モデルは将来 deprecated になり得る。価格・提供状況は変動が速いため、移行時は必ず公式 pricing/models ページで最新を確認する。

## Related
- ADR 0019: GenKit Dev Server 検証時のみ認証をスキップする
