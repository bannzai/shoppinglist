import { defineSecret } from "firebase-functions/params";

/** Slack Bot User OAuth Token(xoxb-...)。chat:write スコープが必要。
 * `firebase functions:secrets:set SLACK_BOT_TOKEN` で設定する。 */
export const slackBotToken = defineSecret("SLACK_BOT_TOKEN");

/** お問い合わせ通知の投稿先 Slack チャンネル ID(例: C0XXXXXXX)。
 * `firebase functions:secrets:set SLACK_INQUIRY_CHANNEL_ID` で設定する。 */
export const slackInquiryChannelID = defineSecret("SLACK_INQUIRY_CHANNEL_ID");

/** テスト・QA の投稿先。bannzai のプロジェクト共通の `#test-notification` のチャンネル ID。
 * files.completeUploadExternal の channel_id はチャンネル名を受け付けないため ID で持つ。
 * 値と運用は bannzai/castle の home/.claude/documents/rules/slack-test-notification-channel.md が正。 */
export const TEST_NOTIFICATION_CHANNEL_ID = "C0CD2MGHCAJ";

/** お問い合わせ通知の投稿先チャンネル ID を返す。
 * リクエストにテスト用の引数 `test: true` が付いている時だけ `#test-notification`、それ以外は本番の
 * `inquiryChannelID` を返す。実行中のプロジェクト (dev / prod) では切り替えない
 * (規約: bannzai/castle の home/.claude/documents/rules/slack-test-notification-channel.md)。 */
export function inquirySlackChannelID(args: {
  test: boolean;
  inquiryChannelID: string;
}): string {
  return args.test ? TEST_NOTIFICATION_CHANNEL_ID : args.inquiryChannelID;
}

/** ユーザー・クライアント由来の文字列を、Slack の mrkdwn / text で制御記法
 * (`<!channel>`・`<@U…>`・`<https://…|label>` 等) として解釈されない形に変換する。
 * Slack が求めるエスケープは `&`・`<`・`>` の 3 文字だけ
 * (https://docs.slack.dev/messaging/formatting-message-text#escaping )。
 * `&` を先に置換しないと、他の 2 文字の置換結果を二重にエスケープしてしまう。 */
export function escapeSlackText(text: string): string {
  return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/** Slack Web API のベース URL。 */
const SLACK_API_BASE = "https://slack.com/api";

/** chat.postMessage のレスポンス(参照するフィールドのみ)。 */
interface SlackPostMessageResponse {
  ok: boolean;
  error?: string;
  ts?: string;
}

/** Slack の指定チャンネルへメッセージを投稿する。
 * 投稿に成功するとスレッド親の ts を返す(将来のスレッド返信・ファイル添付に利用できる)。
 * blocks は Block Kit。通知・アクセシビリティ用のフォールバック text も必須。 */
export async function postSlackMessage(args: {
  token: string;
  channel: string;
  text: string;
  blocks?: unknown[];
}): Promise<string> {
  const response = await fetch(`${SLACK_API_BASE}/chat.postMessage`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${args.token}`,
      "Content-Type": "application/json; charset=utf-8",
    },
    body: JSON.stringify({
      channel: args.channel,
      text: args.text,
      blocks: args.blocks,
    }),
  });
  const result = (await response.json()) as SlackPostMessageResponse;
  if (!result.ok) {
    throw new Error(`Slack API error: ${result.error ?? "unknown"}`);
  }
  return result.ts ?? "";
}

/** files.getUploadURLExternal のレスポンス(参照するフィールドのみ)。 */
interface SlackUploadURLResponse {
  ok: boolean;
  error?: string;
  upload_url?: string;
  file_id?: string;
}

/** Slack の指定スレッドへテキストファイルを添付する(3ステップアップロード)。
 * files:write スコープが必要。スナップショット JSON 等の添付に使う。 */
export async function uploadFileToSlackThread(args: {
  token: string;
  channel: string;
  threadTs: string;
  filename: string;
  content: string;
}): Promise<void> {
  // 1. アップロード URL とファイル ID を取得する。
  const getUrlResponse = await fetch(
    `${SLACK_API_BASE}/files.getUploadURLExternal`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${args.token}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        filename: args.filename,
        length: String(Buffer.byteLength(args.content, "utf8")),
      }),
    }
  );
  const getUrlResult = (await getUrlResponse.json()) as SlackUploadURLResponse;
  if (!getUrlResult.ok || !getUrlResult.upload_url || !getUrlResult.file_id) {
    throw new Error(
      `Slack files.getUploadURLExternal error: ${getUrlResult.error ?? "unknown"}`
    );
  }

  // 2. 取得した URL へファイル本体を POST する。
  const uploadResponse = await fetch(getUrlResult.upload_url, {
    method: "POST",
    headers: { "Content-Type": "application/octet-stream" },
    body: args.content,
  });
  if (!uploadResponse.ok) {
    throw new Error(`Slack file upload failed: ${uploadResponse.status}`);
  }

  // 3. アップロードを完了し、指定スレッドへ共有する。
  const completeResponse = await fetch(
    `${SLACK_API_BASE}/files.completeUploadExternal`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${args.token}`,
        "Content-Type": "application/json; charset=utf-8",
      },
      body: JSON.stringify({
        files: [{ id: getUrlResult.file_id, title: args.filename }],
        channel_id: args.channel,
        thread_ts: args.threadTs,
      }),
    }
  );
  const completeResult = (await completeResponse.json()) as {
    ok: boolean;
    error?: string;
  };
  if (!completeResult.ok) {
    throw new Error(
      `Slack files.completeUploadExternal error: ${completeResult.error ?? "unknown"}`
    );
  }
}
