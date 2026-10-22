// firebase-admin のモック
const mockTransactionGet = jest.fn();
const mockTransactionUpdate = jest.fn();
const mockRunTransaction = jest.fn(async (updateFunction: any) =>
  updateFunction({ get: mockTransactionGet, update: mockTransactionUpdate })
);
const allShoppingListsCountQuery = { name: "allShoppingListsCount" };
const inactiveShoppingListsCountQuery = {
  name: "inactiveShoppingListsCount",
};
const mockWhere = jest.fn(() => ({
  count: () => inactiveShoppingListsCountQuery,
}));
const mockShoppingListsRef = {
  count: () => allShoppingListsCountQuery,
  where: mockWhere,
};
const mockGroupRef = {
  collection: jest.fn(() => mockShoppingListsRef),
};
const mockFirestoreInstance = {
  collection: jest.fn(() => ({ doc: jest.fn(() => mockGroupRef) })),
  runTransaction: mockRunTransaction,
};

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: jest.fn(() => mockFirestoreInstance),
  },
}));

jest.mock("firebase-admin/firestore", () => ({
  FieldValue: {
    serverTimestamp: jest.fn(() => "SERVER_TIMESTAMP"),
  },
}));

import {
  isActiveShoppingListData,
  recountActiveShoppingLists,
} from "./activeShoppingListCount";

/** transaction.get の戻り値を、渡された参照ごとに返し分ける。 */
function stubTransactionGet({
  groupExists,
  allShoppingListCount,
  inactiveShoppingListCount,
}: {
  groupExists: boolean;
  allShoppingListCount: number;
  inactiveShoppingListCount: number;
}) {
  mockTransactionGet.mockImplementation(async (ref: unknown) => {
    if (ref === mockGroupRef) {
      return { exists: groupExists };
    }
    if (ref === allShoppingListsCountQuery) {
      return { data: () => ({ count: allShoppingListCount }) };
    }
    if (ref === inactiveShoppingListsCountQuery) {
      return { data: () => ({ count: inactiveShoppingListCount }) };
    }
    throw new Error("unexpected ref");
  });
}

describe("isActiveShoppingListData", () => {
  test("status が active なら active", () => {
    expect(isActiveShoppingListData({ status: "active" })).toBe(true);
  });

  test("status が欠落していればクライアントの既定値に合わせて active", () => {
    expect(isActiveShoppingListData({})).toBe(true);
  });

  test("status が done / archived なら active ではない", () => {
    expect(isActiveShoppingListData({ status: "done" })).toBe(false);
    expect(isActiveShoppingListData({ status: "archived" })).toBe(false);
  });

  test("文書が無い (作成前・削除後) なら active ではない", () => {
    expect(isActiveShoppingListData(undefined)).toBe(false);
  });
});

describe("recountActiveShoppingLists", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("全リスト数から done / archived の数を引いた値をグループに書く", async () => {
    stubTransactionGet({
      groupExists: true,
      allShoppingListCount: 25,
      inactiveShoppingListCount: 4,
    });

    await recountActiveShoppingLists("g1");

    expect(mockWhere).toHaveBeenCalledWith("status", "in", [
      "done",
      "archived",
    ]);
    expect(mockTransactionUpdate).toHaveBeenCalledWith(mockGroupRef, {
      activeShoppingListCount: 21,
      serverUpdatedDateTime: "SERVER_TIMESTAMP",
    });
  });

  test("グループが削除済みなら何も書かない", async () => {
    stubTransactionGet({
      groupExists: false,
      allShoppingListCount: 0,
      inactiveShoppingListCount: 0,
    });

    await recountActiveShoppingLists("g1");

    expect(mockTransactionUpdate).not.toHaveBeenCalled();
  });
});
