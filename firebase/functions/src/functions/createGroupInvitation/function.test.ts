// firebase-admin のモック
const mockCollection = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
  batch: jest.fn(),
};

const mockTimestampNow = jest.fn(() => ({ toMillis: () => Date.now() }));
const mockTimestampFromMillis = jest.fn((ms: number) => ({
  toMillis: () => ms,
}));
const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");

// admin.firestore() を呼ぶとインスタンスを返し、admin.firestore.Timestamp 等にもアクセスできるようにする
const firestoreFunction = Object.assign(
  jest.fn(() => mockFirestoreInstance),
  {
    Timestamp: {
      now: mockTimestampNow,
      fromMillis: mockTimestampFromMillis,
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
let capturedFlowFn: (input: { groupID: string }) => Promise<any>;

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

jest.mock("uuid", () => ({
  v4: jest.fn(() => "mock-uuid-token"),
}));

// モジュール読み込み
require("./function");

describe("createGroupInvitation", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: メンバーが招待を作成できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1", "user-2"] }),
    };

    const mockInvitationRef = {
      id: "invitation-1",
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
      if (path === "groupInvitations") {
        return { doc: jest.fn(() => mockInvitationRef) };
      }
      return {};
    });

    const result = await capturedFlowFn({ groupID: "group-1" });

    expect(result.result).toBe("OK");
    expect(result.data.invitationURL).toContain("mock-uuid-token");
    expect(mockInvitationRef.set).toHaveBeenCalledWith(
      expect.objectContaining({
        groupID: "group-1",
        inviterUserID: "user-1",
        token: "mock-uuid-token",
        status: "pending",
      })
    );
  });

  test("異常系: 非メンバーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "non-member" } });

    const mockGroupDoc = {
      exists: true,
      data: () => ({ memberUserIDs: ["user-1", "user-2"] }),
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

    const result = await capturedFlowFn({ groupID: "group-1" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });

  test("異常系: 存在しないグループでエラーになる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

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

    const result = await capturedFlowFn({ groupID: "non-existent" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループが見つかりません");
  });

  test("異常系: 未認証ユーザーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({ groupID: "group-1" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });
});
