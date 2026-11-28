import { createMaintenanceReader } from "../../lib/maintenance/maintenance-state";

/**
 * shoppinglist がメンテナンス中かどうかを読む、インスタンスで 1 つの読み手。
 * 読んだ状態を覚えるため、モジュールの読み込み時に 1 度だけ作り、Gemini を呼ぶ Functions で共有する。
 * 状態は `service-maintenance on shoppinglist` / `off shoppinglist` で切り替わる (castle の service-maintenance-setup skill)
 */
export const readMaintenanceState = createMaintenanceReader({
  stateURL: "https://service-maintenance.star-kojiki.workers.dev/shoppinglist",
});
