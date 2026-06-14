import { defineSecret } from "firebase-functions/params";

/** Slack Bot User OAuth Token(xoxb-...)。chat:write スコープが必要。
 * `firebase functions:secrets:set SLACK_BOT_TOKEN` で設定する。 */
export const slackBotToken = defineSecret("SLACK_BOT_TOKEN");

/** お問い合わせ通知の投稿先 Slack チャンネル ID(例: C0XXXXXXX)。
 * `firebase functions:secrets:set SLACK_INQUIRY_CHANNEL_ID` で設定する。 */
export const slackInquiryChannelID = defineSecret("SLACK_INQUIRY_CHANNEL_ID");

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
