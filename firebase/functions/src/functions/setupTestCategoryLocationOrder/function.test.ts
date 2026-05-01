// firebase-admin のモック
const mockTransactionGet = jest.fn();
const mockTransactionUpdate = jest.fn();
const mockTransaction = {
  get: mockTransactionGet,
  update: mockTransactionUpdate,
};
const mockRunTransaction = jest
  .fn()
  .mockImplementation(async (fn: (t: typeof mockTransaction) => Promise<void>) =>
    fn(mockTransaction)
  );

const mockCollection = jest.fn();
const mockDocFn = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
  doc: mockDocFn,
  runTransaction: mockRunTransaction,
};

const mockServerTimestamp = jest.fn(() => "SERVER_TIMESTAMP");
const firestoreFunction = Object.assign(
  jest.fn(() => mockFirestoreInstance),
  {
    FieldValue: { serverTimestamp: mockServerTimestamp },
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
  locationName: string;
  firstCategoryName: string;
  secondCategoryName: string;
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

const mockAppEnv = jest.fn();
jest.mock("../../core/env", () => ({
  appEnv: () => mockAppEnv(),
}));

// モジュール読み込み（モック設定後）
require("./function");

const INPUT = {
  groupID: "group-1",
  locationName: "テストスーパー",
  firstCategoryName: "肉",
  secondCategoryName: "野菜",
};

const AXIS_ID = "axis-1";
const LOC_ID = "loc-1";
const NIKU_ID = "cat-niku";
const YASAI_ID = "cat-yasai";

function setupDefaultMocks() {
  mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

  mockCollection.mockImplementation((path: string) => {
    if (path === `groups/${INPUT.groupID}/userCategoryAxes`) {
      return {
        limit: jest.fn().mockReturnValue({
          get: jest.fn().mockResolvedValue({
            empty: false,
            docs: [{ id: AXIS_ID }],
          }),
        }),
      };
    }
    if (
      path ===
      `groups/${INPUT.groupID}/userCategoryAxes/${AXIS_ID}/categories`
    ) {
      return {
        get: jest.fn().mockResolvedValue({
          docs: [
            {
              id: NIKU_ID,
              data: () => ({ name: "肉", locationOrders: {} }),
            },
            {
              id: YASAI_ID,
              data: () => ({ name: "野菜", locationOrders: {} }),
            },
          ],
        }),
      };
    }
    if (path === `groups/${INPUT.groupID}/shoppingLocations`) {
      return {
        get: jest.fn().mockResolvedValue({
          docs: [{ id: LOC_ID, data: () => ({ name: "テストスーパー" }) }],
        }),
      };
    }
    return { get: jest.fn().mockResolvedValue({ docs: [] }) };
  });

  const firstRef = { id: NIKU_ID };
  const secondRef = { id: YASAI_ID };
  mockDocFn.mockImplementation((path: string) =>
    path.includes(NIKU_ID) ? firstRef : secondRef
  );

  mockTransactionGet.mockImplementation(async (ref: any) => {
    if (ref.id === NIKU_ID) {
      return { data: () => ({ name: "肉", locationOrders: {} }) };
    }
    return { data: () => ({ name: "野菜", locationOrders: {} }) };
  });
}

beforeEach(() => {
  jest.clearAllMocks();
  mockAppEnv.mockReturnValue("dev");
});

describe("setupTestCategoryLocationOrder", () => {
  test("正常系: dev環境でlocationOrdersを更新できる", async () => {
    setupDefaultMocks();

    const result = await capturedFlowFn(INPUT);

    expect(result.result).toBe("OK");
    expect(result.data.success).toBe(true);
    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
    expect(mockTransactionUpdate).toHaveBeenCalledTimes(2);
    expect(mockTransactionUpdate).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        locationOrders: { [LOC_ID]: 0 },
        serverUpdatedDateTime: "SERVER_TIMESTAMP",
      })
    );
    expect(mockTransactionUpdate).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        locationOrders: { [LOC_ID]: 1 },
        serverUpdatedDateTime: "SERVER_TIMESTAMP",
      })
    );
  });

  test("異常系: prod環境では実行できない", async () => {
    mockAppEnv.mockReturnValue("prod");
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn(INPUT);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("この機能は開発環境でのみ使用できます");
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  test("異常系: 未認証では実行できない", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn(INPUT);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: userCategoryAxes が空の場合はNGを返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockCollection.mockImplementation(() => ({
      limit: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({ empty: true, docs: [] }),
      }),
      get: jest.fn().mockResolvedValue({ docs: [] }),
    }));

    const result = await capturedFlowFn(INPUT);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("userCategoryAxes が見つかりません");
  });

  test("異常系: カテゴリが見つからない場合はNGを返す", async () => {
    setupDefaultMocks();
    // カテゴリ一覧を空にする
    mockCollection.mockImplementation((path: string) => {
      if (path === `groups/${INPUT.groupID}/userCategoryAxes`) {
        return {
          limit: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              empty: false,
              docs: [{ id: AXIS_ID }],
            }),
          }),
        };
      }
      return { get: jest.fn().mockResolvedValue({ docs: [] }) };
    });

    const result = await capturedFlowFn(INPUT);

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("カテゴリが見つかりません");
  });

  test("異常系: 場所が見つからない場合はNGを返す", async () => {
    setupDefaultMocks();
    // shoppingLocations を空にする
    const originalImpl = mockCollection.getMockImplementation()!;
    mockCollection.mockImplementation((path: string) => {
      if (path === `groups/${INPUT.groupID}/shoppingLocations`) {
        return { get: jest.fn().mockResolvedValue({ docs: [] }) };
      }
      return originalImpl(path);
    });

    const result = await capturedFlowFn(INPUT);

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("場所が見つかりません");
  });
});
