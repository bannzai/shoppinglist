import admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";

/** Firestore ドキュメント1件分のスナップショット。 */
export interface SnapshotEntry {
  /** 復元先の Firestore 完全パス(例: "groups/abc/shoppingLists/def")。 */
  path: string;
  /** ドキュメントのフィールド値。Timestamp は serializeFirestoreValue でマーカー化済み。 */
  data: Record<string, unknown>;
}

/** Timestamp を JSON 化可能なマーカーに変換する際のキー。 */
const TIMESTAMP_MARKER = "__timestamp__";

/** Firestore の値を JSON 直列化可能な形へ再帰変換する。Timestamp はマーカーへ変換する。 */
export function serializeFirestoreValue(value: unknown): unknown {
  if (value instanceof Timestamp) {
    return {
      [TIMESTAMP_MARKER]: {
        seconds: value.seconds,
        nanoseconds: value.nanoseconds,
      },
    };
  }
  if (Array.isArray(value)) {
    return value.map(serializeFirestoreValue);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, child]) => [
        key,
        serializeFirestoreValue(child),
      ])
    );
  }
  return value;
}

/** serializeFirestoreValue の逆変換。マーカーを admin Timestamp へ戻す。 */
export function deserializeFirestoreValue(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(deserializeFirestoreValue);
  }
  if (value && typeof value === "object") {
    const marker = (value as Record<string, unknown>)[TIMESTAMP_MARKER];
    if (marker && typeof marker === "object") {
      const { seconds, nanoseconds } = marker as {
        seconds: number;
        nanoseconds: number;
      };
      return new Timestamp(seconds, nanoseconds);
    }
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, child]) => [
        key,
        deserializeFirestoreValue(child),
      ])
    );
  }
  return value;
}

/** 指定ユーザーに紐づく Firestore ドキュメントを収集する。
 * 収集対象: users/{uid} とそのサブコレクション、ユーザーがメンバーの groups と全サブコレクション。
 * 不具合再現に必要な範囲を網羅しつつ、他ユーザー固有のデータは含めない。 */
export async function collectUserSnapshot(
  firestore: admin.firestore.Firestore,
  userID: string
): Promise<SnapshotEntry[]> {
  const entries: SnapshotEntry[] = [];

  const pushDoc = (doc: admin.firestore.DocumentSnapshot) => {
    if (doc.exists) {
      entries.push({
        path: doc.ref.path,
        data: serializeFirestoreValue(doc.data()) as Record<string, unknown>,
      });
    }
  };

  // users/{uid} とサブコレクション(privates, aiUsage)。
  const userRef = firestore.collection("users").doc(userID);
  pushDoc(await userRef.get());
  for (const subcollection of ["privates", "aiUsage"]) {
    (await userRef.collection(subcollection).get()).forEach(pushDoc);
  }

  // ユーザーがメンバーの groups と全サブコレクション。
  const groups = await firestore
    .collection("groups")
    .where("memberUserIDs", "array-contains", userID)
    .get();
  for (const groupDoc of groups.docs) {
    pushDoc(groupDoc);
    for (const subcollection of ["userProfiles", "shoppingLocations"]) {
      (await groupDoc.ref.collection(subcollection).get()).forEach(pushDoc);
    }
    // userCategoryAxes/{axis}/categories/{category}
    const axes = await groupDoc.ref.collection("userCategoryAxes").get();
    for (const axisDoc of axes.docs) {
      pushDoc(axisDoc);
      (await axisDoc.ref.collection("categories").get()).forEach(pushDoc);
    }
    // shoppingLists/{list}/items/{item}
    const lists = await groupDoc.ref.collection("shoppingLists").get();
    for (const listDoc of lists.docs) {
      pushDoc(listDoc);
      (await listDoc.ref.collection("items").get()).forEach(pushDoc);
    }
  }

  return entries;
}

/** スナップショットを Firestore へ書き戻す。set(merge:true) のため冪等。 */
export async function restoreSnapshot(
  firestore: admin.firestore.Firestore,
  entries: SnapshotEntry[]
): Promise<void> {
  for (const entry of entries) {
    await firestore
      .doc(entry.path)
      .set(
        deserializeFirestoreValue(entry.data) as admin.firestore.DocumentData,
        { merge: true }
      );
  }
}
