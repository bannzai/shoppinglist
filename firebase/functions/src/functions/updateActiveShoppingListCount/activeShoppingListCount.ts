import admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

/** 買い物リストのうち active として数えない status。firestore.rules の isActiveShoppingListData と一致させる。 */
const INACTIVE_SHOPPING_LIST_STATUSES = ["done", "archived"];

/** 買い物リストの文書のうち active 判定に使う部分。 */
export interface ShoppingListData {
  status?: string;
}

/**
 * 買い物リストの文書が active として数えられるかを返す。文書が無い (作成前・削除後) 時は false。
 * status が欠落した文書はクライアントの既定値 (active) に合わせて active とする。
 */
export function isActiveShoppingListData(
  shoppingListData: ShoppingListData | undefined
): boolean {
  return (
    shoppingListData != null &&
    !INACTIVE_SHOPPING_LIST_STATUSES.includes(
      shoppingListData.status ?? "active"
    )
  );
}

/**
 * `groups/{groupID}` の activeShoppingListCount を、配下の active な買い物リストの実数に揃える。
 * 増減ではなく数え直しで書くため冪等。グループが存在しない (削除済み) 場合は何もしない。
 * グループ文書の読み取りを同じトランザクションに含め、並行する数え直しが古い数で上書きしないようにする。
 */
export async function recountActiveShoppingLists(
  groupID: string
): Promise<void> {
  const firestore = admin.firestore();
  const groupRef = firestore.collection("groups").doc(groupID);
  const shoppingListsRef = groupRef.collection("shoppingLists");
  await firestore.runTransaction(async (transaction) => {
    const groupSnapshot = await transaction.get(groupRef);
    if (!groupSnapshot.exists) {
      return;
    }
    const allShoppingListCount = (
      await transaction.get(shoppingListsRef.count())
    ).data().count;
    const inactiveShoppingListCount = (
      await transaction.get(
        shoppingListsRef
          .where("status", "in", INACTIVE_SHOPPING_LIST_STATUSES)
          .count()
      )
    ).data().count;
    transaction.update(groupRef, {
      activeShoppingListCount: allShoppingListCount - inactiveShoppingListCount,
      serverUpdatedDateTime: FieldValue.serverTimestamp(),
    });
  });
}
