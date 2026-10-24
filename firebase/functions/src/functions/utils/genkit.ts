import { genkit } from "genkit";
import { googleAI } from "@genkit-ai/googleai";

export const ai = genkit({
  plugins: [googleAI()],
  // Gemini を呼ぶ Functions のモデル選定の根拠 (Issue #703)。
  // 商品名の抽出・カテゴリ分類は軽いタスクで、gemini-2.5-flash
  // (入力 $0.30 / 出力 $2.50 per 1M tokens) は過剰なため Flash-Lite 系に下げる。
  // 最安の gemini-2.5-flash-lite (入力 $0.10 / 出力 $0.40) は dev の API キーで
  // 「no longer available to new users」の 404 になった (2026-10-24 実測) ため、
  // 次に安い gemini-3.1-flash-lite (入力 $0.25 / 出力 $1.50) を使う。
  // gemini-3.5-flash-lite は 2.5 Flash と同額で節約にならない。
  // 出典: https://ai.google.dev/gemini-api/docs/pricing (2026-10-23 時点の Standard paid tier)
  // gemini-3.1-flash-lite は 2027-05-07 に shutdown 予定のため、それまでに移行先を決める。
  // 出典: https://ai.google.dev/gemini-api/docs/deprecations
  model: "gemini-3.1-flash-lite",
});
