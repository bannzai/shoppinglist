// firebase-admin のモック
const mockCollection = jest.fn();
const mockBatch = {
  update: jest.fn(),
  commit: jest.fn().mockResolvedValue(undefined),
};
const mockFirestoreInstance = {
  collection: mockCollection,
  batch: jest.fn(() => mockBatch),
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");
const mockArrayUnion = jest.fn((...args: any[]) => ({
  _type: "arrayUnion",
  values: args,
}));

// admin.firestore() でインスタンス返却 + admin.firestore.FieldValue にアクセス可能にする
const firestoreFunction = Object.assign(
  jest.fn(() => mockFirestoreInstance),
  {
    FieldValue: {
      serverTimestamp: mockServerTimestamp,
      arrayUnion: mockArrayUnion,
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
let capturedFlowFn: (input: { token: string }) => Promise<any>;

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

describe("acceptGroupInvitation", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // clearAllMocks は実装をリセットしないが、batch mock の返却値を再確認
    mockFirestoreInstance.batch.mockReturnValue(mockBatch);
    mockBatch.commit.mockResolvedValue(undefined);
  });

  test("正常系: 有効なトークンで参加できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "new-user" } });

    const mockInvitationRef = { update: jest.fn() };
    const mockInvitationDoc = {
      ref: mockInvitationRef,
      data: () => ({
        groupID: "group-1",
        token: "valid-token",
        status: "pending",
        expiresDateTime: {
          toDate: () => new Date(Date.now() + 86400000),
        },
      }),
    };

    const mockGroupRef = { update: jest.fn() };
    const mockGroupDoc = {
      exists: true,
      ref: mockGroupRef,
      data: () => ({ memberUserIDs: ["user-1"] }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groupInvitations") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({
              limit: jest.fn().mockReturnValue({
                get: jest.fn().mockResolvedValue({
                  empty: false,
                  docs: [mockInvitationDoc],
                }),
              }),
            }),
          }),
        };
      }
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({ token: "valid-token" });

    expect(result.result).toBe("OK");
    expect(result.data.groupID).toBe("group-1");
    expect(mockBatch.update).toHaveBeenCalledTimes(2);
    expect(mockBatch.commit).toHaveBeenCalled();
  });

  test("異常系: 無効なトークンでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    mockCollection.mockImplementation((path: string) => {
      if (path === "groupInvitations") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({
              limit: jest.fn().mockReturnValue({
                get: jest.fn().mockResolvedValue({
                  empty: true,
                  docs: [],
                }),
              }),
            }),
          }),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({ token: "invalid-token" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("有効な招待が見つかりません");
  });

  test("異常系: 期限切れでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const mockInvitationRef = {
      update: jest.fn().mockResolvedValue(undefined),
    };
    const mockInvitationDoc = {
      ref: mockInvitationRef,
      data: () => ({
        groupID: "group-1",
        token: "expired-token",
        status: "pending",
        expiresDateTime: {
          toDate: () => new Date(Date.now() - 86400000),
        },
      }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groupInvitations") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({
              limit: jest.fn().mockReturnValue({
                get: jest.fn().mockResolvedValue({
                  empty: false,
                  docs: [mockInvitationDoc],
                }),
              }),
            }),
          }),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({ token: "expired-token" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("招待の有効期限が切れています");
    expect(mockInvitationRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ status: "expired" })
    );
  });

  test("冪等性: 既にメンバーの場合は正常終了", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const mockInvitationDoc = {
      ref: { update: jest.fn() },
      data: () => ({
        groupID: "group-1",
        token: "valid-token",
        status: "pending",
        expiresDateTime: {
          toDate: () => new Date(Date.now() + 86400000),
        },
      }),
    };

    const mockGroupDoc = {
      exists: true,
      ref: {},
      data: () => ({ memberUserIDs: ["user-1"] }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groupInvitations") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({
              limit: jest.fn().mockReturnValue({
                get: jest.fn().mockResolvedValue({
                  empty: false,
                  docs: [mockInvitationDoc],
                }),
              }),
            }),
          }),
        };
      }
      if (path === "groups") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue(mockGroupDoc),
          })),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({ token: "valid-token" });

    expect(result.result).toBe("OK");
    expect(result.data.groupID).toBe("group-1");
    expect(mockBatch.update).not.toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({ token: "valid-token" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });
});
