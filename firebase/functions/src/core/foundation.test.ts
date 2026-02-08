import {
  millisecond,
  second,
  minute,
  hour,
  day,
  nonNullable,
  chunk,
} from "./foundation";

describe("時間定数", () => {
  test("millisecond は 1", () => {
    expect(millisecond).toBe(1);
  });

  test("second は 1000 ミリ秒", () => {
    expect(second).toBe(1000);
  });

  test("minute は 60 秒", () => {
    expect(minute).toBe(60 * 1000);
  });

  test("hour は 60 分", () => {
    expect(hour).toBe(60 * 60 * 1000);
  });

  test("day は 24 時間", () => {
    expect(day).toBe(24 * 60 * 60 * 1000);
  });
});

describe("nonNullable", () => {
  test("null は false を返す", () => {
    expect(nonNullable(null)).toBe(false);
  });

  test("undefined は false を返す", () => {
    expect(nonNullable(undefined)).toBe(false);
  });

  test("0 は true を返す", () => {
    expect(nonNullable(0)).toBe(true);
  });

  test("空文字列は true を返す", () => {
    expect(nonNullable("")).toBe(true);
  });

  test("オブジェクトは true を返す", () => {
    expect(nonNullable({ key: "value" })).toBe(true);
  });
});

describe("chunk", () => {
  test("配列を指定サイズで分割する", () => {
    expect(chunk([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
  });

  test("配列サイズがオフセットの倍数の場合", () => {
    expect(chunk([1, 2, 3, 4], 2)).toEqual([
      [1, 2],
      [3, 4],
    ]);
  });

  test("空配列は空配列を返す", () => {
    expect(chunk([], 3)).toEqual([]);
  });

  test("オフセットが配列サイズより大きい場合、1つの配列にまとめる", () => {
    expect(chunk([1, 2], 10)).toEqual([[1, 2]]);
  });

  test("元の配列を変更しない", () => {
    const original = [1, 2, 3];
    chunk(original, 2);
    expect(original).toEqual([1, 2, 3]);
  });
});
