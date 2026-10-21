jest.mock("firebase-functions", () => ({
  logger: { info: jest.fn(), error: jest.fn() },
}));

jest.mock("firebase-functions/params", () => ({
  defineSecret: jest.fn(() => ({ value: () => "test-rc-secret-key" })),
}));

const mockFetch = jest.fn();
global.fetch = mockFetch;

import { fetchPremiumEntitlementState, hasPremiumEntitlement } from "./premium";

/** RevenueCat Subscribers APIの正常レスポンスを構築するヘルパー。 */
function subscriberResponse(
  entitlements: Record<string, { expires_date: string | null }>
) {
  return {
    ok: true,
    json: async () => ({ subscriber: { entitlements } }),
  };
}

describe("hasPremiumEntitlement", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Premium entitlement が有効期限内なら true", async () => {
    mockFetch.mockResolvedValue(
      subscriberResponse({
        Premium: {
          expires_date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        },
      })
    );

    expect(await hasPremiumEntitlement("user-1")).toBe(true);
  });

  test("expires_date が null（無期限）なら true", async () => {
    mockFetch.mockResolvedValue(
      subscriberResponse({ Premium: { expires_date: null } })
    );

    expect(await hasPremiumEntitlement("user-1")).toBe(true);
  });

  test("expires_date が過去なら false", async () => {
    mockFetch.mockResolvedValue(
      subscriberResponse({
        Premium: {
          expires_date: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
        },
      })
    );

    expect(await hasPremiumEntitlement("user-1")).toBe(false);
  });

  test("Premium entitlement が存在しなければ false", async () => {
    mockFetch.mockResolvedValue(subscriberResponse({}));

    expect(await hasPremiumEntitlement("user-1")).toBe(false);
  });

  test("APIがエラーstatusを返したら false", async () => {
    mockFetch.mockResolvedValue({ ok: false, status: 500 });

    expect(await hasPremiumEntitlement("user-1")).toBe(false);
  });

  test("fetch が例外を投げたら false", async () => {
    mockFetch.mockRejectedValue(new Error("network error"));

    expect(await hasPremiumEntitlement("user-1")).toBe(false);
  });

  test("APIがエラーstatusを返したら fetchPremiumEntitlementState は例外を投げる", async () => {
    mockFetch.mockResolvedValue({ ok: false, status: 500 });

    await expect(fetchPremiumEntitlementState("user-1")).rejects.toThrow(
      "RevenueCat APIエラー: 500"
    );
  });

  test("fetchPremiumEntitlementState は有効期限を Date で返す", async () => {
    const expiresDateText = new Date(
      Date.now() + 24 * 60 * 60 * 1000
    ).toISOString();
    mockFetch.mockResolvedValue(
      subscriberResponse({ Premium: { expires_date: expiresDateText } })
    );

    expect(await fetchPremiumEntitlementState("user-1")).toEqual({
      isPremium: true,
      expiresDateTime: new Date(expiresDateText),
    });
  });

  test("fetchPremiumEntitlementState は entitlement が無ければ無料・期限 null を返す", async () => {
    mockFetch.mockResolvedValue(subscriberResponse({}));

    expect(await fetchPremiumEntitlementState("user-1")).toEqual({
      isPremium: false,
      expiresDateTime: null,
    });
  });

  test("uidをURLエンコードしSecret Keyを付与してSubscribers APIを呼ぶ", async () => {
    mockFetch.mockResolvedValue(subscriberResponse({}));

    await hasPremiumEntitlement("user/1");

    expect(mockFetch).toHaveBeenCalledWith(
      "https://api.revenuecat.com/v1/subscribers/user%2F1",
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: "Bearer test-rc-secret-key",
        }),
      })
    );
  });
});
