/* eslint-disable no-console */
import fs from "fs";
import admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import { inquiryCollectionPath } from "../entity/inquiry";
import { SnapshotEntry, restoreSnapshot } from "../entity/snapshot";

/**
 * お問い合わせ時点の DB スナップショットを named database `development` へ復元するスクリプト。
 *
 * 使い方:
 *   # 問い合わせ ID から(本番 (default) の inquiries を読んで development へ復元)
 *   GOOGLE_APPLICATION_CREDENTIALS=secret/GOOGLE_APPLICATION_CREDENTIALS.json \
 *     npm run script-restore-inquiry-snapshot -- <inquiryID> [--apply]
 *
 *   # Slack からダウンロードしたスナップショット JSON ファイルから復元
 *   GOOGLE_APPLICATION_CREDENTIALS=secret/GOOGLE_APPLICATION_CREDENTIALS.json \
 *     npm run script-restore-inquiry-snapshot -- --file ./inquiry_snapshot_xxx.json [--apply]
 *
 * - 読み元: 問い合わせ ID 指定時は (default) データベースの inquiries/{id}.snapshotJson。
 *   --file 指定時はそのローカル JSON ファイル(Slack 添付をダウンロードしたもの)。
 * - 書き先: 既定で named database `development`(prod の (default) は汚さない)。--db で上書き可。
 * - 既定はドライラン(復元対象の一覧表示のみ)。--apply で実書き込み。set(merge:true) で冪等。
 * - 書き先が (default) の場合のみ ALLOW_PROD_RESTORE=true を要求する(本番誤爆防止)。
 */

/** 復元先の既定 named database。 */
const DEFAULT_TARGET_DATABASE = "development";

/** 本番データを保持する (default) データベースの ID。 */
const PRODUCTION_DATABASE_ID = "(default)";

/** 指定 ID の Firestore インスタンスを返す。(default) はモジュール API に ID を渡さない。 */
function firestoreFor(databaseId: string): admin.firestore.Firestore {
  return databaseId === PRODUCTION_DATABASE_ID
    ? getFirestore(admin.app())
    : getFirestore(admin.app(), databaseId);
}

/** コマンドライン引数を解釈する。 */
function parseArgs(argv: string[]): {
  inquiryID: string | null;
  filePath: string | null;
  apply: boolean;
  targetDatabase: string;
} {
  let inquiryID: string | null = null;
  let filePath: string | null = null;
  let apply = false;
  let targetDatabase = DEFAULT_TARGET_DATABASE;
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--apply") {
      apply = true;
    } else if (arg === "--file") {
      filePath = argv[++i] ?? null;
    } else if (arg === "--db") {
      targetDatabase = argv[++i] ?? DEFAULT_TARGET_DATABASE;
    } else if (!arg.startsWith("--") && inquiryID == null) {
      inquiryID = arg;
    }
  }
  return { inquiryID, filePath, apply, targetDatabase };
}

/** 問い合わせ ID または JSON ファイルからスナップショット entries を取得する。 */
async function loadEntries(
  inquiryID: string | null,
  filePath: string | null
): Promise<SnapshotEntry[]> {
  if (filePath) {
    return JSON.parse(fs.readFileSync(filePath, "utf8")) as SnapshotEntry[];
  }
  if (inquiryID) {
    const inquiryDoc = await firestoreFor(PRODUCTION_DATABASE_ID)
      .collection(inquiryCollectionPath)
      .doc(inquiryID)
      .get();
    if (!inquiryDoc.exists) {
      throw new Error(`inquiry ${inquiryID} が (default) に見つかりません`);
    }
    const snapshotJson = inquiryDoc.get("snapshotJson") as string | null;
    if (!snapshotJson) {
      throw new Error(
        `inquiry ${inquiryID} にスナップショットがありません (${
          inquiryDoc.get("snapshotOmittedReason") ?? "不明"
        })`
      );
    }
    return JSON.parse(snapshotJson) as SnapshotEntry[];
  }
  throw new Error(
    "Usage: npm run script-restore-inquiry-snapshot -- <inquiryID> | --file <path> [--db <name>] [--apply]"
  );
}

async function main(): Promise<void> {
  const { inquiryID, filePath, apply, targetDatabase } = parseArgs(
    process.argv.slice(2)
  );

  if (
    apply &&
    targetDatabase === PRODUCTION_DATABASE_ID &&
    process.env.ALLOW_PROD_RESTORE !== "true"
  ) {
    throw new Error(
      "(default) への復元は ALLOW_PROD_RESTORE=true が必要です"
    );
  }

  admin.initializeApp();

  const entries = await loadEntries(inquiryID, filePath);
  const source = filePath ? `file=${filePath}` : `inquiry=${inquiryID}`;
  console.log(
    `${source} target_database=${targetDatabase} documents=${entries.length} apply=${apply}`
  );
  for (const entry of entries) {
    console.log(`  ${entry.path}`);
  }

  if (!apply) {
    console.log(
      "ドライラン: 書き込みは行いません。--apply を付けて再実行してください。"
    );
    return;
  }

  await restoreSnapshot(firestoreFor(targetDatabase), entries);
  console.log(`復元完了: ${entries.length} ドキュメント → ${targetDatabase}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
