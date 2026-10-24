// firebase-admin のモック
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
  runTransaction: mockRunTransaction,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");
const mockArrayUnion = jest.fn((...args: any[]) => ({
  _type: "arrayUnion",
  values: args,
}));
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
  ...jest.requireActual("firebase-admin/firestore"),
  FieldValue: {
    serverTimestamp: mockServerTimestamp,
    arrayUnion: mockArrayUnion,
    arrayRemove: mockArrayRemove,
  },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: {
  groupID: string;
  debugUserID: string;
  membership: "join" | "leave";
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

const mockIsDeveloper = jest.fn();
jest.mock("../../core/developer", () => ({
  developerToken: { value: () => "test-secret-key" },
  isDeveloper: (...args: unknown[]) => mockIsDeveloper(...args),
}));

// モジュール読み込み（モック設定後）
require("./function");

describe("updateDebugUserGroupMembership", () => {
  let mockTransactionUpdate: jest.Mock;

  // groups/{groupID} の取得結果を差し替え、トランザクションの update を記録する。
  function setupGroup(groupDoc: { exists: boolean; data: () => any }) {
    const mockGroupRef = { get: jest.fn().mockResolvedValue(groupDoc) };
    mockCollection.mockImplementation((path: string) =>
      path === "groups" ? { doc: jest.fn(() => mockGroupRef) } : {}
    );
    return mockGroupRef;
  }

  beforeEach(() => {
    jest.clearAllMocks();
    mockIsDeveloper.mockResolvedValue(true);
    mockTransactionUpdate = jest.fn();
    mockRunTransaction.mockImplementation(async (fn: any) =>
      fn({
        get: jest.fn((ref: any) => ref.get()),
        update: mockTransactionUpdate,
      })
    );
  });

  test("正常系: 開発者が自分のデバッグユーザーをグループに追加できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    const mockGroupRef = setupGroup({
      exists: true,
      data: () => ({ memberUserIDs: ["user-1"] }),
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID: "user-1_debug_1",
      membership: "join",
    });

    expect(result.result).toBe("OK");
    expect(mockTransactionUpdate).toHaveBeenCalledWith(mockGroupRef, {
      memberUserIDs: { _type: "arrayUnion", values: ["user-1_debug_1"] },
      updatedDateTime: "SERVER_TIMESTAMP",
      serverUpdatedDateTime: "SERVER_TIMESTAMP",
    });
  });

  test("正常系: 開発者が自分のデバッグユーザーをグループから除去できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    const mockGroupRef = setupGroup({
      exists: true,
      data: () => ({ memberUserIDs: ["user-1", "user-1_debug_1"] }),
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID: "user-1_debug_1",
      membership: "leave",
    });

    expect(result.result).toBe("OK");
    expect(mockTransactionUpdate).toHaveBeenCalledWith(mockGroupRef, {
      memberUserIDs: { _type: "arrayRemove", values: ["user-1_debug_1"] },
      updatedDateTime: "SERVER_TIMESTAMP",
      serverUpdatedDateTime: "SERVER_TIMESTAMP",
    });
  });

  test.each([
    ["他人の uid", "user-2"],
    ["他人のデバッグユーザー", "user-2_debug_1"],
    ["数字でない suffix", "user-1_debug_x"],
    ["suffix なし", "user-1_debug_"],
    ["自分の uid そのもの", "user-1"],
  ])("異常系: %s (%s) は追加できない", async (_label, debugUserID) => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupGroup({
      exists: true,
      data: () => ({ memberUserIDs: ["user-1"] }),
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID,
      membership: "join",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("自分のデバッグユーザーのみ操作できます");
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  test("異常系: 開発者ではないユーザーは実行できない", async () => {
    mockIsDeveloper.mockResolvedValue(false);
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID: "user-1_debug_1",
      membership: "join",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("開発者のみ");
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  test("異常系: 呼び出し元がメンバーでないグループには追加できない", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupGroup({
      exists: true,
      data: () => ({ memberUserIDs: ["user-2"] }),
    });

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID: "user-1_debug_1",
      membership: "join",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
    expect(mockTransactionUpdate).not.toHaveBeenCalled();
  });

  test("異常系: グループが存在しない場合エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupGroup({ exists: false, data: () => undefined });

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID: "user-1_debug_1",
      membership: "join",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループが見つかりません");
    expect(mockTransactionUpdate).not.toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーが弾かれる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({
      groupID: "group-1",
      debugUserID: "user-1_debug_1",
      membership: "join",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });
});
