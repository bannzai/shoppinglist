/* eslint-disable no-console */
import fs from "fs";
import admin from "firebase-admin";
import { inquiryCollectionPath } from "../entity/inquiry";
import { SnapshotEntry, restoreSnapshot } from "../entity/snapshot";

/**
 * お問い合わせ時点の DB スナップショットを、接続中の Firebase プロジェクトの
 * `(default)` データベースへ復元するスクリプト。
 *
 * 別プロジェクト分離(Issue #410 / ADR 0030)により、復元先は named database ではなく
 * 「どのプロジェクトの認証情報で実行するか」で決まる。dev に復元するときは dev プロジェクトの
 * サービスアカウント鍵(GOOGLE_APPLICATION_CREDENTIALS)を渡す。
 *
 * 使い方:
 *   # 問い合わせ ID から(接続中プロジェクトの inquiries を読んで同プロジェクトの (default) へ復元)
 *   GOOGLE_APPLICATION_CREDENTIALS=../.secret/GOOGLE_APPLICATION_CREDENTIALS.json \
 *     npm run script-restore-inquiry-snapshot -- <inquiryID> [--apply]
 *
 *   # Slack からダウンロードしたスナップショット JSON ファイルから、別 uid に載せ替えて復元
 *   GOOGLE_APPLICATION_CREDENTIALS=../.secret/GOOGLE_APPLICATION_CREDENTIALS.json \
 *     npm run script-restore-inquiry-snapshot -- --file ./inquiry_snapshot_xxx.json \
 *       --target-uid <devの匿名uid> [--apply]
 *
 * - 読み元: 問い合わせ ID 指定時は接続中プロジェクトの inquiries/{id}.snapshotJson。
 *   --file 指定時はそのローカル JSON ファイル(Slack 添付をダウンロードしたもの)。
 * - --target-uid: スナップショット内の元 uid を指定 uid に載せ替える。別端末(匿名サインインで
 *   別 uid になる dev 端末)で本人視点として再現する用途。未指定なら元 uid のまま復元。
 * - 書き先: 接続中プロジェクトの (default)。prod 鍵の誤用を避けるため起動時に projectId を明示ログする。
 * - 既定はドライラン(復元対象の一覧表示のみ)。--apply で実書き込み。set(merge:true) で冪等。
 */

/** コマンドライン引数を解釈する。 */
function parseArgs(argv: string[]): {
  inquiryID: string | null;
  filePath: string | null;
  apply: boolean;
  targetUid: string | null;
} {
  let inquiryID: string | null = null;
  let filePath: string | null = null;
  let apply = false;
  let targetUid: string | null = null;
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--apply") {
      apply = true;
    } else if (arg === "--file") {
      filePath = argv[++i] ?? null;
    } else if (arg === "--target-uid") {
      targetUid = argv[++i] ?? null;
    } else if (!arg.startsWith("--") && inquiryID == null) {
      inquiryID = arg;
    }
  }
  return { inquiryID, filePath, apply, targetUid };
}

/** スナップショット内の元 uid を target uid に載せ替える。
 * users/{uid} エントリから元 uid を特定し、全 path とデータ(JSON)中の文字列を置換する。
 * uid は一意な長い文字列なので単純な全文字列置換で誤爆しない。
 * 別端末(匿名サインインで uid が変わる)で本人視点として再現するために使う。 */
function remapUid(entries: SnapshotEntry[], targetUid: string): SnapshotEntry[] {
  const userEntry = entries.find((entry) => /^users\/[^/]+$/.test(entry.path));
  if (!userEntry) {
    throw new Error(
      "スナップショットに users/{uid} が無く uid 載せ替えできません"
    );
  }
  const originalUid = userEntry.path.split("/")[1];
  if (originalUid === targetUid) {
    return entries;
  }
  return entries.map((entry) => ({
    path: entry.path.split(originalUid).join(targetUid),
    data: JSON.parse(
      JSON.stringify(entry.data).split(originalUid).join(targetUid)
    ) as Record<string, unknown>,
  }));
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
    const inquiryDoc = await admin
      .firestore()
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
    "Usage: npm run script-restore-inquiry-snapshot -- <inquiryID> | --file <path> [--target-uid <uid>] [--apply]"
  );
}

async function main(): Promise<void> {
  const { inquiryID, filePath, apply, targetUid } = parseArgs(
    process.argv.slice(2)
  );

  admin.initializeApp();
  // 復元先プロジェクトを明示する(prod 鍵を誤って渡した場合に気付くため)。
  const projectId =
    process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT;
  console.log(`Restore target project: ${projectId ?? "(認証情報から自動解決)"}`);

  const rawEntries = await loadEntries(inquiryID, filePath);
  const entries = targetUid ? remapUid(rawEntries, targetUid) : rawEntries;
  const source = filePath ? `file=${filePath}` : `inquiry=${inquiryID}`;
  console.log(
    `${source} target_uid=${
      targetUid ?? "(原本のまま)"
    } documents=${entries.length} apply=${apply}`
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

  await restoreSnapshot(admin.firestore(), entries);
  console.log(`復元完了: ${entries.length} ドキュメント → (default)`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
