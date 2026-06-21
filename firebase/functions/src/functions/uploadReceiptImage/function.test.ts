const mockCollection = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
};
const mockCurrentContext = jest.fn();
const mockSave = jest.fn().mockResolvedValue(undefined);
// file.save() 後にダウンロードトークン生成のため呼ぶ getDownloadURL のモック。
const mockGetDownloadURL = jest
  .fn()
  .mockResolvedValue("https://example.com/receipt.jpeg");

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: () => mockFirestoreInstance,
    storage: () => ({
      bucket: () => ({ file: () => ({ save: mockSave }) }),
    }),
  },
}));

jest.mock("firebase-admin/storage", () => ({
  getDownloadURL: mockGetDownloadURL,
}));

// RevenueCat プレミアム判定のモック
const mockHasPremiumEntitlement = jest.fn();
jest.mock("../utils/premium", () => ({
  hasPremiumEntitlement: (...args: unknown[]) =>
    mockHasPremiumEntitlement(...args),
  revenueCatSecretApiKey: { value: () => "test-rc-secret-key" },
}));

let capturedFlowFn: (input: {
  groupID: string;
  shoppingListID: string;
  receiptID: string;
  base64Image: string;
}) => Promise<any>;

jest.mock("../utils/genkit", () => ({
  ai: {
    defineFlow: (_config: unknown, fn: any) => {
      capturedFlowFn = fn;
      return fn;
    },
    currentContext: mockCurrentContext,
  },
}));
jest.mock("firebase-functions/https", () => ({
  onCallGenkit: (_opts: any, flow: any) => flow,
}));
jest.mock("firebase-functions", () => ({ logger: { error: jest.fn() } }));

require("./function");

/** グループメンバーかつ買い物リストが存在するFirestoreモックを構築する。 */
function setupFirestoreMock({
  memberUserIDs,
  listExists,
}: {
  memberUserIDs: string[];
  listExists: boolean;
}) {
  mockCollection.mockImplementation((path: string) => {
    if (path === "groups") {
      return {
        doc: () => ({
          get: async () => ({
            data: () => ({ memberUserIDs }),
          }),
          collection: () => ({
            doc: () => ({
              get: async () => ({ exists: listExists }),
            }),
          }),
        }),
      };
    }
    return {};
  });
}

const defaultInput = {
  groupID: "group-1",
  shoppingListID: "list-1",
  receiptID: "receipt-1",
  // "hello" の base64 (8文字 → padding込み)
  base64Image: "aGVsbG8=",
};

describe("uploadReceiptImage", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: プレミアムユーザーがレシート画像をアップロードできる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    setupFirestoreMock({ memberUserIDs: ["user-1"], listExists: true });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.storagePath).toBe(
      "groups/group-1/shoppingLists/list-1/receipts/receipt-1.jpeg",
    );
    expect(mockSave).toHaveBeenCalled();
    // クライアントが getDownloadURL(storagePath) でトークン付き URL を取得できるよう、
    // サーバー側でダウンロードトークンを生成しておくこと。
    expect(mockGetDownloadURL).toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({});

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: 非プレミアムユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(false);

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("レシートの保存はプレミアム機能です");
  });

  test("異常系: 非メンバーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    setupFirestoreMock({ memberUserIDs: ["user-2"], listExists: true });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });

  test("異常系: 対象の買い物リストが存在しない場合エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    setupFirestoreMock({ memberUserIDs: ["user-1"], listExists: false });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("対象の買い物リストが存在しません");
  });

  test("異常系: 空の画像データでエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    setupFirestoreMock({ memberUserIDs: ["user-1"], listExists: true });

    const result = await capturedFlowFn({
      ...defaultInput,
      base64Image: "",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像データ形式が不正です");
  });

  test("異常系: 不正なbase64フォーマットでエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockHasPremiumEntitlement.mockResolvedValue(true);
    setupFirestoreMock({ memberUserIDs: ["user-1"], listExists: true });

    const result = await capturedFlowFn({
      ...defaultInput,
      base64Image: "!!!invalid!!!base64",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像データ形式が不正です");
  });
});
