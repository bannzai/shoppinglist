import { escapeSlackText } from "./slack";

describe("escapeSlackText", () => {
  it("& < > を実体参照に置換する", () => {
    expect(escapeSlackText("<!channel> & <https://evil|label>")).toBe(
      "&lt;!channel&gt; &amp; &lt;https://evil|label&gt;"
    );
  });

  it("& を二重にエスケープしない", () => {
    expect(escapeSlackText("&lt;")).toBe("&amp;lt;");
  });

  it("制御記法を含まない文字列はそのまま返す", () => {
    expect(escapeSlackText("アイテムが消えました")).toBe(
      "アイテムが消えました"
    );
  });
});
