// firebase-admin のモック
const mockCollection = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
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
  });

  test("正常系: メンバーが買い物リストを作成できる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1", "user-2"] }),
    };

    const mockNewDocRef = {
      id: "new-shopping-list-id",
      set: jest.fn().mockResolvedValue(undefined),
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
        return {
          where: jest.fn().mockReturnValue({
            count: jest.fn().mockReturnValue({
              get: jest
                .fn()
                .mockResolvedValue({ data: () => ({ count: 0 }) }),
            }),
          }),
          count: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({ data: () => ({ count: 0 }) }),
          }),
          doc: jest.fn(() => mockNewDocRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.shoppingListID).toBe("new-shopping-list-id");
    expect(mockNewDocRef.set).toHaveBeenCalledWith(
      expect.objectContaining({
        id: "new-shopping-list-id",
        createUserID: "user-1",
        groupID: "group-1",
        status: "active",
      })
    );
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

  test("異常系: 無料ユーザーで上限超過時にエラーになる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1"] }),
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
        return {
          where: jest.fn().mockReturnValue({
            count: jest.fn().mockReturnValue({
              get: jest
                .fn()
                .mockResolvedValue({ data: () => ({ count: 5 }) }),
            }),
          }),
        };
      }
      return {};
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("5個まで");
  });

  test("正常系: プレミアムユーザーは上限を超えても作成できる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: { isPremium: true } },
    });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1"] }),
    };

    const mockNewDocRef = {
      id: "premium-list-id",
      set: jest.fn().mockResolvedValue(undefined),
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
        return {
          count: jest.fn().mockReturnValue({
            get: jest
              .fn()
              .mockResolvedValue({ data: () => ({ count: 10 }) }),
          }),
          doc: jest.fn(() => mockNewDocRef),
        };
      }
      return {};
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
