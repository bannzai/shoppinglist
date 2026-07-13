// firebase-admin のモック
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
  runTransaction: mockRunTransaction,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");
const mockArrayRemove = jest.fn((...args: any[]) => ({
  _type: "arrayRemove",
  values: args,
}));

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
    arrayRemove: mockArrayRemove,
  },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: {
  groupID: string;
  targetUserID: string;
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

describe("removeGroupMember", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockRunTransaction.mockImplementation(async (fn: any) => {
      const mockTransaction = {
        update: jest.fn(),
        get: jest.fn((ref: any) => ref.get()),
        delete: jest.fn(),
      };
      return fn(mockTransaction);
    });
  });

  test("正常系: オーナーがメンバーを削除できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "owner-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "target-user"],
        }),
      }),
      collection: jest.fn().mockReturnValue({
        doc: jest.fn().mockReturnValue({ id: "GroupUserProfile_groups_group-1_users_target-user" }),
      }),
    };

    const mockUserDoc = {
      exists: true,
      data: () => ({ defaultGroupID: "group-1" }),
    };

    const mockUserRef = {
      get: jest.fn().mockResolvedValue(mockUserDoc),
    };

    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") {
        return {
          doc: jest.fn(() => mockGroupRef),
        };
      }
      if (path === "users") {
        return {
          doc: jest.fn(() => mockUserRef),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      targetUserID: "target-user",
    });

    expect(result.result).toBe("OK");
    expect(mockRunTransaction).toHaveBeenCalled();
  });

  test("冪等性: 既にメンバーでない場合は正常終了", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "owner-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user"],
        }),
      }),
      collection: jest.fn(),
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
      targetUserID: "target-user",
    });

    expect(result.result).toBe("OK");
    expect(mockRunTransaction).toHaveBeenCalled();
  });

  test("異常系: 非オーナーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "non-owner-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "non-owner-user", "target-user"],
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
      targetUserID: "target-user",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "グループのオーナーのみがメンバーを削除できます"
    );
  });

  test("異常系: オーナー自身を削除しようとするとエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "owner-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "target-user"],
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
      targetUserID: "owner-user",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "オーナー自身を削除することはできません"
    );
  });

  test("異常系: グループが存在しない場合エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "owner-user" } });

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
      targetUserID: "target-user",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループが見つかりません");
  });

  test("異常系: 未認証ユーザーがエラー", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({
      groupID: "group-1",
      targetUserID: "target-user",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: ownerUserIDがnullの場合エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: null,
          memberUserIDs: ["user-1", "target-user"],
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
      targetUserID: "target-user",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe(
      "オーナーが設定されていないグループでは操作できません"
    );
  });

  test("回帰: トランザクション内で全read→全writeの順序を守る（read-after-write違反を起こさない）", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "owner-user" } });

    const mockGroupRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          ownerUserID: "owner-user",
          memberUserIDs: ["owner-user", "target-user"],
        }),
      }),
      collection: jest.fn().mockReturnValue({
        doc: jest.fn().mockReturnValue({ id: "profile-doc" }),
      }),
    };
    const mockUserRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({ defaultGroupID: "group-1" }),
      }),
    };
    mockCollection.mockImplementation((path: string) => {
      if (path === "groups") return { doc: jest.fn(() => mockGroupRef) };
      if (path === "users") return { doc: jest.fn(() => mockUserRef) };
      return {};
    });

    // 本物のFirestoreの制約を再現: 1つでもwriteした後にreadを呼んだらthrowする
    mockRunTransaction.mockImplementation(async (fn: any) => {
      let hasWritten = false;
      const mockTransaction = {
        get: jest.fn((ref: any) => {
          if (hasWritten) {
            throw new Error(
              "Firestore transactions require all reads to be executed before all writes."
            );
          }
          return ref.get();
        }),
        update: jest.fn(() => {
          hasWritten = true;
        }),
        delete: jest.fn(() => {
          hasWritten = true;
        }),
      };
      return fn(mockTransaction);
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      targetUserID: "target-user",
    });

    expect(result.result).toBe("OK");
  });
});
