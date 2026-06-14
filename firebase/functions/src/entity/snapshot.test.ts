import { Timestamp } from "firebase-admin/firestore";
import {
  serializeFirestoreValue,
  deserializeFirestoreValue,
  SnapshotEntry,
} from "./snapshot";

describe("snapshot serialize/deserialize", () => {
  it("Timestamp を round-trip できる", () => {
    const restored = deserializeFirestoreValue(
      serializeFirestoreValue(new Timestamp(1700000000, 123000000))
    );
    expect(restored).toBeInstanceOf(Timestamp);
    expect((restored as Timestamp).seconds).toBe(1700000000);
    expect((restored as Timestamp).nanoseconds).toBe(123000000);
  });

  it("ネストした構造の Timestamp も JSON 経由で変換する", () => {
    const data = {
      name: "a",
      items: [{ at: new Timestamp(1, 0) }],
      tags: ["x", "y"],
    };
    const round = deserializeFirestoreValue(
      JSON.parse(JSON.stringify(serializeFirestoreValue(data)))
    ) as typeof data;
    expect(round.name).toBe("a");
    expect(round.tags).toEqual(["x", "y"]);
    expect(round.items[0].at).toBeInstanceOf(Timestamp);
    expect((round.items[0].at as Timestamp).seconds).toBe(1);
  });

  it("SnapshotEntry の data はそのまま保持される", () => {
    const entry: SnapshotEntry = {
      path: "groups/abc",
      data: serializeFirestoreValue({
        id: "abc",
        memberUserIDs: ["u1", "u2"],
      }) as Record<string, unknown>,
    };
    expect(entry.data.memberUserIDs).toEqual(["u1", "u2"]);
  });
});
