import type { Issue } from "firebase-functions/v2/alerts/crashlytics";
import { formatCrashlyticsAlertText } from "./crashlyticsAlert";

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
