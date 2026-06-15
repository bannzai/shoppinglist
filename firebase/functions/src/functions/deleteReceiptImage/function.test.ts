const mockCollection = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
};
const mockCurrentContext = jest.fn();
const mockDelete = jest.fn().mockResolvedValue(undefined);

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: () => mockFirestoreInstance,
    storage: () => ({
      bucket: () => ({ file: () => ({ delete: mockDelete }) }),
    }),
  },
}));

let capturedFlowFn: (input: {
  groupID: string;
  shoppingListID: string;
  receiptID: string;
}) => Promise<any>;

jest.mock("../utils/genkit", () => ({
  ai: {
    defineFlow: (_config: unknown, fn: any) => {
      capturedFlowFn = fn;
      return fn;
    },
    currentContext: mockCurrentContext,
  },
}));
jest.mock("../utils/authPolicy", () => ({
  appAuthPolicy: () => () => undefined,
}));
jest.mock("firebase-functions/https", () => ({
  onCallGenkit: (_opts: any, flow: any) => flow,
}));
jest.mock("firebase-functions", () => ({ logger: { error: jest.fn() } }));

require("./function");

/** グループメンバーシップのFirestoreモックを構築する。 */
function setupFirestoreMock({ memberUserIDs }: { memberUserIDs: string[] }) {
  mockCollection.mockImplementation((path: string) => {
    if (path === "groups") {
      return {
        doc: () => ({
          get: async () => ({ data: () => ({ memberUserIDs }) }),
        }),
      };
    }
    return {};
  });
}

const defaultInput = {
  groupID: "group-1",
  shoppingListID: "list-1",
  receiptID: "receipt-1",
};

describe("deleteReceiptImage", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: メンバーがレシート画像を削除できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupFirestoreMock({ memberUserIDs: ["user-1"] });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(mockDelete).toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({});

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: 非メンバーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupFirestoreMock({ memberUserIDs: ["user-2"] });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });
});
