const mockCollection = jest.fn();
const mockCurrentContext = jest.fn();
const mockDelete = jest.fn().mockResolvedValue(undefined);

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: () => ({ collection: mockCollection }),
    storage: () => ({
      bucket: () => ({ file: () => ({ delete: mockDelete }) }),
    }),
  },
}));

let capturedFlowFn: (input: {
  groupID: string;
  shoppingListID: string;
  itemID: string;
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
jest.mock("firebase-functions/https", () => ({
  onCallGenkit: (_: any, flow: any) => flow,
}));
jest.mock("../utils/authPolicy", () => ({
  appAuthPolicy: jest.fn(() => () => true),
}));
jest.mock("firebase-functions", () => ({ logger: { error: jest.fn() } }));

require("./function");

const defaultInput = {
  groupID: "group-1",
  shoppingListID: "list-1",
  itemID: "item-1",
};

describe("deleteShoppingListItemImage", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: メンバーは削除できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockCollection.mockReturnValue({
      doc: () => ({
        get: async () => ({
          data: () => ({ memberUserIDs: ["user-1"] }),
        }),
      }),
    });

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
    mockCollection.mockReturnValue({
      doc: () => ({
        get: async () => ({
          data: () => ({ memberUserIDs: ["user-2"] }),
        }),
      }),
    });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });
});
