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
  },
}));

jest.mock("firebase-admin/firestore", () => ({
  // zTimestamp (z.instanceof(Timestamp)) 等が実物の Timestamp クラスを必要とするため、
  // モジュール全体を潰さず必要な static だけ差し替える
  ...jest.requireActual("firebase-admin/firestore"),
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
const mockGenerate = jest.fn();
let capturedFlowFn: (input: {
  itemNames: string[];
  existingCategoryNames: string[];
}) => Promise<any>;

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

const mockLoggerWarn = jest.fn();
jest.mock("firebase-functions", () => ({
  logger: { info: jest.fn(), warn: mockLoggerWarn, error: jest.fn() },
}));

jest.mock("firebase-functions/params", () => ({
  defineSecret: jest.fn(() => ({ value: () => "test-api-key" })),
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

describe("categorizeShoppingListItems", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // デフォルト: 無料ユーザー
    mockHasPremiumEntitlement.mockResolvedValue(false);
    // デフォルト: Genkit からの正常レスポンス
    mockGenerate.mockResolvedValue({
      output: {
        categorizedItems: [
          { name: "にんじん", categoryName: "野菜" },
          { name: "牛乳", categoryName: "乳製品" },
        ],
      },
    });
  });

  test("正常系: 既存ドキュメントで categorizeCount がインクリメントされる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    const { txUpdate, txSet } = setupTransactionMock(aiUsageRef, {
      exists: true,
      data: { categorizeCount: 2 },
    });

    const result = await capturedFlowFn({
      itemNames: ["にんじん", "牛乳"],
      existingCategoryNames: ["野菜"],
    });

    expect(result.result).toBe("OK");
    expect(result.data.categorizedItems).toEqual([
      { name: "にんじん", categoryName: "野菜" },
      { name: "牛乳", categoryName: "乳製品" },
    ]);
    expect(txUpdate).toHaveBeenCalledWith(
      aiUsageRef,
      expect.objectContaining({ categorizeCount: "INCREMENT_1" })
    );
    expect(txSet).not.toHaveBeenCalled();
    expect(mockGenerate).toHaveBeenCalledWith(
      expect.objectContaining({ model: "googleai/gemini-3.1-flash-lite" })
    );
  });

  test("正常系: 新規ドキュメントが作成される", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const aiUsageRef = { id: "aiUsageRef" };
    const { txUpdate, txSet } = setupTransactionMock(aiUsageRef, {
      exists: false,
      data: undefined,
    });

    const result = await capturedFlowFn({
      itemNames: ["にんじん"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("OK");
    expect(txSet).toHaveBeenCalledWith(
      aiUsageRef,
      expect.objectContaining({
        userID: "user-1",
        categorizeCount: 1,
        imageRecognitionCount: 0,
        urlRecognitionCount: 0,
      })
    );
    expect(txUpdate).not.toHaveBeenCalled();
  });

  test("入力に存在しないアイテム名はフィルタされる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGenerate.mockResolvedValue({
      output: {
        categorizedItems: [
          { name: "にんじん", categoryName: "野菜" },
          // 入力に無い名前。ハルシネーション対策でフィルタされる
          { name: "存在しない商品", categoryName: "その他" },
        ],
      },
    });
    setupTransactionMock(
      { id: "aiUsageRef" },
      { exists: true, data: { categorizeCount: 0 } }
    );

    const result = await capturedFlowFn({
      itemNames: ["にんじん"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("OK");
    expect(result.data.categorizedItems).toEqual([
      { name: "にんじん", categoryName: "野菜" },
    ]);
  });

  test("未認証なら NG を返し generate を呼ばない", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({
      itemNames: ["にんじん"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("NG");
    expect(mockGenerate).not.toHaveBeenCalled();
  });

  test("アイテムが空なら NG を返し generate を呼ばない", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({
      itemNames: ["", "   "],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("NG");
    expect(mockGenerate).not.toHaveBeenCalled();
  });

  test("月次上限に達していたら NG を返し generate を呼ばない", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    // 無料上限は 5。既に 5 使用済み
    setupTransactionMock(
      { id: "aiUsageRef" },
      { exists: true, data: { categorizeCount: 5 } }
    );

    const result = await capturedFlowFn({
      itemNames: ["にんじん"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("月間利用回数");
    expect(mockGenerate).not.toHaveBeenCalled();
    // 上限発動が Cloud Logging で確認できるよう warn ログが出ることを確認 (Issue #524)
    expect(mockLoggerWarn).toHaveBeenCalledWith(
      "categorizeShoppingListItems: monthly limit reached",
      expect.objectContaining({
        uid: "user-1",
        monthlyLimit: 5,
        isPremium: false,
      })
    );
  });

  test("プレミアムユーザーは無料上限(5回)超過後も利用できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "premium-user" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    const { txUpdate } = setupTransactionMock(
      { id: "aiUsageRef" },
      { exists: true, data: { categorizeCount: 5 } }
    );

    const result = await capturedFlowFn({
      itemNames: ["にんじん", "牛乳"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("OK");
    expect(mockHasPremiumEntitlement).toHaveBeenCalledWith("premium-user");
    expect(txUpdate).toHaveBeenCalled();
  });

  test("プレミアムユーザーも月次上限(50回)に達したら NG を返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "premium-user" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    setupTransactionMock(
      { id: "aiUsageRef" },
      { exists: true, data: { categorizeCount: 50 } }
    );

    const result = await capturedFlowFn({
      itemNames: ["にんじん"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("50回");
    expect(mockGenerate).not.toHaveBeenCalled();
  });

  test("モデル出力が不正なら NG を返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGenerate.mockResolvedValue({ output: { invalid: "data" } });
    setupTransactionMock(
      { id: "aiUsageRef" },
      { exists: true, data: { categorizeCount: 0 } }
    );

    const result = await capturedFlowFn({
      itemNames: ["にんじん"],
      existingCategoryNames: [],
    });

    expect(result.result).toBe("NG");
  });
});
