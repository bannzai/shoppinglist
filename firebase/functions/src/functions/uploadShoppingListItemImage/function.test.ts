const mockCollection = jest.fn();
const mockFirestoreInstance = {
  collection: mockCollection,
};
const mockGetUser = jest.fn();
const mockCurrentContext = jest.fn();
const mockSave = jest.fn().mockResolvedValue(undefined);
const mockGetDownloadURL = jest
  .fn()
  .mockResolvedValue("https://example.com/item-photo.jpg");

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    auth: () => ({ getUser: mockGetUser }),
    firestore: () => mockFirestoreInstance,
    storage: () => ({
      bucket: () => ({ file: () => ({ save: mockSave }) }),
    }),
  },
}));

let capturedFlowFn: (input: {
  groupID: string;
  shoppingListID: string;
  itemID: string;
  mimeType: string;
  base64Image: string;
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
jest.mock("firebase-admin/storage", () => ({
  getDownloadURL: mockGetDownloadURL,
}));
jest.mock("firebase-functions/https", () => ({
  onCallGenkit: (flow: any) => flow,
}));
jest.mock("firebase-functions", () => ({ logger: { error: jest.fn() } }));

require("./function");

/** グループメンバーかつitemが存在するFirestoreモックを構築する。 */
function setupFirestoreMock({
  memberUserIDs,
  itemExists,
}: {
  memberUserIDs: string[];
  itemExists: boolean;
}) {
  mockCollection.mockImplementation((path: string) => {
    if (path === "groups") {
      return {
        doc: () => ({
          get: async () => ({
            data: () => ({ memberUserIDs }),
          }),
          collection: () => ({
            doc: () => ({
              collection: () => ({
                doc: () => ({
                  get: async () => ({ exists: itemExists }),
                }),
              }),
            }),
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
  itemID: "item-1",
  mimeType: "image/jpeg",
  // "hello" の base64 (8文字 → padding込み)
  base64Image: "aGVsbG8=",
};

describe("uploadShoppingListItemImage", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("正常系: プレミアムユーザーが画像アップロードできる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: true } });
    setupFirestoreMock({ memberUserIDs: ["user-1"], itemExists: true });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("OK");
    expect(result.data.imageURL).toContain("https://");
    expect(mockSave).toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({});

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
  });

  test("異常系: 非プレミアムユーザーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: false } });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("商品写真の添付はプレミアム機能です");
  });

  test("異常系: 非メンバーはエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: true } });
    setupFirestoreMock({ memberUserIDs: ["user-2"], itemExists: true });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("グループのメンバーではありません");
  });

  test("異常系: 対象itemが存在しない場合エラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: true } });
    setupFirestoreMock({ memberUserIDs: ["user-1"], itemExists: false });

    const result = await capturedFlowFn(defaultInput);

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("対象のアイテムが存在しません");
  });

  test("異常系: 非許可MIME typeでエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: true } });
    setupFirestoreMock({ memberUserIDs: ["user-1"], itemExists: true });

    const result = await capturedFlowFn({
      ...defaultInput,
      mimeType: "image/gif",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像形式がサポートされていません");
  });

  test("異常系: 空の画像データでエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: true } });
    setupFirestoreMock({ memberUserIDs: ["user-1"], itemExists: true });

    const result = await capturedFlowFn({
      ...defaultInput,
      base64Image: "",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像データ形式が不正です");
  });

  test("異常系: 不正なbase64フォーマットでエラー", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockGetUser.mockResolvedValue({ customClaims: { isPremium: true } });
    setupFirestoreMock({ memberUserIDs: ["user-1"], itemExists: true });

    const result = await capturedFlowFn({
      ...defaultInput,
      base64Image: "!!!invalid!!!base64",
    });

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("画像データ形式が不正です");
  });
});
