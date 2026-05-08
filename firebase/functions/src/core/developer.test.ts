const mockGet = jest.fn();
const mockDoc = jest.fn(() => ({ get: mockGet }));
const mockCollection = jest.fn(() => ({ doc: mockDoc }));

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: jest.fn(() => ({ collection: mockCollection })),
    initializeApp: jest.fn(),
  },
}));

const mockSecretValue = jest.fn();
jest.mock("firebase-functions/params", () => ({
  defineSecret: jest.fn(() => ({ value: () => mockSecretValue() })),
}));

import { isDeveloper } from "./developer";

beforeEach(() => {
  jest.clearAllMocks();
});

describe("isDeveloper", () => {
  test("Secret 未設定なら false", async () => {
    mockSecretValue.mockReturnValue("");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: "token-1" }) });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("Secret と user.developerToken が一致したら true", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: "token-1" }) });
    expect(await isDeveloper("user-1")).toBe(true);
    expect(mockCollection).toHaveBeenCalledWith("users");
    expect(mockDoc).toHaveBeenCalledWith("user-1");
  });

  test("Secret と user.developerToken が異なれば false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: "token-2" }) });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("user.developerToken 未設定なら false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({}) });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("user ドキュメントが存在しなくても false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => undefined });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("user.developerToken が string 以外なら false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: 123 }) });
    expect(await isDeveloper("user-1")).toBe(false);
  });
});
