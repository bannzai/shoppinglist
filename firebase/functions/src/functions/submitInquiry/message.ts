import { Inquiry, inquiryCategoryLabels } from "../../entity/inquiry";

/** Slack の section text(mrkdwn)1要素あたりの文字数上限。これを超えると Slack が拒否する。 */
const MRKDWN_TEXT_LIMIT = 2900;

/** 上限を超えるテキストを省略表示用に切り詰める。 */
function truncate(text: string): string {
  if (text.length <= MRKDWN_TEXT_LIMIT) {
    return text;
  }
  return `${text.slice(0, MRKDWN_TEXT_LIMIT)}…(省略)`;
}

/** Slack 通知のフォールバック(通知本文)テキストを生成する。 */
export function buildInquirySlackText(inquiry: Inquiry): string {
  return `お問い合わせ[${inquiryCategoryLabels[inquiry.categoryType]}] ${truncate(
    inquiry.content
  )}`;
}

/** Slack 通知の Block Kit blocks を生成する。
 * 末尾に復元コマンド例を載せ、問い合わせ ID から DB スナップショットを復元できるようにする。 */
export function buildInquirySlackBlocks(inquiry: Inquiry): unknown[] {
  const snapshotStatus = inquiry.snapshotJson
    ? "保存済み (復元可能)"
    : `なし (${inquiry.snapshotOmittedReason ?? "unknown"})`;
  return [
    {
      type: "header",
      text: {
        type: "plain_text",
        text: `📩 お問い合わせ: ${inquiryCategoryLabels[inquiry.categoryType]}`,
        emoji: true,
      },
    },
    {
      type: "section",
      fields: [
        { type: "mrkdwn", text: `*問い合わせID*\n${inquiry.id}` },
        { type: "mrkdwn", text: `*ユーザーID*\n${inquiry.userID}` },
        { type: "mrkdwn", text: `*メール*\n${inquiry.email}` },
        { type: "mrkdwn", text: `*プラットフォーム*\n${inquiry.platform}` },
        { type: "mrkdwn", text: `*アプリバージョン*\n${inquiry.appVersion}` },
        { type: "mrkdwn", text: `*スナップショット*\n${snapshotStatus}` },
      ],
    },
    { type: "divider" },
    {
      type: "section",
      text: {
        type: "mrkdwn",
        text: `*お問い合わせ内容*\n${truncate(inquiry.content)}`,
      },
    },
    {
      type: "context",
      elements: [
        {
          type: "mrkdwn",
          text: `DB復元: \`GOOGLE_APPLICATION_CREDENTIALS=../.secret/GOOGLE_APPLICATION_CREDENTIALS.json npm run script-restore-inquiry-snapshot -- ${inquiry.id} --apply\``,
        },
      ],
    },
  ];
}
