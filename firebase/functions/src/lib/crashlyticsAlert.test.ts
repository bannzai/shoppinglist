import type { Issue } from "firebase-functions/v2/alerts/crashlytics";
import { crashlyticsSlackChannel, currentProjectId, formatCrashlyticsAlertText } from "./crashlyticsAlert";

describe("crashlyticsSlackChannel", () => {
  it("本番のプロジェクト ID では本番の通知チャンネルを返す", () => {
    expect(crashlyticsSlackChannel("shoppinglist-prod-857bb")).toBe("#shoppinglist-notification");
  });

  it("別のプロジェクト ID では -qa のチャンネルを返す", () => {
    expect(crashlyticsSlackChannel("shoppinglist-dev-b2787")).toBe("#shoppinglist-notification-qa");
  });

  it("空文字では -qa のチャンネルを返す", () => {
    expect(crashlyticsSlackChannel("")).toBe("#shoppinglist-notification-qa");
  });

  it("プロジェクト ID の環境変数が無い時は -qa のチャンネルを返す", () => {
    const { GCLOUD_PROJECT, FIREBASE_CONFIG } = process.env;
    delete process.env.GCLOUD_PROJECT;
    delete process.env.FIREBASE_CONFIG;
    try {
      expect(crashlyticsSlackChannel(currentProjectId())).toBe("#shoppinglist-notification-qa");
    } finally {
      if (GCLOUD_PROJECT !== undefined) process.env.GCLOUD_PROJECT = GCLOUD_PROJECT;
      if (FIREBASE_CONFIG !== undefined) process.env.FIREBASE_CONFIG = FIREBASE_CONFIG;
    }
  });
});

const maliciousIssue: Issue = {
  id: "issue-1",
  title: "<!channel> <https://evil|Firebase Console>",
  subtitle: "<!here> & <@U123>",
  appVersion: "<!everyone>",
};

describe("formatCrashlyticsAlertText", () => {
  it("issue の title・subtitle・appVersion と detail の Slack 制御記法をエスケープする", () => {
    const text = formatCrashlyticsAlertText({
      kind: "velocity",
      projectId: "project-1",
      appId: "app-1",
      issue: maliciousIssue,
      detail: "初出バージョン <!channel>",
    });
    expect(text).toContain("&lt;!channel&gt; &lt;https://evil|Firebase Console&gt;");
    expect(text).toContain("&lt;!here&gt; &amp; &lt;@U123&gt;");
    expect(text).toContain("バージョン &lt;!everyone&gt;");
    expect(text).toContain("初出バージョン &lt;!channel&gt;");
    expect(text).not.toContain("<!");
    expect(text).not.toContain("<http");
    expect(text).not.toContain("<@");
  });

  it("コンソール URL と分析コマンドはエスケープしない", () => {
    const text = formatCrashlyticsAlertText({
      kind: "newFatalIssue",
      projectId: "project-1",
      appId: "app-1",
      issue: { id: "issue-1", title: "Crash", subtitle: "main.dart", appVersion: "1.0.1 (1)" },
    });
    expect(text).toContain(
      "https://console.firebase.google.com/project/project-1/crashlytics/app/app-1/issues/issue-1"
    );
    expect(text).toContain("/firebase-crashlytics-triage --app-id app-1 --issue-id issue-1");
  });
});
