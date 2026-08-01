// firebase-admin のモック
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
  runTransaction: mockRunTransaction,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");
const mockIncrement = jest.fn((n: number) => `INCREMENT_${n}`);

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: jest.fn(() => mockFirestoreInstance),
    initializeApp: jest.fn(),
    storage: jest.fn(() => ({
      bucket: jest.fn(() => ({
        file: jest.fn(() => ({ delete: jest.fn() })),
      })),
    })),
  },
}));

// このファイルは Timestamp クラス(zTimestamp等)を使用しないため、
// jest.requireActual による実モジュール読み込みは行わない。
// 実読み込みすると @grpc/grpc-js の GrpcStatus getter が評価され、
// このNode.jsバージョン環境下でクラッシュするため回避する。
jest.mock("firebase-admin/firestore", () => ({
  FieldValue: {
    serverTimestamp: mockServerTimestamp,
    increment: mockIncrement,
  },
}));

// RevenueCat プレミアム判定のモック
const mockHasPremiumEntitlement = jest.fn();
jest.mock("../utils/premium", () => ({
  hasPremiumEntitlement: (...args: unknown[]) =>
    mockHasPremiumEntitlement(...args),
  revenueCatSecretApiKey: { value: () => "test-rc-secret-key" },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: {
  mimeType: string;
  base64Image: string;
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

jest.mock("../utils/authPolicy", () => ({
  appAuthPolicy: jest.fn(() => () => true),
}));

const mockLoggerWarn = jest.fn();
jest.mock("firebase-functions", () => ({
  logger: { info: jest.fn(), warn: mockLoggerWarn, error: jest.fn() },
}));

jest.mock("firebase-functions/params", () => ({
  defineSecret: jest.fn(() => ({ value: () => "test-api-key" })),
}));

// Gemini SDKのモック
const mockSendMessage = jest.fn();
const mockStartChat = jest.fn().mockResolvedValue({
  sendMessage: mockSendMessage,
});

jest.mock("@google/generative-ai", () => ({
  GoogleGenerativeAI: jest.fn().mockImplementation(() => ({
    getGenerativeModel: jest.fn().mockReturnValue({
      startChat: mockStartChat,
    }),
  })),
  SchemaType: { OBJECT: "OBJECT", ARRAY: "ARRAY", STRING: "STRING" },
}));

jest.mock("@google/generative-ai/server", () => ({
  GoogleAIFileManager: jest.fn().mockImplementation(() => ({
    uploadFile: jest.fn().mockResolvedValue({
      file: {
        mimeType: "image/jpeg",
        uri: "https://example.com/file",
        displayName: "uploaded_image",
        name: "files/test",
      },
    }),
  })),
}));

jest.mock("fs", () => ({
  writeFile: jest.fn(
    (
      _path: string,
      _data: Buffer,
      callback: (err: Error | null) => void
    ) => {
      callback(null);
    }
  ),
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

describe("generateShoppingListItemsFromImage", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // デフォルト: Geminiから正常レスポンスを返す
    mockSendMessage.mockResolvedValue({
      response: {
        functionCalls: () => [
          { args: { shoppingListItems: ["牛乳", "卵"] } },
        ],
      },
    });
    // デフォルト: 無料ユーザー
    mockHasPremiumEntitlement.mockResolvedValue(false);
  });

  test("正常系: AI利用回数がインクリメントされる（既存ドキュメント）", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    const txGet = jest
      .fn()
      .mockResolvedValue({ exists: true, data: () => ({ imageRecognitionCount: 2 }) });
    const txUpdate = jest.fn();
    const txSet = jest.fn();
    mockRunTransaction.mockImplementation(async (handler: any) =>
      handler({ get: txGet, update: txUpdate, set: txSet })
    );

    setupFirestoreMocks(aiUsageRef);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("OK");
    expect(result.data.shoppingListItems).toEqual(["牛乳", "卵"]);
    expect(txUpdate).toHaveBeenCalledWith(
      aiUsageRef,
      expect.objectContaining({
        imageRecognitionCount: "INCREMENT_1",
      })
    );
    expect(txSet).not.toHaveBeenCalled();
  });

  test("正常系: AI利用回数が新規作成される（ドキュメント未存在）", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    const txGet = jest
      .fn()
      .mockResolvedValue({ exists: false, data: () => undefined });
    const txUpdate = jest.fn();
    const txSet = jest.fn();
    mockRunTransaction.mockImplementation(async (handler: any) =>
      handler({ get: txGet, update: txUpdate, set: txSet })
    );

    setupFirestoreMocks(aiUsageRef);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("OK");
    expect(txSet).toHaveBeenCalledWith(
      aiUsageRef,
      expect.objectContaining({
        userID: "user-1",
        imageRecognitionCount: 1,
      })
    );
    expect(txUpdate).not.toHaveBeenCalled();
  });

  test("境界: function callのargsが空でも空配列でOKを返す（INTERNAL化を防ぐ）", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    // 画像から何も読み取れず args が空オブジェクトで返るケースを再現する
    mockSendMessage.mockResolvedValue({
      response: {
        functionCalls: () => [{ args: {} }],
      },
    });

    const aiUsageRef = { id: "aiUsageRef" };
    const txGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({ imageRecognitionCount: 0 }),
    });
    mockRunTransaction.mockImplementation(async (handler: any) =>
      handler({ get: txGet, update: jest.fn(), set: jest.fn() })
    );

    setupFirestoreMocks(aiUsageRef);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("OK");
    expect(result.data.shoppingListItems).toEqual([]);
  });

  test("異常系: 未認証ユーザーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: authにuidがない場合エラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: {} });

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: 非許可MIME typeでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({
      mimeType: "application/pdf",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像形式がサポートされていません");
  });

  test("異常系: 空の画像データでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像サイズが制限を超えています");
  });

  test("異常系: 無料ユーザーの利用回数上限（5回）到達でエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(false);

    const aiUsageRef = { id: "aiUsageRef" };
    const txGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({ imageRecognitionCount: 5 }),
    });
    mockRunTransaction.mockImplementation(async (handler: any) =>
      handler({ get: txGet, update: jest.fn(), set: jest.fn() })
    );

    setupFirestoreMocks(aiUsageRef);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "画像読み取りの月間利用回数（5回）に達しました"
    );
    // AI呼び出しが実行されていないことを確認
    expect(mockStartChat).not.toHaveBeenCalled();
    // 上限発動が Cloud Logging で確認できるよう warn ログが出ることを確認 (Issue #524)
    expect(mockLoggerWarn).toHaveBeenCalledWith(
      "generateShoppingListItemsFromImage: monthly limit reached",
      expect.objectContaining({
        uid: "user-1",
        monthlyLimit: 5,
        isPremium: false,
      })
    );
  });

  test("正常系: プレミアムユーザーは50回まで利用可能", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "premium-user" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);

    const aiUsageRef = { id: "aiUsageRef" };
    const txGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({ imageRecognitionCount: 10 }),
    });
    const txUpdate = jest.fn();
    mockRunTransaction.mockImplementation(async (handler: any) =>
      handler({ get: txGet, update: txUpdate, set: jest.fn() })
    );

    setupFirestoreMocks(aiUsageRef);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("OK");
    expect(txUpdate).toHaveBeenCalled();
  });

  test("異常系: プレミアムユーザーの利用回数上限（50回）到達でエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "premium-user" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);

    const aiUsageRef = { id: "aiUsageRef" };
    const txGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({ imageRecognitionCount: 50 }),
    });
    mockRunTransaction.mockImplementation(async (handler: any) =>
      handler({ get: txGet, update: jest.fn(), set: jest.fn() })
    );

    setupFirestoreMocks(aiUsageRef);

    const result = await capturedFlowFn({
      mimeType: "image/jpeg",
      base64Image: "dGVzdA==",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "画像読み取りの月間利用回数（50回）に達しました"
    );
    expect(mockStartChat).not.toHaveBeenCalled();
  });
});
