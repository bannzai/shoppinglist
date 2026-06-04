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
  createUserID: string;
  name: string | null;
  setAsDefault: boolean;
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
  createUserID: "user-1",
  name: "テストグループ",
  setAsDefault: false,
};

describe("createGroup", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: グループを作成できる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockUserDoc = {
      exists: true,
      data: () => ({ defaultGroupID: "existing-group" }),
    };

    const mockGroupRef = {
      id: "new-group-id",
    };

    const ownedGroupsQuery = { __kind: "ownedGroupsQuery" };
    const mockTransaction = {
      get: jest.fn(async (arg: unknown) =>
        arg === ownedGroupsQuery ? { size: 1 } : mockUserDoc
      ),
      set: jest.fn(),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          where: jest.fn(() => ownedGroupsQuery),
          doc: jest.fn(() => mockGroupRef),
        };
      }
      if (path === `groups/new-group-id/userProfiles`) {
        return {
          doc: jest.fn(() => ({
            id: `GroupUserProfile_groups_new-group-id_users_user-1`,
          })),
        };
      }
      if (path === "users") {
        return {
          doc: jest.fn(() => ({ id: "user-1" })),
        };
      }
      return {};
    });

    mockFirestoreInstance.runTransaction = jest
      .fn()
      .mockImplementation(async (fn: any) => {
        await fn(mockTransaction);
      });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.groupID).toBe("new-group-id");
    expect(mockTransaction.set).toHaveBeenCalledTimes(2);
  });

  test("正常系: defaultGroupIDがnullの場合はデフォルトに設定される", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const mockUserDoc = {
      exists: true,
      data: () => ({ defaultGroupID: null }),
    };

    const mockGroupRef = {
      id: "new-group-id",
    };

    const ownedGroupsQuery = { __kind: "ownedGroupsQuery" };
    const mockTransaction = {
      get: jest.fn(async (arg: unknown) =>
        arg === ownedGroupsQuery ? { size: 0 } : mockUserDoc
      ),
      set: jest.fn(),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          where: jest.fn(() => ownedGroupsQuery),
          doc: jest.fn(() => mockGroupRef),
        };
      }
      if (path === `groups/new-group-id/userProfiles`) {
        return {
          doc: jest.fn(() => ({
            id: `GroupUserProfile_groups_new-group-id_users_user-1`,
          })),
        };
      }
      if (path === "users") {
        return {
          doc: jest.fn(() => ({ id: "user-1" })),
        };
      }
      return {};
    });

    mockFirestoreInstance.runTransaction = jest
      .fn()
      .mockImplementation(async (fn: any) => {
        await fn(mockTransaction);
      });

    const result = await capturedFlowFn({
      ...defaultInput,
      setAsDefault: false,
    });

    expect(result.result).toBe("OK");
    // group + profile + user(defaultGroupID設定) = 3回
    expect(mockTransaction.set).toHaveBeenCalledTimes(3);
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

  test("異常系: 無料ユーザーで上限到達時はトランザクション内で弾かれ書き込みが発生しない", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const ownedGroupsQuery = { __kind: "ownedGroupsQuery" };
    const mockTransaction = {
      get: jest.fn(async (arg: unknown) =>
        arg === ownedGroupsQuery
          ? { size: 2 }
          : { exists: true, data: () => ({ defaultGroupID: "existing-group" }) }
      ),
      set: jest.fn(),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          where: jest.fn(() => ownedGroupsQuery),
          doc: jest.fn(() => ({ id: "new-group-id" })),
        };
      }
      if (path === `groups/new-group-id/userProfiles`) {
        return {
          doc: jest.fn(() => ({
            id: `GroupUserProfile_groups_new-group-id_users_user-1`,
          })),
        };
      }
      if (path === "users") {
        return { doc: jest.fn(() => ({ id: "user-1" })) };
      }
      return {};
    });

    mockFirestoreInstance.runTransaction = jest
      .fn()
      .mockImplementation(async (fn: any) => fn(mockTransaction));

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain(
      "無料プランではソログループ+1グループ"
    );
    expect(mockTransaction.set).not.toHaveBeenCalled();
  });

  test("正常系: プレミアムユーザーは上限超過時でも作成できる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: { isPremium: true } },
    });

    const mockUserDoc = {
      exists: true,
      data: () => ({ defaultGroupID: "existing-group" }),
    };

    const mockGroupRef = {
      id: "premium-group-id",
    };

    const mockTransaction = {
      get: jest.fn().mockResolvedValue(mockUserDoc),
      set: jest.fn(),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          // プレミアムは上限チェックの transaction.get を通らないが、ownedGroupsQuery 構築時に where は呼ばれる
          where: jest.fn(() => ({ __kind: "ownedGroupsQuery" })),
          doc: jest.fn(() => mockGroupRef),
        };
      }
      if (path === `groups/premium-group-id/userProfiles`) {
        return {
          doc: jest.fn(() => ({
            id: `GroupUserProfile_groups_premium-group-id_users_user-1`,
          })),
        };
      }
      if (path === "users") {
        return {
          doc: jest.fn(() => ({ id: "user-1" })),
        };
      }
      return {};
    });

    mockFirestoreInstance.runTransaction = jest
      .fn()
      .mockImplementation(async (fn: any) => {
        await fn(mockTransaction);
      });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.groupID).toBe("premium-group-id");
  });

  test("異常系: グループ名に制御文字が含まれる場合にエラーになる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const result = await capturedFlowFn({
      ...defaultInput,
      name: "bad\u0000name",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("使用できない文字");
  });

  test("異常系: グループ名が100文字を超える場合にエラーになる", async () => {
    mockCurrentContext.mockReturnValue({
      auth: { uid: "user-1", token: {} },
    });

    const result = await capturedFlowFn({
      ...defaultInput,
      name: "あ".repeat(101),
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("100文字以内");
  });
});
