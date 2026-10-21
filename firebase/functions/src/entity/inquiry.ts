import * as z from "zod";

/** お問い合わせの種類。
 * クライアント(lib/entity/inquiry_category.dart の wireValue)と同じ値を維持すること。 */
export const InquiryCategorySchema = z.enum([
  "bugReport",
  "howToUse",
  "request",
  "other",
]);

export type InquiryCategory = z.infer<typeof InquiryCategorySchema>;

/** お問い合わせ種類ごとの Slack 表示用日本語ラベル。 */
export const inquiryCategoryLabels: Record<InquiryCategory, string> = {
  bugReport: "不具合報告",
  howToUse: "操作方法について",
  request: "ご要望・改善要望",
  other: "その他",
};

/** お問い合わせの送信元プラットフォーム。 */
export const InquiryPlatformSchema = z.enum(["ios", "android"]);

export type InquiryPlatform = z.infer<typeof InquiryPlatformSchema>;

/** クライアントが送るアプリバージョン(lib/features/inquiry/page.dart の `'${version} (${buildNumber})'`)。
 * Slack 通知にそのまま載るため、長さと文字種をバージョン表記に必要な範囲に絞る。
 * 32 文字は "1.0.1 (1)" 形式に、プレリリース表記(例: "10.20.30-beta.12 (12345)")を足しても収まる長さとして選んだ。 */
export const InquiryAppVersionSchema = z
  .string()
  .min(1)
  .max(32)
  .regex(/^[0-9A-Za-z.+\-_ ()]+$/);

/** inquiries コレクションのドキュメント。
 * クライアントからの直接 read/write は禁止し(firestore.rules 参照)、
 * submitInquiry Function(Admin SDK)経由でのみ作成する。 */
export interface Inquiry {
  /** Firestore ドキュメント ID。 */
  id: string;
  /** 送信したユーザーの Firebase Auth UID。 */
  userID: string;
  /** 返信先メールアドレス。 */
  email: string;
  /** お問い合わせの種類。 */
  categoryType: InquiryCategory;
  /** お問い合わせ本文。 */
  content: string;
  /** 送信元プラットフォーム。 */
  platform: InquiryPlatform;
  /** クライアントのアプリバージョン(例: "1.2.3 (45)")。 */
  appVersion: string;
  /** 送信時点のユーザー関連データのスナップショット(JSON 文字列)。
   * 復元コマンド(script/restoreInquirySnapshot.ts)で書き戻して不具合を再現する。
   * ドキュメント上限(約1MiB)を超える場合は null になり snapshotOmittedReason に理由が入る。 */
  snapshotJson: string | null;
  /** snapshotJson が null の場合の理由。正常時は null。 */
  snapshotOmittedReason: string | null;
  /** Slack 通知に成功したか。 */
  slackNotified: boolean;
}

/** inquiries コレクションのパス。 */
export const inquiryCollectionPath = "inquiries";
