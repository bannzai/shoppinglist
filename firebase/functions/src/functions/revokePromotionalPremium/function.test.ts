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
  defineString: jest.fn(() => ({ value: () => "test-secret-key" })),
}));

const mockIsDeveloper = jest.fn();
jest.mock("../../core/developer", () => ({
  developerToken: { value: () => "test-secret-key" },
  isDeveloper: (...args: unknown[]) => mockIsDeveloper(...args),
}));

const originalFetch = global.fetch;
const mockFetch = jest.fn();

beforeEach(() => {
  jest.clearAllMocks();
  mockIsDeveloper.mockResolvedValue(true);
  (global as any).fetch = mockFetch;
});

afterAll(() => {
  (global as any).fetch = originalFetch;
});

// モジュール読み込み（モック設定後）
require("./function");

describe("revokePromotionalPremium", () => {
  test("正常系: 開発者として認証されたユーザーで剥奪できる", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({
      ok: true,
      status: 200,
      text: async () => "",
    });

    const result = await capturedFlowFn({});

    expect(result.result).toBe("OK");
    expect(result.data.success).toBe(true);
    expect(mockIsDeveloper).toHaveBeenCalledWith("user-1");
    expect(mockFetch).toHaveBeenCalledWith(
      "https://api.revenuecat.com/v1/subscribers/user-1/entitlements/Premium/revoke_promotionals",
      expect.objectContaining({
        method: "POST",
        headers: expect.objectContaining({
          Authorization: "Bearer test-secret-key",
          "Content-Type": "application/json",
        }),
      })
    );
  });

  test("異常系: 開発者ではないユーザーは実行できない", async () => {
    mockIsDeveloper.mockResolvedValue(false);
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });

    const result = await capturedFlowFn({});

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("開発者のみ");
    expect(mockFetch).not.toHaveBeenCalled();
  });

  test("異常系: 未認証ユーザーが弾かれる", async () => {
    mockCurrentContext.mockReturnValue(undefined);

    const result = await capturedFlowFn({});

    expect(result.result).toBe("NG");
    expect(result.error.message).toBe("認証されていません");
    expect(mockFetch).not.toHaveBeenCalled();
  });

  test("異常系: RevenueCat API がエラーを返す", async () => {
    mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
    mockFetch.mockResolvedValue({
      ok: false,
      status: 500,
      text: async () => "Internal",
    });

    const result = await capturedFlowFn({});

    expect(result.result).toBe("NG");
    expect(result.error.message).toContain("RevenueCat APIエラー: 500");
  });
});
