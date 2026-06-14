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
});

describe("buildInquirySlackBlocks", () => {
  it("問い合わせID/メール/復元コマンドを含む", () => {
    const json = JSON.stringify(buildInquirySlackBlocks(baseInquiry));
    expect(json).toContain("INQ123");
    expect(json).toContain("foo@example.com");
    expect(json).toContain("script-restore-inquiry-snapshot");
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
