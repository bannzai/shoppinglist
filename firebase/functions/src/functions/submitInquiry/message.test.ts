import { buildInquirySlackBlocks, buildInquirySlackText } from "./message";
import { Inquiry } from "../../entity/inquiry";

const baseInquiry: Inquiry = {
  id: "INQ123",
  userID: "user-abc",
  email: "foo@example.com",
  categoryType: "bugReport",
  content: "アイテムが消えました",
  platform: "ios",
  appVersion: "1.0.0 (1)",
  snapshotJson: "[]",
  snapshotOmittedReason: null,
  slackNotified: false,
};

describe("buildInquirySlackText", () => {
  it("カテゴリラベルと本文を含む", () => {
    const text = buildInquirySlackText(baseInquiry);
    expect(text).toContain("不具合報告");
    expect(text).toContain("アイテムが消えました");
  });

  it("本文が上限を超える場合は省略する", () => {
    const text = buildInquirySlackText({
      ...baseInquiry,
      content: "あ".repeat(5000),
    });
    expect(text).toContain("…(省略)");
  });

  it("本文の Slack 制御記法をエスケープする", () => {
    const text = buildInquirySlackText({
      ...baseInquiry,
      content: "<!channel> <https://evil|label>",
    });
    expect(text).toContain("&lt;!channel&gt; &lt;https://evil|label&gt;");
    expect(text).not.toContain("<!");
    expect(text).not.toContain("<http");
  });

  it("切り詰め位置が実体参照の途中でも断片を残さない", () => {
    // エスケープ後の 2900 文字目が "&amp;" の途中("&am")に来る入力
    const text = buildInquirySlackText({
      ...baseInquiry,
      content: `${"a".repeat(2897)}&<`,
    });
    const body = text.slice(text.indexOf("] ") + 2);
    expect(body).toBe(`${"a".repeat(2897)}…(省略)`);
  });
});

describe("buildInquirySlackBlocks", () => {
  it("問い合わせID/メール/復元コマンドを含む", () => {
    const json = JSON.stringify(buildInquirySlackBlocks(baseInquiry));
    expect(json).toContain("INQ123");
    expect(json).toContain("foo@example.com");
    expect(json).toContain("script-restore-inquiry-snapshot");
  });

  it("本文とアプリバージョンの Slack 制御記法をエスケープする", () => {
    const json = JSON.stringify(
      buildInquirySlackBlocks({
        ...baseInquiry,
        content: "<!channel> <https://evil|label>",
        appVersion: "<!here> <@U123>",
      })
    );
    expect(json).toContain("&lt;!channel&gt; &lt;https://evil|label&gt;");
    expect(json).toContain("&lt;!here&gt; &lt;@U123&gt;");
    expect(json).not.toContain("<!");
    expect(json).not.toContain("<http");
    expect(json).not.toContain("<@");
  });

  it("スナップショットが無い場合は理由を表示する", () => {
    const json = JSON.stringify(
      buildInquirySlackBlocks({
        ...baseInquiry,
        snapshotJson: null,
        snapshotOmittedReason: "too large",
      })
    );
    expect(json).toContain("too large");
  });
});
