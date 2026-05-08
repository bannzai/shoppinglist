# Issue #241: Maestro E2E 既存問題 + dev/prod 環境分離 後続タスク

## Context

PR #240（Issue #239）でプレミアム動作確認を Promotional Entitlement 経由に切り替えた際に判明した 4 つの既存問題を修正する。

- Task 1・2・4: Maestro フロー修正（軽量）
- Task 3: Firebase dev/prod 分離は**本 Issue のスコープ外**とし、別 Issue に分離する

---

## Task 1: `premium_shopping_list_limit.yaml` / `_duplicate.yaml` のメニュー操作問題

**原因**: 実装で確認した結果、現状の UI には「リスト名」TextField を持つダイアログは存在しなかった。「買い物リストを追加」（PopupMenuItem）をタップすると BottomSheet が開き、その中の「買い物リストを追加」ListTile を再度タップすることで（名前なしの）新規リストが作成される。元のフローは存在しない UI を期待していたため毎回失敗していた。

**修正方針**: `tapOn: "リスト名"` / `inputText` / `tapOn: "追加"` の 3 ステップを削除し、「買い物リストを追加」を 2 回タップする（PopupMenuItem → BottomSheet ListTile）構造に変更する。BottomSheet の出現確認には「現在の買い物リストを複製」（BottomSheet 内の別 ListTile）を使う。

### `maestro/flows/premium_shopping_list_limit.yaml`

```yaml
- repeat:
    times: 6
    commands:
      - tapOn: "メニュー"
      - waitForAnimationToEnd
      - tapOn: "買い物リストを追加"
      - extendedWaitUntil:
          visible: "現在の買い物リストを複製"
          timeout: 5000
      - tapOn: "買い物リストを追加"
      - waitForAnimationToEnd
```

### `maestro/flows/premium_shopping_list_limit_duplicate.yaml`

repeat ブロック（5 回）と末尾の複製ステップも同様に BottomSheet を経由する形に修正:

```yaml
- repeat:
    times: 5
    commands:
      - tapOn: "メニュー"
      - waitForAnimationToEnd
      - tapOn: "買い物リストを追加"
      - extendedWaitUntil:
          visible: "現在の買い物リストを複製"
          timeout: 5000
      - tapOn: "買い物リストを追加"
      - waitForAnimationToEnd

# 6 個目を複製で作成
- tapOn: "メニュー"
- waitForAnimationToEnd
- tapOn: "買い物リストを追加"
- extendedWaitUntil:
    visible: "現在の買い物リストを複製"
    timeout: 5000
- tapOn: "現在の買い物リストを複製"
- waitForAnimationToEnd
```

---

## Task 2: `iap_purchase_*.yaml` の mock_purchase modal flaky 問題

**原因**: iOS 18.5 シミュレータの RC Test Store mock purchase modal で "Subscribe" ボタンのテキスト/アクセシビリティ ID が変わっている可能性がある。

**修正方針**: 実装フェーズでシミュレータを起動し `maestro hierarchy` で実際の UI 要素を確認し、正確な text/id に更新する。

### 調査手順（実装フェーズで実行）

```bash
# 1. アプリを起動して PaywallPage まで遷移
# 2. 「購入」ボタンをタップして mock modal が出た瞬間に実行
maestro hierarchy
```

### 修正対象ファイル（調査結果を反映）

- `maestro/flows/shared/mock_purchase.yaml`
- `maestro/flows/shared/mock_purchase_annual.yaml`
- `maestro/flows/shared/mock_purchase_lifetime.yaml`

**調査結果**: iOS 18.5 シミュレータ上の RC Test Store mock purchase modal は "Test Purchase" タイトルの Alert で、ボタンは `"Test valid purchase"` / `"Test failed purchase"` / `"Cancel"` の 3 種だった。"Subscribe" は存在しない。

**変更後**: `"Subscribe"` → `"Test valid purchase"` に置換（3 ファイル共通）。

```yaml
- extendedWaitUntil:
    visible: "Test valid purchase"
    timeout: 30000
- tapOn: "Test valid purchase"
```

加えて `iap_purchase_*.yaml` の最終アサーション `assertVisible: "プレミアム会員"` / `"有効"` は ListTile の title/subtitle が iOS Semantics merge により単一要素 `"プレミアム会員\n有効"` になっているため、regex を使って部分一致で確認するよう変更:

```yaml
- assertVisible:
    text: ".*プレミアム会員.*"
- assertVisible:
    text: ".*有効.*"
```

---

## Task 3: Firebase dev/prod 環境分離（スコープ外）

**方針**: 本 Issue では実装しない。以下の GitHub 操作のみ行う。

1. **新規 Issue を作成**: タイトル「Firebase dev 環境構築（コード・スクリプト自動化）」、内容はコード・スクリプトで dev Firebase プロジェクトを作成・切替できる仕組みを整備する
2. **Issue #241 にコメント追記**: 「Task 3 (Firebase dev/prod 分離) は別 Issue に分離し、本 Issue のスコープ外とする」旨を記載

---

## Task 4: `premium_category_location_order.yaml` のロケーション別ソート assert 実装

### 設計方針

- `GroupCategoryPage`（ロケーション別 order 設定 UI）は production アプリから到達不可能
- Firebase Functions にデバッグ専用 Function `setupTestCategoryLocationOrder` を追加し、developer_options から呼び出してテストデータを設定する
- Maestro フローでは「肉」を `locationOrders[テストスーパーID] = 0`、「野菜」を `locationOrders[テストスーパーID] = 1` にセット（デフォルト order の逆順）し、買い物リストで「肉」→「野菜」の順に表示されることを assert する

### 4-A: Firebase Functions 新規追加

**ファイル**: `firebase/functions/functions/src/functions/setupTestCategoryLocationOrder/function.ts`

Firestore パス:
- Category Axes: `/groups/{groupID}/userCategoryAxes/{axisID}`
- Categories: `/groups/{groupID}/userCategoryAxes/{axisID}/categories/{categoryID}`
- Shopping Locations: `/groups/{groupID}/shoppingLocations/{locationID}`

```typescript
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import { appEnv } from "../../core/env";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";
import admin from "firebase-admin";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({ success: z.boolean() }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "groupID": "<groupID>", "locationName": "テストスーパー", "firstCategoryName": "肉", "secondCategoryName": "野菜" }
const setupTestCategoryLocationOrderFlow = ai.defineFlow(
  {
    name: "setupTestCategoryLocationOrder",
    inputSchema: z.object({
      groupID: z.string(),
      locationName: z.string(),
      firstCategoryName: z.string(),
      secondCategoryName: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async ({ groupID, locationName, firstCategoryName, secondCategoryName }) => {
    try {
      if (appEnv() !== "dev") {
        return {
          result: "NG" as const,
          error: { message: "この機能は開発環境でのみ使用できます" },
        };
      }

      const context = ai.currentContext();
      const uid = context?.auth?.uid;
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      const firestore = admin.firestore();

      // userCategoryAxes の先頭 1 件を取得
      const axesSnap = await firestore
        .collection(`groups/${groupID}/userCategoryAxes`)
        .limit(1)
        .get();
      if (axesSnap.empty) {
        return {
          result: "NG" as const,
          error: { message: "userCategoryAxes が見つかりません" },
        };
      }
      const axisID = axesSnap.docs[0].id;

      // カテゴリを全件取得して名前で検索
      const categoriesSnap = await firestore
        .collection(`groups/${groupID}/userCategoryAxes/${axisID}/categories`)
        .get();
      const firstCategoryDoc = categoriesSnap.docs.find(
        (d) => d.data().name === firstCategoryName
      );
      const secondCategoryDoc = categoriesSnap.docs.find(
        (d) => d.data().name === secondCategoryName
      );
      if (!firstCategoryDoc || !secondCategoryDoc) {
        return {
          result: "NG" as const,
          error: {
            message: `カテゴリが見つかりません: ${firstCategoryName}, ${secondCategoryName}`,
          },
        };
      }

      // 買い物場所を名前で検索
      const locationsSnap = await firestore
        .collection(`groups/${groupID}/shoppingLocations`)
        .get();
      const locationDoc = locationsSnap.docs.find(
        (d) => d.data().name === locationName
      );
      if (!locationDoc) {
        return {
          result: "NG" as const,
          error: { message: `場所が見つかりません: ${locationName}` },
        };
      }
      const locationID = locationDoc.id;

      // locationOrders を batch で更新（firstCategory=0, secondCategory=1）
      const batch = firestore.batch();

      const firstRef = firestore.doc(
        `groups/${groupID}/userCategoryAxes/${axisID}/categories/${firstCategoryDoc.id}`
      );
      batch.update(firstRef, {
        locationOrders: {
          ...firstCategoryDoc.data().locationOrders,
          [locationID]: 0,
        },
        serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      const secondRef = firestore.doc(
        `groups/${groupID}/userCategoryAxes/${axisID}/categories/${secondCategoryDoc.id}`
      );
      batch.update(secondRef, {
        locationOrders: {
          ...secondCategoryDoc.data().locationOrders,
          [locationID]: 1,
        },
        serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      await batch.commit();

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
              : "カテゴリロケーション順序の設定に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("setupTestCategoryLocationOrder"),
  },
  setupTestCategoryLocationOrderFlow
);
```

**`firebase/functions/functions/src/index.ts` に登録追加:**

```typescript
if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "setupTestCategoryLocationOrder"
) {
  exports.setupTestCategoryLocationOrder = require("./functions/setupTestCategoryLocationOrder/function");
}
```

**テストファイル**: `firebase/functions/functions/src/functions/setupTestCategoryLocationOrder/function.test.ts`

```typescript
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: {
  groupID: string;
  locationName: string;
  firstCategoryName: string;
  secondCategoryName: string;
}) => Promise<any>;

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
jest.mock("firebase-functions/params", () => ({
  defineString: jest.fn().mockReturnValue({ value: jest.fn() }),
}));
jest.mock("firebase-functions", () => ({ logger: { error: jest.fn() } }));
jest.mock("../utils/authPolicy", () => ({
  appAuthPolicy: jest.fn().mockReturnValue(() => true),
}));

const mockAppEnv = jest.fn();
jest.mock("../../core/env", () => ({ appEnv: () => mockAppEnv() }));

const mockBatchUpdate = jest.fn();
const mockBatchCommit = jest.fn().mockResolvedValue(undefined);
const mockBatch = { update: mockBatchUpdate, commit: mockBatchCommit };

const mockAxesGet = jest.fn();
const mockCategoriesGet = jest.fn();
const mockLocationsGet = jest.fn();

const mockCollection = jest.fn().mockImplementation((path: string) => {
  if (path.includes("userCategoryAxes") && !path.includes("categories")) {
    return { limit: jest.fn().mockReturnValue({ get: mockAxesGet }) };
  }
  if (path.includes("categories")) {
    return { get: mockCategoriesGet };
  }
  if (path.includes("shoppingLocations")) {
    return { get: mockLocationsGet };
  }
  return { get: jest.fn() };
});

const mockDocFn = jest.fn().mockReturnValue({});
jest.mock("firebase-admin", () => ({
  default: {
    firestore: jest.fn().mockReturnValue({
      collection: mockCollection,
      doc: mockDocFn,
      batch: jest.fn().mockReturnValue(mockBatch),
    }),
    firestore: Object.assign(jest.fn(), {
      FieldValue: { serverTimestamp: jest.fn().mockReturnValue("TS") },
    }),
  },
}));

const INPUT = {
  groupID: "group-1",
  locationName: "テストスーパー",
  firstCategoryName: "肉",
  secondCategoryName: "野菜",
};

beforeEach(() => {
  jest.clearAllMocks();
  mockAppEnv.mockReturnValue("dev");
  mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

  mockAxesGet.mockResolvedValue({
    empty: false,
    docs: [{ id: "axis-1" }],
  });
  mockCategoriesGet.mockResolvedValue({
    docs: [
      { id: "cat-niku", data: () => ({ name: "肉", locationOrders: {} }) },
      { id: "cat-yasai", data: () => ({ name: "野菜", locationOrders: {} }) },
    ],
  });
  mockLocationsGet.mockResolvedValue({
    docs: [{ id: "loc-1", data: () => ({ name: "テストスーパー" }) }],
  });
});

require("./function");

describe("setupTestCategoryLocationOrder", () => {
  test("正常系: dev環境でlocationOrdersを更新できる", async () => {
    const result = await capturedFlowFn(INPUT);
    expect(result.result).toBe("OK");
    expect(mockBatchUpdate).toHaveBeenCalledTimes(2);
    expect(mockBatchCommit).toHaveBeenCalled();
  });

  test("異常系: prod環境では実行できない", async () => {
    mockAppEnv.mockReturnValue("prod");
    const result = await capturedFlowFn(INPUT);
    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("この機能は開発環境でのみ使用できます");
  });

  test("異常系: 未認証では実行できない", async () => {
    mockCurrentContext.mockReturnValue(null);
    const result = await capturedFlowFn(INPUT);
    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: カテゴリが見つからない場合はNGを返す", async () => {
    mockCategoriesGet.mockResolvedValue({ docs: [] });
    const result = await capturedFlowFn(INPUT);
    expect(result.result).toBe("NG");
  });

  test("異常系: 場所が見つからない場合はNGを返す", async () => {
    mockLocationsGet.mockResolvedValue({ docs: [] });
    const result = await capturedFlowFn(INPUT);
    expect(result.result).toBe("NG");
  });
});
```

### 4-B: Flutter `firebase_function.dart` に新メソッド追加

**ファイル**: `lib/utils/functions/firebase_function.dart`

```dart
/// カテゴリのロケーション別表示順序をテスト用に設定する。
/// [firstCategoryName] の順序を 0、[secondCategoryName] の順序を 1 に設定する。
/// 開発者オプションでのテスト用。
Future<void> setupTestCategoryLocationOrder({
  required String groupID,
  required String locationName,
  required String firstCategoryName,
  required String secondCategoryName,
}) async {
  final result = await httpsCallable('setupTestCategoryLocationOrder').call({
    'groupID': groupID,
    'locationName': locationName,
    'firstCategoryName': firstCategoryName,
    'secondCategoryName': secondCategoryName,
  });
  debugPrint('setupTestCategoryLocationOrder.result: ${result.data}');
  final response = mapToJSON(result.data);
  if (response['result'] != 'OK') {
    throw Exception(response['error']['message']);
  }
}
```

### 4-C: Flutter `developer_options/page.dart` に `_ActionTile` 追加

**ファイル**: `lib/features/developer_options/page.dart`

既存の `プレミアム付与（1日）` ActionTile の後に追加:

```dart
_ActionTile(
  title: 'カテゴリロケーション順序設定（テスト用）',
  subtitle: '「肉」→「野菜」の順序を「テストスーパー」に設定（dev環境のみ）',
  icon: Icons.sort,
  isProcessing: isProcessing.value,
  onTap: defaultGroupID == null
      ? null
      : () => _execute(
            isProcessing: isProcessing,
            resultMessage: resultMessage,
            action: () async {
              await functions.setupTestCategoryLocationOrder(
                groupID: defaultGroupID,
                locationName: 'テストスーパー',
                firstCategoryName: '肉',
                secondCategoryName: '野菜',
              );
            },
            actionName: 'カテゴリロケーション順序設定',
          ),
),
```

### 4-D: `premium_category_location_order.yaml` 更新

**ファイル**: `maestro/flows/premium_category_location_order.yaml`

完全な更新後ファイル:

```yaml
appId: com.bannzai.shoppinglist
---
# プレミアム状態でロケーション別カテゴリ並び替えが機能することを確認する。
# 「テストスーパー」に対して「肉」(order=0)→「野菜」(order=1) の順序をデバッグ Function 経由で設定し、
# 買い物リスト画面でデフォルト order（野菜=0, 肉=1）の逆順で表示されることを assert する。

- runFlow: shared/anonymous_sign_in.yaml
- runFlow: shared/grant_premium_via_debug.yaml

# --- グループ設定: 買い物場所とカテゴリを作成 ---

- tapOn: "リスト設定"
- assertVisible: "買い物リスト設定"
- tapOn:
    point: "50%,12%"
- waitForAnimationToEnd

- tapOn: "グループ設定"
- waitForAnimationToEnd
- assertVisible: "グループ設定"

# 買い物場所の作成
- tapOn: "場所を追加"
- assertVisible: "場所を追加"
- tapOn: "場所の名前（例: スーパー）"
- inputText: "テストスーパー"
- tapOn:
    text: "追加"
    index: 0
- waitForAnimationToEnd
- assertVisible: "テストスーパー"

# カテゴリ作成: 野菜（キーワード: にんじん）
- tapOn: "カテゴリを追加"
- assertVisible: "カテゴリを追加"
- tapOn: "カテゴリ名（例: 野菜）"
- inputText: "野菜"
- tapOn:
    text: "追加"
    index: 0
- waitForAnimationToEnd
- assertVisible: "カテゴリ編集"
- tapOn: "キーワードを追加"
- assertVisible: "キーワードを追加"
- inputText: "にんじん"
- tapOn:
    text: "追加"
    index: 0
- waitForAnimationToEnd
- tapOn:
    point: "5%,10%"
- waitForAnimationToEnd
- assertVisible: "グループ設定"

# カテゴリ作成: 肉（キーワード: 鶏肉）
- scrollUntilVisible:
    element: "カテゴリを追加"
    direction: DOWN
- tapOn: "カテゴリを追加"
- assertVisible: "カテゴリを追加"
- tapOn: "カテゴリ名（例: 野菜）"
- inputText: "肉"
- tapOn:
    text: "追加"
    index: 0
- waitForAnimationToEnd
- assertVisible: "カテゴリ編集"
- tapOn: "キーワードを追加"
- assertVisible: "キーワードを追加"
- inputText: "鶏肉"
- tapOn:
    text: "追加"
    index: 0
- waitForAnimationToEnd
- tapOn:
    point: "5%,10%"
- waitForAnimationToEnd
- assertVisible: "グループ設定"
- takeScreenshot: screenshots/premium_cat_loc_01_setup_done

# グループ設定 → リスト設定に戻る
- tapOn:
    point: "5%,10%"
- waitForAnimationToEnd
- assertVisible: "買い物リスト設定"

# リスト設定（BottomSheet）を閉じて買い物リストに戻る
- tapOn:
    point: "5%,12%"
- waitForAnimationToEnd

# --- 開発者オプション経由でカテゴリロケーション順序を設定 ---
# 「肉」= locationOrders[テストスーパー]=0、「野菜」= locationOrders[テストスーパー]=1
# デフォルト order（野菜=0, 肉=1）の逆順になるため、ソートが正しく動作すれば肉→野菜の順になる

- runFlow: shared/open_developer_options.yaml
- extendedWaitUntil:
    visible: "カテゴリロケーション順序設定（テスト用）"
    timeout: 10000
- tapOn: "カテゴリロケーション順序設定（テスト用）"
- extendedWaitUntil:
    visible: "カテゴリロケーション順序設定 完了"
    timeout: 30000
- tapOn: "Back"
- waitForAnimationToEnd
- tapOn:
    point: "25%,93%"
- waitForAnimationToEnd

# --- リスト設定: 買い物する場所に「テストスーパー」を選択 ---

- tapOn: "リスト設定"
- assertVisible: "買い物リスト設定"
- tapOn:
    point: "50%,12%"
- waitForAnimationToEnd

- tapOn: "なし"
- waitForAnimationToEnd
- tapOn: "テストスーパー"
- waitForAnimationToEnd

- tapOn:
    point: "5%,12%"
- waitForAnimationToEnd

# --- アイテム追加 ---

- tapOn: "アイテムを追加"
- inputText: "にんじん"
- pressKey: enter
- inputText: "鶏肉"
- pressKey: enter
- pressKey: enter

- tapOn:
    point: "50%,6%"
- waitForAnimationToEnd

# --- Assert: ロケーション別ソートが機能している ---
# locationOrders: 肉=0, 野菜=1 → 肉が野菜より先に表示される

# Firestore 同期待ち + 「肉」ヘッダーがスクロール前に表示（リスト上部に位置）
- extendedWaitUntil:
    visible: "肉"
    timeout: 10000
- assertVisible: "肉"

# 「野菜」ヘッダーは「肉」の後（下方向スクロールで確認 → 順序の保証）
- scrollUntilVisible:
    element: "野菜"
    direction: DOWN
- assertVisible: "野菜"

# キーワードマッチングが機能し未分類アイテムがないこと
- assertNotVisible: "未分類"

- takeScreenshot: screenshots/premium_cat_loc_02_location_order_applied
```

---

## 実装順序

1. **Task 1**: `premium_shopping_list_limit.yaml` / `_duplicate.yaml` 修正 → `maestro test` で動作確認
2. **Task 2**: シミュレータ起動 → `maestro hierarchy` 調査 → `mock_purchase*.yaml` 修正 → `maestro test` で動作確認
3. **Task 3**: GitHub Issue 新規作成 → Issue #241 にコメント追記
4. **Task 4**:
   a. Firebase Function 実装 (`function.ts` + `function.test.ts` + `index.ts` 登録)
   b. `npm run lint` + `npm run build` + `npm test` 実行
   c. Flutter `firebase_function.dart` に新メソッド追加
   d. Flutter `developer_options/page.dart` に `_ActionTile` 追加
   e. `dart run build_runner build` + `flutter analyze` + `flutter test`
   f. iOS ビルド確認 (`flutter build ios`)
   g. `maestro/flows/premium_category_location_order.yaml` 更新
   h. `maestro test maestro/flows/premium_category_location_order.yaml` で E2E 確認

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成
- [ ] Entity命名: フィールド名が省略されていない
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（timestamp等メタデータ除く）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当する場合）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `npm run lint` パス（firebase/functions/functions/ で実行）
- [ ] ビルド: `npm run build` 成功
- [ ] テスト: `npm test` 全件パス
- [ ] クライアント呼び出し関数はGenKitで定義
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
