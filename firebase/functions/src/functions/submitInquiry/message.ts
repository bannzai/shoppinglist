import { Inquiry, inquiryCategoryLabels } from "../../entity/inquiry";
import { escapeSlackText } from "../utils/slack";

/** Slack の section text(mrkdwn)1要素あたりの文字数上限。これを超えると Slack が拒否する。 */
const MRKDWN_TEXT_LIMIT = 2900;

/** ユーザー入力をエスケープし、上限を超える場合は省略表示用に切り詰める。
 * エスケープで文字数が増えるため、エスケープ後に切り詰める。
 * 切った位置が実体参照(`&amp;` 等)の途中だと Slack 上で `&am` のような断片が残るため、末尾の断片を除く。 */
function escapeAndTruncate(text: string): string {
  const escaped = escapeSlackText(text);
  if (escaped.length <= MRKDWN_TEXT_LIMIT) {
    return escaped;
  }
  return `${escaped.slice(0, MRKDWN_TEXT_LIMIT).replace(/&[a-z]*$/, "")}…(省略)`;
}

/** Slack 通知のフォールバック(通知本文)テキストを生成する。 */
export function buildInquirySlackText(inquiry: Inquiry): string {
  return `お問い合わせ[${inquiryCategoryLabels[inquiry.categoryType]}] ${escapeAndTruncate(
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
        {
          type: "mrkdwn",
          text: `*アプリバージョン*\n${escapeSlackText(inquiry.appVersion)}`,
        },
        { type: "mrkdwn", text: `*スナップショット*\n${snapshotStatus}` },
      ],
    },
    { type: "divider" },
    {
      type: "section",
      text: {
        type: "mrkdwn",
        text: `*お問い合わせ内容*\n${escapeAndTruncate(inquiry.content)}`,
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
