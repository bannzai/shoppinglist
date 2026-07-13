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

const mockGetUser = jest.fn();

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: jest.fn(() => mockFirestoreInstance),
    initializeApp: jest.fn(),
    auth: jest.fn(() => ({
      getUser: mockGetUser,
    })),
  },
}));

jest.mock("firebase-admin/firestore", () => ({
  // zTimestamp (z.instanceof(Timestamp)) 等が実物の Timestamp クラスを必要とするため、
  // モジュール全体を潰さず必要な static だけ差し替える
  ...jest.requireActual("firebase-admin/firestore"),
  FieldValue: {
    serverTimestamp: mockServerTimestamp,
    arrayUnion: mockArrayUnion,
  },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: { invitationCode: string }) => Promise<any>;

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
    mockRunTransaction.mockImplementation(async (fn: any) => {
      const mockTransaction = {
        update: jest.fn(),
        get: jest.fn((ref: any) => ref.get()),
        set: jest.fn(),
      };
      return fn(mockTransaction);
    });
  });

  test("正常系: 有効な招待コードで参加できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "new-user" } });
    mockGetUser.mockResolvedValue({ displayName: "New User" });

    const mockInvitationRef = {
      update: jest.fn(),
      get: jest.fn().mockResolvedValue({
        data: () => ({ status: "pending" }),
      }),
    };
    const mockInvitationDoc = {
      ref: mockInvitationRef,
      data: () => ({
        groupID: "group-1",
        invitationCode: "ABCD3456",
        status: "pending",
        expiresDateTime: {
          toDate: () => new Date(Date.now() + 86400000),
        },
      }),
    };

    const mockGroupRef = {
      update: jest.fn(),
      collection: jest.fn().mockReturnValue({
        doc: jest.fn().mockReturnValue({ id: "group_userProfile_new-user" }),
      }),
    };
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
            collection: mockGroupRef.collection,
          })),
        };
      }
      return {};
    });

    const result = await capturedFlowFn({ invitationCode: "ABCD3456" });

    expect(result.result).toBe("OK");
    expect(result.data.groupID).toBe("group-1");
    expect(mockRunTransaction).toHaveBeenCalled();
  });

  test("異常系: 無効な招待コードでエラーになる", async () => {
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

    const result = await capturedFlowFn({ invitationCode: "INVALID1" });

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
        invitationCode: "EXPD1234",
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

    const result = await capturedFlowFn({ invitationCode: "EXPD1234" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("招待の有効期限が切れています");
    expect(mockInvitationRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ status: "expired" })
    );
  });

  test("冪等性: 既にメンバーの場合は正常終了", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const mockInvitationDoc = {
      ref: {
        update: jest.fn(),
        get: jest.fn().mockResolvedValue({
          data: () => ({ status: "pending" }),
        }),
      },
      data: () => ({
        groupID: "group-1",
        invitationCode: "ABCD3456",
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

    const result = await capturedFlowFn({ invitationCode: "ABCD3456" });

    expect(result.result).toBe("OK");
    expect(result.data.groupID).toBe("group-1");
    expect(mockRunTransaction).toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーがエラーになる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({ invitationCode: "ABCD3456" });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });
});
