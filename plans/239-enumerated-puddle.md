# Plan: Issue #239 - Premium 動作確認を Promotional Entitlement + デバッグ機能経由に切り替える

参考: [Issue #239](https://github.com/bannzai/shoppinglist/issues/239), [Issue #237](https://github.com/bannzai/shoppinglist/issues/237), [ADR 0010](../documents/adr/0010-paywall-ui-and-iap-e2e-flows.md)

## Context

### なぜこの変更が必要か
Issue #237 の調査で、Maestro の課金 E2E（`shared/mock_purchase.yaml` 経由で iOS Test Store mock purchase modal を承認する方式）が flaky であることが判明した。原因と背景:

- iOS Test Store mock purchase modal の自動操作 + 後続 Settings 画面 navigation が iOS バージョン・modal 文言（"Subscribe" / "Test valid purchase"）変更に依存し脆弱
- 直近の Maestro 検証で `iap_purchase_*` 3 本 + `premium_ai_image_recognition` + `premium_ai_url_recognition` + `category_location_order_non_premium` の 6/15 だけが通り、残る 9 本（`premium_*.yaml`）は Settings 画面 scroll 状態引き継ぎ等の flow 設計問題で失敗
- そもそも StoreKit / 課金 modal を踏ませる前提の E2E は long-term で保守性が低い
- shoppinglist には既に `grantPromotionalPremium` onCall（`firebase/functions/src/functions/grantPromotionalPremium/function.ts`）と開発者オプション画面の「プレミアム付与（1日）」ボタン（`lib/features/developer_options/page.dart:166-183`）が実装済みで、RC v1 Promotional Entitlement を直接付与できる状態

### 意図する成果
- **IAP 3 flow**（`iap_purchase_monthly` / `_annual` / `_lifetime`）は **mock_purchase 経由のまま残し**、実購入動線の E2E カバレッジを維持する
- **`premium_*.yaml` 11 本**は新設の `shared/grant_premium_via_debug.yaml` に統一し、課金 modal を踏まずに Promotional Entitlement を付与してプレミアム機能を assert する形に切り替える
- 「プレミアム剥奪」も同経路で実装し、テスト後のクリーンアップ・状態切替が可能になる
- 既存の `grantPromotionalPremium` onCall と新設の `revokePromotionalPremium` onCall に Jest テストを追加し、回帰検知を強化する
- ADR 0010 の Follow-up セクションを更新し、Issue #237 root cause（Test Store Base price 未設定）と方針転換を明文化する

### 既存実装を再利用する箇所
- `firebase/functions/src/functions/grantPromotionalPremium/function.ts`（既存実装、テスト追加のみ）
- `lib/features/developer_options/page.dart` の `_ActionTile` / `_execute`（既存。新規 revoke ボタンは同パターン流用）
- `lib/utils/functions/firebase_function.dart` の `grantPromotionalPremium()` extension method（既存。`revokePromotionalPremium()` を同パターンで追加）
- `maestro/flows/shared/open_developer_options.yaml`（既存。`grant_premium_via_debug.yaml` から `runFlow` で呼ぶ）
- `firebase/functions/src/functions/createGroup/function.test.ts`（テスト雛形）

## 実装内容

### 1. Firebase Functions: `revokePromotionalPremium` onCall を新設

ファイル: `firebase/functions/src/functions/revokePromotionalPremium/function.ts`（新規）

`grantPromotionalPremium/function.ts` と同形で v1 Promotional API の revoke エンドポイントを呼ぶ。`appEnv() === "dev"` ガード + `appAuthPolicy` を踏襲。

```typescript
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import { defineString } from "firebase-functions/params";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import { appEnv } from "../../core/env";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/// RevenueCat Secret API Key。Promotions API の revoke 呼び出しに使用する。
const REVENUECAT_SECRET_API_KEY = defineString("REVENUECAT_SECRET_API_KEY");

/// RevenueCat のプレミアム Entitlement 識別子。
const PREMIUM_ENTITLEMENT_IDENTIFIER = "Premium";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      success: z.boolean(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: {}
const revokePromotionalPremiumFlow = ai.defineFlow(
  {
    name: "revokePromotionalPremium",
    inputSchema: z.object({}),
    outputSchema: ResponseSchema,
  },
  async () => {
    try {
      // 開発環境でのみ実行可能。本番環境での運用ミスを防止する。
      if (appEnv() !== "dev") {
        return {
          result: "NG" as const,
          error: { message: "この機能は開発環境でのみ使用できます" },
        };
      }

      const uid = ai.currentContext()?.auth?.uid;
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      // RevenueCat v1 Promotions API: 当該ユーザーに付与済みの Promotional Entitlement
      // を即時取り消す。実購入由来の Entitlement には影響しない。
      const revenueCatResponse = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${uid}/entitlements/${PREMIUM_ENTITLEMENT_IDENTIFIER}/revoke_promotionals`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${REVENUECAT_SECRET_API_KEY.value()}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!revenueCatResponse.ok) {
        const errorBody = await revenueCatResponse.text();
        logger.error(
          `RevenueCat Revoke Promotions API error: ${revenueCatResponse.status} ${errorBody}`
        );
        return {
          result: "NG" as const,
          error: {
            message: `RevenueCat APIエラー: ${revenueCatResponse.status}`,
          },
        };
      }

      logger.info(`Revoked promotional premium from ${uid}`);

      return {
        result: "OK" as const,
        data: { success: true },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "プレミアムの剥奪に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("revokePromotionalPremium"),
  },
  revokePromotionalPremiumFlow
);
```

### 2. Firebase Functions: `index.ts` に revoke を export 追加

ファイル: `firebase/functions/src/index.ts`（既存末尾に追記）

既存パターン（`FUNCTION_NAME` 一致条件付き require）に揃える。

```typescript
if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "revokePromotionalPremium"
) {
  exports.revokePromotionalPremium = require("./functions/revokePromotionalPremium/function");
}
```

### 3. Firebase Functions: `grantPromotionalPremium` のテスト新設

ファイル: `firebase/functions/src/functions/grantPromotionalPremium/function.test.ts`（新規）

`createGroup/function.test.ts` のモック構成（`firebase-admin` / `genkit` / `firebase-functions/https` / `authPolicy` / `firebase-functions(logger)` / `firebase-functions/params`）を踏襲し、`global.fetch` と `appEnv` を追加でモックする。

```typescript
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: { duration?: string }) => Promise<any>;

jest.mock("../utils/genkit", () => ({
  ai: {
    defineFlow: (_config: any, fn: any) => {
      capturedFlowFn = fn;
      return fn;
    },
    currentContext: mockCurrentContext,
  },
}));

jest.mock("firebase-functions/https", () => ({
  onCallGenkit: (_opts: any, flow: any) => flow,
}));

jest.mock("../utils/authPolicy", () => ({
  appAuthPolicy: jest.fn(() => () => true),
}));

jest.mock("firebase-functions", () => ({
  logger: { info: jest.fn(), error: jest.fn() },
}));

jest.mock("firebase-functions/params", () => ({
  defineString: jest.fn(() => ({ value: () => "test-secret-key" })),
}));

const mockAppEnv = jest.fn(() => "dev");
jest.mock("../../core/env", () => ({
  appEnv: () => mockAppEnv(),
}));

const originalFetch = global.fetch;
const mockFetch = jest.fn();
beforeEach(() => {
  jest.clearAllMocks();
  mockAppEnv.mockReturnValue("dev");
  (global as any).fetch = mockFetch;
});
afterAll(() => {
  (global as any).fetch = originalFetch;
});

require("./function");

describe("grantPromotionalPremium", () => {
  test("正常系: dev 環境で認証済みユーザーに付与できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({
      ok: true,
      status: 200,
      text: async () => "",
    });
    const result = await capturedFlowFn({ duration: "daily" });
    expect(result.result).toBe("OK");
    expect(result.data.success).toBe(true);
    expect(mockFetch).toHaveBeenCalledWith(
      "https://api.revenuecat.com/v1/subscribers/user-1/entitlements/Premium/promotional",
      expect.objectContaining({
        method: "POST",
        headers: expect.objectContaining({
          Authorization: "Bearer test-secret-key",
        }),
        body: JSON.stringify({ duration: "daily" }),
      })
    );
  });

  test("異常系: prod 環境では実行できない", async () => {
    mockAppEnv.mockReturnValue("prod");
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    const result = await capturedFlowFn({ duration: "daily" });
    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("開発環境でのみ");
    expect(mockFetch).not.toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーが弾かれる", async () => {
    mockCurrentContext.mockReturnValue(undefined);
    const result = await capturedFlowFn({ duration: "daily" });
    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
    expect(mockFetch).not.toHaveBeenCalled();
  });

  test("異常系: RevenueCat API がエラーを返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({
      ok: false,
      status: 404,
      text: async () => "Not found",
    });
    const result = await capturedFlowFn({ duration: "daily" });
    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("RevenueCat APIエラー: 404");
  });
});
```

### 4. Firebase Functions: `revokePromotionalPremium` のテスト新設

ファイル: `firebase/functions/src/functions/revokePromotionalPremium/function.test.ts`（新規）

3 のテストとほぼ同形。エンドポイント URL（`/revoke_promotionals`）と body の有無のみ差異。

```typescript
// 上記 grant のモック構成を流用
require("./function");

describe("revokePromotionalPremium", () => {
  test("正常系: dev 環境で剥奪できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({ ok: true, status: 200, text: async () => "" });
    const result = await capturedFlowFn({});
    expect(result.result).toBe("OK");
    expect(mockFetch).toHaveBeenCalledWith(
      "https://api.revenuecat.com/v1/subscribers/user-1/entitlements/Premium/revoke_promotionals",
      expect.objectContaining({ method: "POST" })
    );
  });

  test("異常系: prod 環境では実行できない", async () => {
    mockAppEnv.mockReturnValue("prod");
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    const result = await capturedFlowFn({});
    expect(result.result).toBe("NG");
  });

  test("異常系: 未認証ユーザーが弾かれる", async () => {
    mockCurrentContext.mockReturnValue(undefined);
    const result = await capturedFlowFn({});
    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: RevenueCat API エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({ ok: false, status: 500, text: async () => "Internal" });
    const result = await capturedFlowFn({});
    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("RevenueCat APIエラー: 500");
  });
});
```

### 5. Flutter: `firebase_function.dart` に `revokePromotionalPremium()` 追加

ファイル: `lib/utils/functions/firebase_function.dart`（既存に追加。`grantPromotionalPremium` の直後）

```dart
/// RevenueCat Promotions API 経由で付与済みのプレミアム Entitlement を剥奪する。
/// 開発者オプションでのテスト用（実購入由来の Entitlement には影響しない）。
Future<void> revokePromotionalPremium() async {
  final result = await httpsCallable('revokePromotionalPremium').call();
  debugPrint('revokePromotionalPremium.result: ${result.data}');
  final response = mapToJSON(result.data);
  if (response['result'] != 'OK') {
    throw Exception(response['error']['message']);
  }
}
```

### 6. Flutter: 開発者オプションに「プレミアム剥奪」ボタン追加

ファイル: `lib/features/developer_options/page.dart`（line 184 付近、「プレミアム付与（1日）」直下に追加）

`_ActionTile` + `_execute` の既存パターンをそのまま流用。剥奪後も RC SDK の `customerInfo` を refetch する。

```dart
// プレミアム付与の _ActionTile 直後（line 184 の `const Divider(height: 24),` の前）に追加

_ActionTile(
  title: 'プレミアム剥奪',
  subtitle: 'RC Promo経由で付与したプレミアムEntitlementを取り消す（dev環境のみ）',
  icon: Icons.star_border,
  isProcessing: isProcessing.value,
  onTap: () => _execute(
    isProcessing: isProcessing,
    resultMessage: resultMessage,
    action: () async {
      await functions.revokePromotionalPremium();
      // RC SDK の customerInfo を refetch してプレミアム状態を反映する
      await Purchases.getCustomerInfo();
      ref.invalidate(customerInfoProvider);
    },
    actionName: 'プレミアム剥奪',
  ),
),
```

### 7. Flutter: `purchase.dart` に Issue #237 経緯コメント追記

ファイル: `lib/utils/purchase/purchase.dart`（`initializePurchase` の `kDebugMode` 切替コメント周辺、line 180 直前に挿入）

Issue 本文では「`offeringsProvider` の retry / `initializePurchase` の barrier」と記載されているが、現在のコードに retry / barrier ロジックは存在しない。代わりに `kDebugMode` 切替コメントブロックの直前に方針転換の経緯を追記する。

```dart
// Issue #237 (https://github.com/bannzai/shoppinglist/issues/237) /
// Issue #239 (https://github.com/bannzai/shoppinglist/issues/239) 経緯:
// iOS Test Store mock purchase modal 経由の Maestro E2E (`shared/mock_purchase.yaml`)
// が long-term で flaky なため、`premium_*.yaml` の動作確認は
// `shared/grant_premium_via_debug.yaml` 経由（開発者オプション画面の「プレミアム付与
// （1日）」ボタンから RC Promotional Entitlement を直接付与）に切り替えた。
// `iap_purchase_*.yaml` のみ実購入動線検証として mock_purchase を踏み続ける。
Future<void> initializePurchase() async {
  // ...既存実装
}
```

### 8. Maestro: `shared/grant_premium_via_debug.yaml` を新設

ファイル: `maestro/flows/shared/grant_premium_via_debug.yaml`（新規）

`virtual_pairing/02_create_debug_user.yaml` と同型。`open_developer_options.yaml` を呼んで「プレミアム付与（1日）」ボタンをタップ → `extendedWaitUntil` で `_execute` の完了メッセージ「プレミアム付与 完了」を確認 → Back で設定タブに戻る。

```yaml
appId: com.bannzai.shoppinglist
---
# 開発者オプション画面 → 「プレミアム付与（1日）」ボタンタップ → 完了確認の共通サブフロー。
#
# 経緯:
# Issue #237 (https://github.com/bannzai/shoppinglist/issues/237) で iOS Test Store
# mock purchase modal 経由の Maestro E2E が flaky と判明したため、
# Issue #239 (https://github.com/bannzai/shoppinglist/issues/239) で
# `premium_*.yaml` の前段プレミアム化は本フロー（RC Promotional Entitlement の直接付与）
# に切り替えた。`shared/mock_purchase.yaml` は `iap_purchase_*.yaml` の実購入検証専用として残す。
#
# 実装位置: `lib/features/developer_options/page.dart` の「プレミアム付与（1日）」ボタン
# (`_ActionTile` + `_execute` パターン)。`functions.grantPromotionalPremium(duration: 'daily')`
# を呼んで `customerInfoProvider` を invalidate する。
#
# Flutter ListTile の title/subtitle が 1 つのセマンティクス要素にマージされるため
# `assertVisible` の text 単独マッチが iOS で不安定。`extendedWaitUntil` + 部分一致
# regex で安定化する。

- runFlow: open_developer_options.yaml

- extendedWaitUntil:
    visible: "プレミアム付与（1日）"
    timeout: 10000
- tapOn: "プレミアム付与（1日）"

# `_execute` が完了時に resultMessage.value = '$actionName 完了' を表示する。
- extendedWaitUntil:
    visible: "プレミアム付与 完了"
    timeout: 30000

# 設定タブに戻る（呼び出し元の premium_*.yaml が設定タブから機能画面に進める前提）
- tapOn: "Back"
- waitForAnimationToEnd
```

### 9. Maestro: `premium_*.yaml` 11 本の書き換え

10 本（mock_purchase 呼び出しあり）は `runFlow` 行を置換。1 本（`premium_category_location_order.yaml`、現状 mock_purchase 未呼び出し）は `anonymous_sign_in` 直後に `grant_premium_via_debug.yaml` を挿入。

#### 9-A. mock_purchase を呼んでいる 10 本の置換

対象ファイル:
- `maestro/flows/premium_ai_image_recognition.yaml`
- `maestro/flows/premium_ai_url_recognition.yaml`
- `maestro/flows/premium_export_shopping_list.yaml`
- `maestro/flows/premium_group_creation.yaml`
- `maestro/flows/premium_item_photo_attachment.yaml`
- `maestro/flows/premium_location_reminder.yaml`
- `maestro/flows/premium_shopping_list_display_period.yaml`
- `maestro/flows/premium_shopping_list_limit.yaml`
- `maestro/flows/premium_shopping_list_limit_duplicate.yaml`
- `maestro/flows/premium_theme_color_setting.yaml`

各ファイルで:

```yaml
- runFlow: shared/anonymous_sign_in.yaml
- runFlow: shared/mock_purchase.yaml
```

を以下に置換:

```yaml
- runFlow: shared/anonymous_sign_in.yaml
- runFlow: shared/grant_premium_via_debug.yaml
```

`grant_premium_via_debug.yaml` 末尾の `tapOn: "Back"` で設定タブに戻る前提のため、各 premium フローの「設定タブ → 機能画面に遷移」ステップ（`tapOn: "設定.*"` 等）はそのまま機能する。

#### 9-B. `premium_category_location_order.yaml` の挿入

ファイル: `maestro/flows/premium_category_location_order.yaml`（line 7 付近に runFlow を 1 行追加）

現状 ADR 0010 line 84 の通り中身は non_premium 仕様（カテゴリ・ロケーション設定のみ）だが、Issue #239 の方針（11 本すべて grant 経路に揃える）を優先し `grant_premium_via_debug.yaml` を挿入してプレミアム化する。中身（ロケーション別ソート assert 等の本格的な premium 検証）は ADR 0010 #84 follow-up で別途対応する。

```yaml
- runFlow: shared/anonymous_sign_in.yaml
- runFlow: shared/grant_premium_via_debug.yaml  # ← 追加
```

### 10. ADR 0010 Follow-up セクション更新

ファイル: `documents/adr/0010-paywall-ui-and-iap-e2e-flows.md`（既存 line 81-85 の Follow-up を更新）

```markdown
### Follow-up
- ✅ Issue #237 root cause（Test Store の Subscription "Premium" に Base price 未設定で
  GetOfferingsOperation が空を返す）が判明し、Test Store 設定を修正済み（Issue #237 で対応完了）
- ✅ `premium_*.yaml` 11 本は Issue #239 で `shared/grant_premium_via_debug.yaml` 経由
  （RC Promotional Entitlement を開発者オプションから直接付与）に方針転換。
  `iap_purchase_*.yaml` 3 本のみ実購入動線検証として `shared/mock_purchase*.yaml` を踏み続ける
- ✅ `revokePromotionalPremium` onCall を Issue #239 で追加。テスト後のクリーンアップに使用
- mock purchase modal の `tapOn` 対象（暫定 `"Subscribe"`）は実機調査で確定し、必要なら iOS / Android で platform 別サブフローに分離（`iap_purchase_*.yaml` のみで使用）
- `maestro/flows/premium_category_location_order.yaml` のロケーション別ソート assert
  実装は別 Issue。本 Issue では `grant_premium_via_debug` 経由でプレミアム化のみ揃えた
- ペイウォール UI のデザイン拡充（コンバージョン視点）は paywall-design skill ベースで別 Issue
```

## 検証

### 自動テスト
- `cd firebase/functions && npm run lint` パス
- `cd firebase/functions && npm run build` 成功
- `cd firebase/functions && npm test` 全件パス（grant / revoke の test.ts 追加分含む）
- リポジトリルート `flutter analyze` エラーなし
- `flutter test`（変更がリポジトリ内で `purchase.dart` 等のテストに影響しないことを確認）
- `dart run build_runner build`（`purchase.g.dart` 等の再生成が不要か確認、新規 Provider は追加しない予定）

### Maestro E2E

iPhone 16 Plus シミュレータで以下を実行（dev 環境ビルド）:

1. `maestro test maestro/flows/shared/grant_premium_via_debug.yaml`
   - 単体で開発者オプション → 「プレミアム付与（1日）」 → 「プレミアム付与 完了」 → Back が成功することを確認
2. 書き換えた `premium_*.yaml` のうち代表 3 本を実行:
   - `maestro test maestro/flows/premium_theme_color_setting.yaml`
   - `maestro test maestro/flows/premium_shopping_list_limit.yaml`
   - `maestro test maestro/flows/premium_ai_image_recognition.yaml`
3. `iap_purchase_monthly.yaml` が **mock_purchase 経路のまま** 通ることを確認（リグレッション検証）

### 手動動作確認
- dev ビルドで開発者オプションを開き「プレミアム剥奪」ボタンを押下
  → 結果メッセージ「プレミアム剥奪 完了」が表示され、`Premium(RC)` が `false` に切り替わる
- 「プレミアム付与（1日）」→「プレミアム剥奪」を順に実行し、`customerInfoProvider` が即時反映されることを確認
- prod ビルド（`appEnv() !== "dev"`）で `revokePromotionalPremium` を呼ぶと「この機能は開発環境でのみ使用できます」が返る（GenKit Web UI で検証）

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している（`grantPromotionalPremium` ・`createGroup/function.test.ts` ・`virtual_pairing/02_create_debug_user.yaml` 流用）

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新（新規 Provider を増やさない予定だが念のため）
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（既存 page.dart 操作のため新規 widget test は不要、Maestro E2E でカバー）
- [ ] Maestro E2E: `shared/grant_premium_via_debug.yaml` 新設 + `premium_*.yaml` 11 本書き換え後に代表 3 本 + `iap_purchase_monthly.yaml` 実行
- [ ] Entity命名: フィールド名が省略されていない（新規 Entity なし）
- [ ] DB操作: Firestore 書き込みなし（RC API 呼び出しのみ）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（`revokePromotionalPremium()` は引数なし）
- [ ] ref使い分け: build内は `ref.watch`、コールバックは `ref.read`（既存 page.dart は `ref.invalidate(customerInfoProvider)` で揃っている）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当なし）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `npm run lint` パス（firebase/functions/ で実行）
- [ ] ビルド: `npm run build` 成功
- [ ] テスト: `npm test` 全件パス（grant / revoke の test.ts 含む）
- [ ] クライアント呼び出し関数は GenKit (`onCallGenkit`) で定義
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない
- [ ] 新規・変更機能に対するテストが存在する（grant 既存実装のテスト追加 + revoke 新設に伴うテスト新設）

### 共通
- [ ] エラーメッセージはそのまま表示（`e.toString()` 加工なし、`firebase_function.dart` の既存パターン踏襲）
- [ ] 各ファイル冒頭/該当箇所に Issue #237 / #239 へのリンクを含むコメントを追記
- [ ] ADR 0010 Follow-up セクションに方針転換と revoke onCall 追加を明記
