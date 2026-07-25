const mockCollection = jest.fn();
const mockRecursiveDelete = jest.fn().mockResolvedValue(undefined);
const mockFirestoreInstance = {
  collection: mockCollection,
  recursiveDelete: mockRecursiveDelete,
};
const mockCurrentContext = jest.fn();
const mockDeleteFiles = jest.fn().mockResolvedValue(undefined);

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: () => mockFirestoreInstance,
    storage: () => ({
      bucket: () => ({ deleteFiles: mockDeleteFiles }),
    }),
  },
}));

let capturedFlowFn: (input: {
  groupID: string;
  shoppingListID: string;
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
  onCallGenkit: (_opts: any, flow: any) => flow,
}));
jest.mock("firebase-functions", () => ({ logger: { error: jest.fn() } }));

require("./function");

/** recursiveDelete の呼び出し引数検証用に、リストドキュメント参照を一意なオブジェクトにする。 */
const mockShoppingListDocRef = { id: "list-1" };

/** グループメンバーシップとリストドキュメント参照を返すFirestoreモックを構築する。 */
function setupFirestoreMock({ memberUserIDs }: { memberUserIDs: string[] }) {
  mockCollection.mockImplementation((path: string) => {
    if (path === "groups") {
      return {
        doc: () => ({
          get: async () => ({
            data: () => ({ memberUserIDs }),
          }),
          collection: () => ({
            doc: () => mockShoppingListDocRef,
          }),
        }),
      };
    }
    return {};
  });
}

const defaultInput = {
  groupID: "group-1",
  shoppingListID: "list-1",
};

describe("deleteShoppingList", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockRecursiveDelete.mockResolvedValue(undefined);
    mockDeleteFiles.mockResolvedValue(undefined);
  });

  test("正常系: グループメンバーがリスト配下のStorage画像とドキュメントを再帰削除できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupFirestoreMock({ memberUserIDs: ["user-1"] });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    // レシート画像と商品写真の両方を消すため、リスト配下全体の prefix で削除すること。
    expect(mockDeleteFiles).toHaveBeenCalledWith({
      prefix: "groups/group-1/shoppingLists/list-1/",
    });
    // リストドキュメント本体と items / receipts サブコレクションの再帰削除。
    expect(mockRecursiveDelete).toHaveBeenCalledWith(mockShoppingListDocRef);
  });

  test("異常系: 未認証ユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({});

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
    expect(mockDeleteFiles).not.toHaveBeenCalled();
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });

  test("異常系: 非メンバーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupFirestoreMock({ memberUserIDs: ["user-2"] });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
    expect(mockDeleteFiles).not.toHaveBeenCalled();
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });

  test("異常系: Storage削除が失敗した場合はエラーを返しFirestoreを削除しない", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupFirestoreMock({ memberUserIDs: ["user-1"] });
    mockDeleteFiles.mockRejectedValue(new Error("storage down"));

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("リストの削除に失敗しました");
    // リストドキュメントを残すことで、UI からのリスト再削除でリトライできる。
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });

  test("異常系: Firestore再帰削除が失敗した場合はエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    setupFirestoreMock({ memberUserIDs: ["user-1"] });
    mockRecursiveDelete.mockRejectedValue(new Error("firestore down"));

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("リストの削除に失敗しました");
  });
});
