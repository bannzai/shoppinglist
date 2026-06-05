import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import { DataResponseSchema, ErrorResponseSchema } from "../../entity/response";
import { UserAIUsageData } from "../../entity/ai_usage";
import { defineSecret } from "firebase-functions/params";
import { lookup } from "node:dns/promises";
import { isIP } from "node:net";
import * as https from "node:https";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      shoppingListItems: z.array(z.string()),
    }),
  }),
  ErrorResponseSchema,
]);

/** AI構造化出力のスキーマ。 */
const ShoppingListItemsSchema = z.object({
  shoppingListItems: z.array(z.string()),
});

const googleAIApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/** URL解析に使うモデル。環境変数で切り替え可能。 */
const urlRecognitionModel =
  process.env.URL_RECOGNITION_MODEL ?? "googleai/gemini-2.0-flash";

/** URLの最大文字数。 */
const maxURLLength = 2048;

/** 取得するHTMLの最大バイトサイズ（5MB）。 */
const maxHTMLBytes = 5 * 1024 * 1024;

/** Geminiに送信するHTMLテキストの最大文字数。 */
const maxHTMLCharsForGemini = 100_000;

/** HTMLフェッチのタイムアウト（ミリ秒）。 */
const fetchTimeoutMs = 10_000;

/** 無料ユーザーのURL認識月次上限。 */
const freeMonthlyURLRecognitionLimit = 5;

/** プレミアムユーザーのURL認識月次上限。 */
const premiumMonthlyURLRecognitionLimit = 50;

/** 返却する買い物リストアイテム最大件数。 */
const maxShoppingListItems = 50;

/** 1アイテムあたりの最大文字数。 */
const maxShoppingListItemLength = 100;

/** SSRF対策として拒否するホスト名。 */
const blockedHostnames = new Set(["localhost", "metadata.google.internal"]);

/** プライベートIPアドレスかどうかを判定する。 */
function isPrivateIPAddress(ipAddress: string): boolean {
  if (ipAddress.includes(":")) {
    const normalized = ipAddress.toLowerCase();
    return (
      normalized === "::1" ||
      normalized.startsWith("fc") ||
      normalized.startsWith("fd") ||
      normalized.startsWith("fe80")
    );
  }

  const [a, b] = ipAddress.split(".").map((part) => Number(part));
  if ([a, b].some((v) => Number.isNaN(v))) return true;
  if (a === 10 || a === 127 || a === 0) return true;
  if (a === 169 && b === 254) return true;
  if (a === 172 && b >= 16 && b <= 31) return true;
  if (a === 192 && b === 168) return true;
  if (a === 100 && b >= 64 && b <= 127) return true;
  return false;
}

/** 公開Web向けURLのみ許可し、解決済みIPアドレスを返す。DNS Rebinding対策のため、ここで解決したIPをfetchでも使用する。 */
async function resolveToSafeIP(url: URL): Promise<string | null> {
  const hostname = url.hostname.toLowerCase();
  if (blockedHostnames.has(hostname)) return null;

  if (isIP(hostname)) {
    return isPrivateIPAddress(hostname) ? null : hostname;
  }

  try {
    const resolvedAddress = (await lookup(hostname)).address;
    return isPrivateIPAddress(resolvedAddress) ? null : resolvedAddress;
  } catch {
    return null;
  }
}

/**
 * DNS Rebinding・OOM対策を施したHTMLフェッチ。
 * lookupコールバックで事前解決済みIPを強制し、ストリームでバイト数を制限する。
 */
async function safeFetchHTML({
  targetURL,
  resolvedIP,
}: {
  targetURL: URL;
  resolvedIP: string;
}): Promise<{ ok: true; html: string } | { ok: false; error: string }> {
  return new Promise((resolve) => {
    const agent = new https.Agent({
      lookup: (_hostname, _options, callback) => {
        // DNS Rebinding対策: 事前解決済みIPを強制使用し、再度の名前解決を防ぐ
        callback(null, resolvedIP, resolvedIP.includes(":") ? 6 : 4);
      },
    });

    const req = https.request(
      targetURL.toString(),
      {
        method: "GET",
        agent,
        timeout: fetchTimeoutMs,
        headers: { "User-Agent": "ShoppingListBot/1.0" },
      },
      (res) => {
        if (res.statusCode && (res.statusCode >= 300 && res.statusCode < 400)) {
          req.destroy();
          agent.destroy();
          resolve({ ok: false, error: "リダイレクトは許可されていません" });
          return;
        }
        if (!res.statusCode || res.statusCode < 200 || res.statusCode >= 300) {
          req.destroy();
          agent.destroy();
          resolve({
            ok: false,
            error: `ページの取得に失敗しました（HTTP ${res.statusCode}）`,
          });
          return;
        }
        const contentType = (
          res.headers["content-type"] ?? ""
        ).toLowerCase();
        if (!contentType.includes("text/html")) {
          req.destroy();
          agent.destroy();
          resolve({ ok: false, error: "HTMLページのみ対応しています" });
          return;
        }
        const contentLength = Number(res.headers["content-length"] ?? "0");
        if (contentLength > maxHTMLBytes) {
          req.destroy();
          agent.destroy();
          resolve({ ok: false, error: "ページサイズが大きすぎます" });
          return;
        }

        // OOM対策: ストリームでバイト数を制限しながら読み取る
        const chunks: Buffer[] = [];
        let totalBytes = 0;
        res.on("data", (chunk: Buffer) => {
          totalBytes += chunk.length;
          if (totalBytes > maxHTMLBytes) {
            req.destroy();
            agent.destroy();
            resolve({ ok: false, error: "ページサイズが大きすぎます" });
            return;
          }
          chunks.push(chunk);
        });
        res.on("end", () => {
          agent.destroy();
          resolve({ ok: true, html: Buffer.concat(chunks).toString("utf8") });
        });
        res.on("error", (err) => {
          agent.destroy();
          resolve({ ok: false, error: err.message });
        });
      }
    );

    req.on("timeout", () => {
      req.destroy();
      agent.destroy();
      resolve({ ok: false, error: "タイムアウトしました" });
    });
    req.on("error", (err) => {
      agent.destroy();
      resolve({ ok: false, error: err.message });
    });
    req.end();
  });
}

/** Firebase Auth Custom Claimsからプレミアム判定を行う。 */
async function hasPremiumEntitlement(uid: string): Promise<boolean> {
  try {
    return (await admin.auth().getUser(uid)).customClaims?.["premium"] === true;
  } catch (error) {
    logger.error("hasPremiumEntitlement failed", {
      uid,
      errorName: error instanceof Error ? error.name : "unknown",
    });
    return false;
  }
}

/**
 * URLからWebページを取得し、AIで買い物リストアイテムを生成するFunction。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "url": "https://example.com/recipe/curry"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須
 * - URLはHTTPSのみ、2048文字以下、user:password付きURL不可
 * - SSRF対策: localhost / プライベートIP / リンクローカル宛先を拒否
 * - リダイレクトは追従しない
 * - HTML取得: 5MB以下、10秒タイムアウト
 * - 月次利用上限: 無料5回、プレミアム50回（UTC基準）
 */
const generateShoppingListItemsFromURLFlow = ai.defineFlow(
  {
    name: "generateShoppingListItemsFromURL",
    inputSchema: z.object({
      url: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { url: string }) => {
    const normalizedURL = input.url.trim();

    // 認証チェック（クライアントからの回避を防ぐため Function 側で強制）
    const uid = currentAuthUID();
    if (!uid) {
      return { result: "NG" as const, error: { message: "認証されていません" } };
    }

    // URL検証
    if (!normalizedURL || normalizedURL.length > maxURLLength) {
      return { result: "NG" as const, error: { message: "URLが無効です" } };
    }
    let parsedURL: URL;
    try {
      parsedURL = new URL(normalizedURL);
    } catch {
      return { result: "NG" as const, error: { message: "URLが無効です" } };
    }
    if (parsedURL.protocol !== "https:") {
      return {
        result: "NG" as const,
        error: { message: "HTTPSのURLのみ対応しています" },
      };
    }
    if (parsedURL.username || parsedURL.password) {
      return { result: "NG" as const, error: { message: "URLが無効です" } };
    }
    // DNS Rebinding対策: 名前解決を1回だけ行い、そのIPアドレスをfetchでも使用する
    const resolvedIP = await resolveToSafeIP(parsedURL);
    if (!resolvedIP) {
      return {
        result: "NG" as const,
        error: { message: "指定されたURLにはアクセスできません" },
      };
    }

    // サーバー管理データからプレミアム判定（クライアントの申告値は信用しない）
    const isPremium = await hasPremiumEntitlement(uid);
    const monthlyLimit = isPremium
      ? premiumMonthlyURLRecognitionLimit
      : freeMonthlyURLRecognitionLimit;

    const firestore = admin.firestore();
    const now = new Date();
    const yearMonth = `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;
    const aiUsageRef = firestore
      .collection("users")
      .doc(uid)
      .collection("aiUsage")
      .doc(yearMonth);

    // 上限判定とカウント更新は同一トランザクション内で実施
    // 冪等にしない理由: 月次利用上限を正確に適用するため、上限判定を通過したリクエストごとに1回だけ加算する必要がある。
    const limitCheckResult = await firestore.runTransaction(async (tx) => {
      const aiUsageDoc = await tx.get(aiUsageRef);
      const aiUsageData = aiUsageDoc.data() as UserAIUsageData | undefined;
      if ((aiUsageData?.urlRecognitionCount ?? 0) >= monthlyLimit) {
        return { isLimitReached: true as const };
      }

      if (aiUsageDoc.exists) {
        tx.update(aiUsageRef, {
          urlRecognitionCount: admin.firestore.FieldValue.increment(1),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(aiUsageRef, {
          id: yearMonth,
          userID: uid,
          imageRecognitionCount: 0,
          urlRecognitionCount: 1,
          serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      return { isLimitReached: false as const };
    });

    if (limitCheckResult.isLimitReached) {
      return {
        result: "NG" as const,
        error: {
          message: `URL読み取りの月間利用回数（${monthlyLimit}回）に達しました`,
        },
      };
    }

    try {
      // HTML取得（DNS Rebinding対策 + OOM対策: safeFetchHTMLで解決済みIPを使用し、ストリームでバイト数を制限）
      const fetchResult = await safeFetchHTML({
        targetURL: parsedURL,
        resolvedIP,
      });
      if (!fetchResult.ok) {
        return {
          result: "NG" as const,
          error: { message: fetchResult.error },
        };
      }
      const htmlTextRaw = fetchResult.html;

      // Genkitで構造化出力としてアイテム抽出
      const generation = await ai.generate({
        model: urlRecognitionModel,
        prompt: `以下はWebページのHTMLです。このページから買い物リストに追加すべきアイテム（食材、商品、材料など）を抽出してください。\n\n${htmlTextRaw.slice(0, maxHTMLCharsForGemini)}`,
        output: {
          schema: ShoppingListItemsSchema,
        },
      });
      const parsedOutput = ShoppingListItemsSchema.safeParse(generation.output);
      if (!parsedOutput.success) {
        throw new Error("Invalid model output payload");
      }

      return {
        result: "OK",
        status: 200,
        data: {
          shoppingListItems: parsedOutput.data.shoppingListItems
            .map((item) => item.trim())
            .filter(
              (item) =>
                item.length > 0 && item.length <= maxShoppingListItemLength
            )
            .slice(0, maxShoppingListItems),
        },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error("generateShoppingListItemsFromURL failed", {
        uid,
        yearMonth,
        targetHost: parsedURL.hostname,
        errorName: error instanceof Error ? error.name : "unknown",
      });
      return {
        result: "NG",
        error: {
          message:
            error instanceof Error
              ? error.message
              : "買い物リストの生成に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("generateShoppingListItemsFromURL"),
    secrets: [googleAIApiKey],
  },
  generateShoppingListItemsFromURLFlow
);
