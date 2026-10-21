const mockRecountActiveShoppingLists = jest.fn();
let capturedHandler: (event: any) => Promise<void>;

jest.mock("firebase-functions/v2/firestore", () => ({
  onDocumentWritten: (_options: unknown, handler: any) => {
    capturedHandler = handler;
    return handler;
  },
}));

jest.mock("firebase-functions", () => ({
  logger: { info: jest.fn(), error: jest.fn() },
}));

jest.mock("./activeShoppingListCount", () => ({
  ...jest.requireActual("./activeShoppingListCount"),
  recountActiveShoppingLists: (...args: unknown[]) =>
    mockRecountActiveShoppingLists(...args),
}));

require("./function");

/** onDocumentWritten の event を、書き込み前後の買い物リストの文書から組み立てる。 */
function writtenEvent({
  before,
  after,
}: {
  before: { status?: string } | undefined;
  after: { status?: string } | undefined;
}) {
  return {
    params: { groupID: "g1", shoppingListID: "sl1" },
    data: {
      before: { data: () => before },
      after: { data: () => after },
    },
  };
}

describe("updateActiveShoppingListCount", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("active での作成・active からの変更・削除で数え直す", async () => {
    await capturedHandler(
      writtenEvent({ before: undefined, after: { status: "active" } })
    );
    await capturedHandler(
      writtenEvent({ before: { status: "active" }, after: { status: "done" } })
    );
    await capturedHandler(
      writtenEvent({ before: { status: "active" }, after: undefined })
    );

    expect(mockRecountActiveShoppingLists).toHaveBeenCalledTimes(3);
    expect(mockRecountActiveShoppingLists).toHaveBeenCalledWith("g1");
  });

  test("active かどうかが変わらない書き込みでは数え直さない", async () => {
    await capturedHandler(
      writtenEvent({ before: { status: "active" }, after: { status: "active" } })
    );
    await capturedHandler(
      writtenEvent({ before: { status: "done" }, after: { status: "archived" } })
    );
    await capturedHandler(
      writtenEvent({ before: undefined, after: { status: "done" } })
    );

    expect(mockRecountActiveShoppingLists).not.toHaveBeenCalled();
  });
});
