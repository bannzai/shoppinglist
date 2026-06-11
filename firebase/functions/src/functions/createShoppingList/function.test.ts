// firebase-admin のモック
const mockCollection = jest.fn();
const mockSet = jest.fn();

// トランザクション内で使われるモック
const mockTransactionGet = jest.fn();
const mockTransactionSet = jest.fn();
const mockTransaction = {
  get: mockTransactionGet,
  set: mockTransactionSet,
};

// runTransaction: コールバックに mockTransaction を渡して実行する
const mockRunTransaction = jest.fn(async (fn: any) => {
  return await fn(mockTransaction);
});

const mockFirestoreInstance = {
  collection: mockCollection,
  runTransaction: mockRunTransaction,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");

const firestoreFunction = Object.assign(
  jest.fn(() => mockFirestoreInstance),
  {
    Timestamp: {
      now: jest.fn(() => ({ toMillis: () => Date.now() })),
      fromMillis: jest.fn((ms: number) => ({ toMillis: () => ms })),
    },
    FieldValue: {
      serverTimestamp: mockServerTimestamp,
    },
  }
);

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: firestoreFunction,
    initializeApp: jest.fn(),
  },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: {
  groupID: string;
  createUserID: string;
  shoppingLocationID: string | null;
  duplicatedFromGroupShoppingListID: string | null;
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

jest.mock("firebase-functions", () => ({
  logger: { info: jest.fn(), error: jest.fn() },
}));

jest.mock("firebase-functions/params", () => ({
  defineString: jest.fn(() => ({ value: () => "" })),
}));

// RevenueCat プレミアム判定のモック
const mockHasPremiumEntitlement = jest.fn();
jest.mock("../utils/premium", () => ({
  hasPremiumEntitlement: (...args: unknown[]) =>
    mockHasPremiumEntitlement(...args),
  revenueCatSecretApiKey: { value: () => "test-rc-secret-key" },
}));

// モジュール読み込み
require("./function");

const defaultInput = {
  groupID: "group-1",
  createUserID: "user-1",
  shoppingLocationID: null,
  duplicatedFromGroupShoppingListID: null,
};

describe("createShoppingList", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // デフォルト: 無料ユーザー
    mockHasPremiumEntitlement.mockResolvedValue(false);
  });

  test("正常系: メンバーが買い物リストを作成できる（トランザクション使用）", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1", "user-2"] }),
    };

    const mockNewDocRef = {
      id: "new-shopping-list-id",
    };

    const mockActiveQuery = { _tag: "activeQuery" };
    const mockShoppingListsRef = {
      where: jest.fn().mockReturnValue(mockActiveQuery),
      doc: jest.fn(() => mockNewDocRef),
      _tag: "shoppingListsRef",
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      if (path === "groups/group-1/shoppingLists") {
        return mockShoppingListsRef;
      }
      return {};
    });

    // transaction.get の振る舞い: activeリスト0件、全リスト0件
    mockTransactionGet.mockImplementation((queryOrRef: any) => {
      if (queryOrRef === mockActiveQuery) {
        return Promise.resolve({ size: 0 });
      }
      if (queryOrRef === mockShoppingListsRef) {
        return Promise.resolve({ size: 0 });
      }
      return Promise.resolve({ size: 0 });
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.shoppingListID).toBe("new-shopping-list-id");
    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
    expect(mockTransactionSet).toHaveBeenCalledWith(
      mockNewDocRef,
      expect.objectContaining({
        id: "new-shopping-list-id",
        createUserID: "user-1",
        groupID: "group-1",
        status: "active",
      })
    );
    // createdDateTime / updatedDateTime はサーバーで設定しない
    const setArgs = mockTransactionSet.mock.calls[0][1];
    expect(setArgs).not.toHaveProperty("createdDateTime");
    expect(setArgs).not.toHaveProperty("updatedDateTime");
    expect(setArgs).toHaveProperty("serverCreatedDateTime");
    expect(setArgs).toHaveProperty("serverUpdatedDateTime");
  });

  test("異常系: 未認証ユーザーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: createUserIDと認証ユーザーが不一致", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "other-user", token: {} },
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "createUserIDが認証ユーザーと一致しません"
    );
  });

  test("異常系: 非メンバーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-2", "user-3"] }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      return {};
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });

  test("異常系: 無料ユーザーで上限超過時にエラーになる（トランザクション内で検証）", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1"] }),
    };

    const mockActiveQuery = { _tag: "activeQuery" };
    const mockShoppingListsRef = {
      where: jest.fn().mockReturnValue(mockActiveQuery),
      doc: jest.fn(() => ({ id: "dummy" })),
      _tag: "shoppingListsRef",
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      if (path === "groups/group-1/shoppingLists") {
        return mockShoppingListsRef;
      }
      return {};
    });

    // transaction.get: activeリスト5件（上限到達）
    mockTransactionGet.mockImplementation((queryOrRef: any) => {
      if (queryOrRef === mockActiveQuery) {
        return Promise.resolve({ size: 5 });
      }
      return Promise.resolve({ size: 0 });
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("5個まで");
  });

  test("正常系: プレミアムユーザーは上限を超えても作成できる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });
    mockHasPremiumEntitlement.mockResolvedValue(true);

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1"] }),
    };

    const mockNewDocRef = {
      id: "premium-list-id",
    };

    const mockShoppingListsRef = {
      where: jest.fn(),
      doc: jest.fn(() => mockNewDocRef),
      _tag: "shoppingListsRef",
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      if (path === "groups/group-1/shoppingLists") {
        return mockShoppingListsRef;
      }
      return {};
    });

    // プレミアムユーザーはactiveリストのチェックをスキップするため、allSnapshot のみ
    mockTransactionGet.mockImplementation((queryOrRef: any) => {
      if (queryOrRef === mockShoppingListsRef) {
        return Promise.resolve({ size: 10 });
      }
      return Promise.resolve({ size: 0 });
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.shoppingListID).toBe("premium-list-id");
  });

  test("異常系: 存在しないグループでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockGroupDoc = {
      exists: false,
      data: () => null,
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      return {};
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループが見つかりません");
  });
});
