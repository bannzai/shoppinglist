// firebase-admin のモック
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
  runTransaction: mockRunTransaction,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");
const mockIncrement = jest.fn((n: number) => `INCREMENT_${n}`);

// admin.firestore() でインスタンス返却 + admin.firestore.FieldValue にアクセス可能にする
const firestoreFunction = Object.assign(
  jest.fn(() => mockFirestoreInstance),
  {
    FieldValue: {
      serverTimestamp: mockServerTimestamp,
      increment: mockIncrement,
    },
  }
);

const mockGetUser = jest.fn();

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: firestoreFunction,
    initializeApp: jest.fn(),
    auth: jest.fn(() => ({
      getUser: mockGetUser,
    })),
  },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
const mockGenerate = jest.fn();
let capturedFlowFn: (input: { url: string }) => Promise<any>;

jest.mock("../utils/genkit", () => ({
  ai: {
    defineFlow: (_config: any, fn: any) => {
      capturedFlowFn = fn;
      return fn;
    },
    currentContext: mockCurrentContext,
    generate: (...args: unknown[]) => mockGenerate(...args),
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
  defineSecret: jest.fn(() => ({ value: () => "test-api-key" })),
}));

// DNS lookup のモック
const mockLookup = jest.fn();
jest.mock("node:dns/promises", () => ({
  lookup: (...args: unknown[]) => mockLookup(...args),
}));

// node:https のモック（safeFetchHTML で使用）
const mockHttpsRequest = jest.fn();
jest.mock("node:https", () => ({
  Agent: jest.fn().mockImplementation(() => ({
    destroy: jest.fn(),
  })),
  request: (...args: unknown[]) => mockHttpsRequest(...args),
}));

require("./function");

/** aiUsageRefのモックを構築するヘルパー。 */
function setupFirestoreMocks(aiUsageRef: any) {
  mockCollection.mockImplementation((path: string) => {
    if (path === "users") {
      return {
        doc: jest.fn(() => ({
          collection: jest.fn(() => ({
            doc: jest.fn(() => aiUsageRef),
          })),
        })),
      };
    }
    return {};
  });
}

import { EventEmitter } from "node:events";

/** node:https.request のモックレスポンスを構築するヘルパー。 */
function setupHttpsRequestMock(overrides: {
  statusCode?: number;
  headers?: Record<string, string>;
  body?: string;
  error?: Error;
} = {}) {
  const statusCode = overrides.statusCode ?? 200;
  const headers = overrides.headers ?? {
    "content-type": "text/html; charset=utf-8",
    "content-length": "100",
  };
  const body = overrides.body ?? "<html><body>牛乳 卵</body></html>";

  mockHttpsRequest.mockImplementation((_url: string, _opts: any, callback: (res: any) => void) => {
    const res = new EventEmitter() as any;
    res.statusCode = statusCode;
    res.headers = headers;

    // レスポンスを非同期で発火
    process.nextTick(() => {
      callback(res);
      if (overrides.error) {
        res.emit("error", overrides.error);
      } else {
        res.emit("data", Buffer.from(body, "utf8"));
        res.emit("end");
      }
    });

    const req = new EventEmitter() as any;
    req.end = jest.fn();
    req.destroy = jest.fn();
    return req;
  });
}

/** トランザクションモックを設定するヘルパー。 */
function setupTransactionMock(
  aiUsageRef: any,
  aiUsageData: { exists: boolean; data: any }
) {
  const txGet = jest.fn().mockResolvedValue({
    exists: aiUsageData.exists,
    data: () => aiUsageData.data,
  });
  const txUpdate = jest.fn();
  const txSet = jest.fn();
  mockRunTransaction.mockImplementation(async (handler: any) =>
    handler({ get: txGet, update: txUpdate, set: txSet })
  );
  setupFirestoreMocks(aiUsageRef);
  return { txGet, txUpdate, txSet };
}

describe("generateShoppingListItemsFromURL", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // デフォルト: 無料ユーザー
    mockGetUser.mockResolvedValue({ customClaims: {} });
    // デフォルト: DNS lookup → パブリックIP
    mockLookup.mockResolvedValue({ address: "93.184.216.34" });
    // デフォルト: Genkit からの正常レスポンス
    mockGenerate.mockResolvedValue({
      output: { shoppingListItems: ["牛乳", "卵"] },
    });
    // デフォルト: node:https.request
    setupHttpsRequestMock();
  });

  test("正常系: 既存ドキュメントで urlRecognitionCount がインクリメントされる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    const { txUpdate, txSet } = setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 2 },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("OK");
    expect(result.data.shoppingListItems).toEqual(["牛乳", "卵"]);
    expect(txUpdate).toHaveBeenCalledWith(
      aiUsageRef,
      expect.objectContaining({
        urlRecognitionCount: "INCREMENT_1",
      })
    );
    expect(txSet).not.toHaveBeenCalled();
  });

  test("正常系: 新規ドキュメントが作成される", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    const { txUpdate, txSet } = setupTransactionMock(aiUsageRef, {
      exists: false,
      data: undefined,
    });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("OK");
    expect(txSet).toHaveBeenCalledWith(
      aiUsageRef,
      expect.objectContaining({
        userID: "user-1",
        imageRecognitionCount: 0,
        urlRecognitionCount: 1,
      })
    );
    expect(txUpdate).not.toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({ url: "https://example.com" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: authにuidがない場合エラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: {} });

    const result = await capturedFlowFn({ url: "https://example.com" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: 空URLでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({ url: "" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("URLが無効です");
  });

  test("異常系: 不正URL形式でエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({ url: "not-a-url" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("URLが無効です");
  });

  test("異常系: HTTP URLでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({ url: "http://example.com" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("HTTPSのURLのみ対応しています");
  });

  test("異常系: user:password付きURLでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({
      url: "https://user:pass@example.com",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("URLが無効です");
  });

  test("異常系: localhost URL は拒否される", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({ url: "https://localhost/test" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("指定されたURLにはアクセスできません");
  });

  test("異常系: プライベートIP宛URLは拒否される", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockLookup.mockResolvedValue({ address: "192.168.1.1" });

    const result = await capturedFlowFn({
      url: "https://internal.example.com",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("指定されたURLにはアクセスできません");
  });

  test("異常系: リンクローカル宛URLは拒否される", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockLookup.mockResolvedValue({ address: "169.254.1.1" });

    const result = await capturedFlowFn({
      url: "https://link-local.example.com",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("指定されたURLにはアクセスできません");
  });

  test("異常系: URL長が2048文字を超えるとエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const longURL = "https://example.com/" + "a".repeat(2048);
    const result = await capturedFlowFn({ url: longURL });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("URLが無効です");
  });

  test("異常系: 無料ユーザーの上限（5回）到達でエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: {} });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 5 },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "URL読み取りの月間利用回数（5回）に達しました"
    );
    expect(mockGenerate).not.toHaveBeenCalled();
  });

  test("正常系: プレミアムユーザーは50回まで利用可能", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "premium-user" } });
    mockGetUser.mockResolvedValue({ customClaims: { premium: true } });

    const aiUsageRef = { id: "aiUsageRef" };
    const { txUpdate } = setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 10 },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("OK");
    expect(txUpdate).toHaveBeenCalled();
  });

  test("異常系: プレミアムユーザーの上限（50回）到達でエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "premium-user" } });
    mockGetUser.mockResolvedValue({ customClaims: { premium: true } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 50 },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "URL読み取りの月間利用回数（50回）に達しました"
    );
    expect(mockGenerate).not.toHaveBeenCalled();
  });

  test("異常系: Webページ取得失敗（HTTPステータス非200）", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    setupHttpsRequestMock({ statusCode: 404 });

    const result = await capturedFlowFn({
      url: "https://example.com/not-found",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("ページの取得に失敗しました（HTTP 404）");
  });

  test("異常系: Webページがリダイレクト応答", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    setupHttpsRequestMock({ statusCode: 301 });

    const result = await capturedFlowFn({
      url: "https://example.com/redirect",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("リダイレクトは許可されていません");
  });

  test("異常系: content-type が text/html 以外", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    setupHttpsRequestMock({
      headers: { "content-type": "application/json" },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/api.json",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("HTMLページのみ対応しています");
  });

  test("異常系: Webページサイズ超過（content-length）", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    setupHttpsRequestMock({
      headers: {
        "content-type": "text/html",
        "content-length": String(6 * 1024 * 1024),
      },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/large-page",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("ページサイズが大きすぎます");
  });

  test("異常系: Genkitのstructured output payload が不正", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    mockGenerate.mockResolvedValue({ output: { invalid: "data" } });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("Invalid model output payload");
  });

  test("異常系: Genkitのstructured outputがnull", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    mockGenerate.mockResolvedValue({ output: null });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("Invalid model output payload");
  });

  test("異常系: 内部エラー時に Error.message をそのまま返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    mockGenerate.mockRejectedValue(new Error("Gemini API error"));

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("Gemini API error");
  });

  test("正常系: 返却アイテムの空文字除去・文字数上限・件数上限が適用される", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { urlRecognitionCount: 0 },
    });

    const longItem = "あ".repeat(101);
    const items = Array.from({ length: 55 }, (_, i) => `アイテム${i}`);
    items.push("", "  ", longItem);
    mockGenerate.mockResolvedValue({
      output: { shoppingListItems: items },
    });

    const result = await capturedFlowFn({
      url: "https://example.com/recipe",
    });

    expect(result.result).toBe("OK");
    // 空文字・空白のみは除去、101文字超は除去、50件上限
    expect(result.data.shoppingListItems.length).toBeLessThanOrEqual(50);
    expect(
      result.data.shoppingListItems.every(
        (item: string) => item.length > 0 && item.length <= 100
      )
    ).toBe(true);
  });
});
