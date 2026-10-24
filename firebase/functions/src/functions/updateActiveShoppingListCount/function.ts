import { logger } from "firebase-functions";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import {
  ShoppingListData,
  isActiveShoppingListData,
  recountActiveShoppingLists,
} from "./activeShoppingListCount";

/**
 * 買い物リストの作成・status 変更・削除に合わせて、グループの activeShoppingListCount を数え直す。
 *
 * 無料プランの買い物リスト数の上限を firestore.rules で判定するための値 (Issue #683)。
 * rules では active なリストを数えられず、オフライン作成を残すためリストの作成はクライアントの
 * 直接書き込みのままにするので、Function の側で書き込みに追随して数を保つ。
 * `.claude/rules/firebase-functions.md` は Firestore トリガーを原則禁止しているが、
 * Issue #683 でオーナーがこの方式 (案 B) を選んだため例外として使う。
 * active かどうかが変わらない書き込み (名前の変更等) では数え直さない。
 * 数え直しが一時的に失敗すると次の active の変化まで数がずれたまま作成を拒否し得るため、
 * 冪等な数え直しであることを前提に retry を有効にする。
 */
module.exports = onDocumentWritten(
  {
    document: "groups/{groupID}/shoppingLists/{shoppingListID}",
    retry: true,
  },
  async (event) => {
    const beforeIsActive = isActiveShoppingListData(
      event.data?.before.data() as ShoppingListData | undefined
    );
    const afterIsActive = isActiveShoppingListData(
      event.data?.after.data() as ShoppingListData | undefined
    );
    if (beforeIsActive === afterIsActive) {
      return;
    }
    await recountActiveShoppingLists(event.params.groupID);
    logger.info(
      `Recounted active shopping lists of group ${event.params.groupID}`
    );
  }
);
