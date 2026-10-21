// firebase-admin のモック
const mockSet = jest.fn();
const mockDoc = jest.fn(() => ({ set: mockSet }));
const mockCollection = jest.fn(() => ({ doc: mockDoc }));
const mockFirestoreInstance = {
  collection: mockCollection,
};

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
    serverTimestamp: jest.fn(() => "SERVER_TIMESTAMP"),
  },
}));

// genkit のモック
const mockCurrentContext = jest.fn();
let capturedFlowFn: (input: Record<string, never>) => Promise<any>;

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
  defineSecret: jest.fn(() => ({ value: () => "test-rc-secret-key" })),
}));

const originalFetch = global.fetch;
const mockFetch = jest.fn();

beforeEach(() => {
  jest.clearAllMocks();
  (global as any).fetch = mockFetch;
});

afterAll(() => {
  (global as any).fetch = originalFetch;
});

// モジュール読み込み（モック設定後）
const { Timestamp } = jest.requireActual("firebase-admin/firestore");
require("./function");

describe("syncPremiumEntitlement", () => {
  test("正常系: RevenueCat のプレミアム状態を本人の premiumEntitlements に書き写す", async () => {
    const expiresDateText = new Date(
      Date.now() + 24 * 60 * 60 * 1000
    ).toISOString();
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({
      ok: true,
      json: async () => ({
        subscriber: {
          entitlements: { Premium: { expires_date: expiresDateText } },
        },
      }),
    });

    const result = await capturedFlowFn({});

    expect(result).toEqual({ result: "OK", data: { isPremium: true } });
    expect(mockCollection).toHaveBeenCalledWith(
      "users/user-1/premiumEntitlements"
    );
    expect(mockDoc).toHaveBeenCalledWith("PremiumEntitlement_users_user-1");
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({
        userID: "user-1",
        isPremium: true,
        expiresDateTime: Timestamp.fromDate(new Date(expiresDateText)),
      }),
      { merge: true }
    );
  });

  test("正常系: entitlement が無いユーザーは isPremium: false を書く", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({
      ok: true,
      json: async () => ({ subscriber: { entitlements: {} } }),
    });

    const result = await capturedFlowFn({});

    expect(result).toEqual({ result: "OK", data: { isPremium: false } });
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({ isPremium: false, expiresDateTime: null }),
      { merge: true }
    );
  });

  test("異常系: RevenueCat API がエラーを返したら写しを書き換えず NG を返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({ ok: false, status: 500 });

    const result = await capturedFlowFn({});

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("RevenueCat APIエラー: 500");
    expect(mockSet).not.toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーが弾かれる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({});

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
    expect(mockFetch).not.toHaveBeenCalled();
    expect(mockSet).not.toHaveBeenCalled();
  });
});
