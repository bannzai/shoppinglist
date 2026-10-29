import {
  escapeSlackText,
  inquirySlackChannelID,
  TEST_NOTIFICATION_CHANNEL_ID,
} from "./slack";

describe("inquirySlackChannelID", () => {
  it("test: true の時は #test-notification のチャンネル ID を返す", () => {
    expect(
      inquirySlackChannelID({ test: true, inquiryChannelID: "C_INQUIRY" })
    ).toBe("C0CD2MGHCAJ");
    expect(TEST_NOTIFICATION_CHANNEL_ID).toBe("C0CD2MGHCAJ");
  });

  it("test: false の時は SLACK_INQUIRY_CHANNEL_ID のチャンネルを返す", () => {
    expect(
      inquirySlackChannelID({ test: false, inquiryChannelID: "C_INQUIRY" })
    ).toBe("C_INQUIRY");
  });
});

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
