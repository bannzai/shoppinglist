import { InquiryAppVersionSchema } from "./inquiry";

describe("InquiryAppVersionSchema", () => {
  it("クライアントが送る形式を受け付ける", () => {
    expect(InquiryAppVersionSchema.safeParse("1.0.1 (1)").success).toBe(true);
    expect(
      InquiryAppVersionSchema.safeParse("10.20.30-beta.12 (12345)").success
    ).toBe(true);
  });

  it("33 文字以上を拒否する", () => {
    expect(InquiryAppVersionSchema.safeParse("1".repeat(32)).success).toBe(
      true
    );
    expect(InquiryAppVersionSchema.safeParse("1".repeat(33)).success).toBe(
      false
    );
  });

  it("Slack の制御記法に使う文字を拒否する", () => {
    expect(InquiryAppVersionSchema.safeParse("<!channel>").success).toBe(false);
    expect(InquiryAppVersionSchema.safeParse("1.0.0 & 2").success).toBe(false);
  });

  it("空文字を拒否する", () => {
    expect(InquiryAppVersionSchema.safeParse("").success).toBe(false);
  });
});
