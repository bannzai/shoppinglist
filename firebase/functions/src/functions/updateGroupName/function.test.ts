// firebase-admin のモック
const mockCollection = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");

// admin.firestore() でインスタンス返却 + admin.firestore.FieldValue にアクセス可能にする
const firestoreFunction = Object.assign(
  jest.fn(() => mockFirestoreInstance),
  {
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
  name: string;
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

describe("updateGroupName", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: オーナーがグループ名を更新できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "owner-user" } });

    const mockUpdate = jest.fn().mockResolvedValue(undefined);
    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "member-user"],
        }),
      }),
      update: mockUpdate,
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => mockGroupRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      name: "新しいグループ名",
    });

    expect(result.result).toBe("OK");
    expect(mockUpdate).toHaveBeenCalledWith({
      name: "新しいグループ名",
      updatedDateTime: "SERVER_TIMESTAMP",
    });
  });

  test("正常系: ownerUserIDがnullのレガシーグループでメンバーが更新できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "member-user" } });

    const mockUpdate = jest.fn().mockResolvedValue(undefined);
    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: null,
          memberUserIDs: ["member-user", "other-user"],
        }),
      }),
      update: mockUpdate,
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => mockGroupRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      name: "レガシーグループの新名前",
    });

    expect(result.result).toBe("OK");
    expect(mockUpdate).toHaveBeenCalledWith({
      name: "レガシーグループの新名前",
      updatedDateTime: "SERVER_TIMESTAMP",
    });
  });

  test("異常系: 非オーナーメンバーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "member-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "member-user"],
        }),
      }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => mockGroupRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      name: "新しい名前",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "グループのオーナーのみが名前を変更できます"
    );
  });

  test("異常系: グループが存在しない場合エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: false,
        data: () => undefined,
      }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => mockGroupRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({
      groupID: "non-existent-group",
      name: "新しい名前",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループが見つかりません");
  });

  test("異常系: 未認証ユーザーがエラー", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({
      groupID: "group-1",
      name: "新しい名前",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: メンバーでないユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "outsider-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "member-user"],
        }),
      }),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => mockGroupRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      name: "新しい名前",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });
});
