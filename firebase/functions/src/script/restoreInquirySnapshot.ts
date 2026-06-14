/* eslint-disable no-console */
import fs from "fs";
import admin from "firebase-admin";
import { inquiryCollectionPath } from "../entity/inquiry";
import { SnapshotEntry, restoreSnapshot } from "../entity/snapshot";

/**
 * お問い合わせドキュメントに保存されたスナップショットを Firestore へ復元するスクリプト。
 *
 * 使い方:
 *   GOOGLE_APPLICATION_CREDENTIALS=secret/GOOGLE_APPLICATION_CREDENTIALS.json \
 *     npm run script-restore-inquiry-snapshot -- <inquiryID> [--apply]
 *
 * - 接続先プロジェクトは GOOGLE_APPLICATION_CREDENTIALS のサービスアカウントで決まる。
 * - 既定はドライラン(復元対象の一覧を表示するのみ)。--apply で実際に書き込む。
 * - 書き込みは set(merge:true) のため冪等。
 * - 本番プロジェクトへの --apply は ALLOW_PROD_RESTORE=true がない限り拒否する。
 */

/** 本番 Firebase プロジェクト ID。誤って本番へ書き戻すのを防ぐガードに使う(src/index.ts の storageBucket と同一プロジェクト)。 */
const PRODUCTION_PROJECT_ID = "shopping-list-prod-a615c";

/** 接続中の Firebase プロジェクト ID を解決する。サービスアカウント JSON の project_id を優先する。 */
function resolveProjectID(): string {
  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (credentialsPath && fs.existsSync(credentialsPath)) {
    const credentials = JSON.parse(
      fs.readFileSync(credentialsPath, "utf8")
    ) as { project_id?: string };
    if (credentials.project_id) {
      return credentials.project_id;
    }
  }
  return (
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT ?? "unknown"
  );
}

async function main(): Promise<void> {
  const inquiryID = process.argv[2];
  const apply = process.argv.includes("--apply");
  if (!inquiryID || inquiryID.startsWith("--")) {
    throw new Error(
      "Usage: npm run script-restore-inquiry-snapshot -- <inquiryID> [--apply]"
    );
  }

  const projectID = resolveProjectID();
  if (
    apply &&
    projectID === PRODUCTION_PROJECT_ID &&
    process.env.ALLOW_PROD_RESTORE !== "true"
  ) {
    throw new Error(
      `本番プロジェクト(${PRODUCTION_PROJECT_ID})への復元は ALLOW_PROD_RESTORE=true が必要です`
    );
  }

  admin.initializeApp();
  const firestore = admin.firestore();

  const inquiryDoc = await firestore
    .collection(inquiryCollectionPath)
    .doc(inquiryID)
    .get();
  if (!inquiryDoc.exists) {
    throw new Error(`inquiry ${inquiryID} が見つかりません (project=${projectID})`);
  }

  const snapshotJson = inquiryDoc.get("snapshotJson") as string | null;
  if (!snapshotJson) {
    throw new Error(
      `inquiry ${inquiryID} にスナップショットがありません (${
        inquiryDoc.get("snapshotOmittedReason") ?? "不明"
      })`
    );
  }

  const entries = JSON.parse(snapshotJson) as SnapshotEntry[];
  console.log(
    `project=${projectID} inquiry=${inquiryID} documents=${entries.length} apply=${apply}`
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

  await restoreSnapshot(firestore, entries);
  console.log(`復元完了: ${entries.length} ドキュメント`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
