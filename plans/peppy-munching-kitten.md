# RevenueCat Test Store 対応 Skill 拡張

## Context

開発中に実 App Store Connect / Google Play に商品を登録せずに IAP フローをテストしたい。RC が提供する **Test Store** 機能 (https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store) を使うと、専用 API Key で SDK を初期化するだけで mock purchase modal が出せる (実課金なし)。

これを `revenuecat-setup` / `iap-orchestrator` Skill に組み込むことで、IAP セットアップの一環として Test Store も扱えるようにする。

### API 可能性の確定事実 (要確認済み)

- **`POST /projects/{pid}/apps` の `type` enum は `app_store, mac_app_store, play_store, amazon, stripe, rc_billing, roku, paddle` の 8 種のみ。`test_store` は存在しない**
- 出典:
  - API v2 ref https://www.revenuecat.com/docs/api-v2
  - OpenAPI YAML https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml (438KB 全文検索で `test_store` 不在を確認)
  - https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store "create one on the **Apps and providers** tab"
  - https://www.revenuecat.com/blog/engineering/testing-test-store/ "go to the RevenueCat dashboard ... then you can create your Test Store"
- `rc_billing` は Web Billing (Paddle/Stripe 仲間) で Test Store とは**別物**
- → **Test Store App 自体の作成は Dashboard 手動必須**

### 未確認 (実装前に先行調査で確定させる)

- Dashboard 作成後の Test Store App が `GET /projects/{pid}/apps` のレスポンスに含まれるか、含まれる場合の `type` 値
- `POST /projects/{pid}/products` の `app_id` に Test Store App の内部 ID を渡して登録が通るか

### 今回のスコープ (ユーザー方針)

- **Skill 側のみ実装する** (revenuecat-setup / iap-orchestrator / config / docs)
- Entitlement / Offering / Package は本番 App と**共有** (RC 推奨。Flutter 側の offering 選択ロジック改変が不要)
- Flutter 側 (`lib/secret/secret.dart` / `lib/utils/purchase/purchase.dart` / `lib/utils/config/environment.dart`) の API Key 切替は**別 Issue 化**してプラン末尾に内容を記載 → 実装フェーズで `gh issue create`

---

## 変更対象ファイル一覧

| パス | 役割 | 変更種別 |
|---|---|---|
| `.claude/skills/revenuecat-setup/scripts/inspect_test_store.sh` | 先行調査 (GET /apps と GET /products の raw 出力で Test Store の API 可視性を確認) | 新規 |
| `.claude/skills/revenuecat-setup/scripts/lookup_test_store_app.sh` | Dashboard 作成済み Test Store App の ID 解決 (env fallback あり) | 新規 |
| `.claude/skills/revenuecat-setup/scripts/create_products.sh` | `--app-type test_store` を受け付けるよう引数検証を拡張 | 修正 |
| `.claude/skills/revenuecat-setup/SKILL.md` | Test Store 対応の使い方を追記 | 修正 |
| `.claude/skills/revenuecat-setup/references/manual-steps.md` | Test Store の Dashboard 作成手順 + 環境変数を追記 | 修正 |
| `.claude/skills/iap-orchestrator/scripts/config_template.json` | `revenuecat.test_store` フィールド追加 | 修正 |
| `.claude/skills/iap-orchestrator/scripts/validate.sh` | `test_store.enabled=true` 時の env 警告追加 | 修正 |
| `.claude/skills/iap-orchestrator/scripts/orchestrate.sh` | Phase 3 に Test Store 分岐 (lookup + Products 登録) を追加 | 修正 |
| `.claude/skills/iap-orchestrator/SKILL.md` | 新フィールドの説明 | 修正 |

---

## 実装順序 (Phase)

```
[Phase A] 先行調査 (Dashboard 手動 + inspect_test_store.sh)
  A-1. ユーザーが Dashboard で Test Store を 1 つ作成し、API Key と app_id を控える
  A-2. REVENUECAT_TEST_STORE_API_KEY を export
  A-3. inspect_test_store.sh を実行し、GET /apps のレスポンスに Test Store が含まれるか確認
  A-4. 含まれる場合は `type` 値を確定 → lookup_test_store_app.sh の candidate 配列に反映

[Phase B] Skill 実装
  B-1. lookup_test_store_app.sh 新規 (Phase A の結果を反映)
  B-2. create_products.sh の --app-type 検証を拡張 (test_store を許可)
  B-3. config_template.json に revenuecat.test_store 追加
  B-4. validate.sh に env 警告追加
  B-5. orchestrate.sh Phase 3 に Test Store 分岐追加
  B-6. SKILL.md / manual-steps.md 更新

[Phase C] 検証
  C-1. --dry-run で curl コマンド確認
  C-2. 実行して Products 登録成功を確認
  C-3. RC Dashboard で Test Store App に Products が追加されていることを目視確認
  C-4. 冪等性確認 (2 回実行)

[Phase D] Flutter 側は別 Issue 化
  D-1. gh issue create で Flutter 側対応の内容を issue 登録 (詳細は末尾)
```

---

## 実装コード提案

### 1. `inspect_test_store.sh` (新規)

```bash
#!/usr/bin/env bash
# Test Store App の REST API 可視性を確認する先行調査スクリプト。
# Dashboard で Test Store を作成済みであることが前提。
# Usage: bash inspect_test_store.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

printf '=== GET /projects/{pid}/apps (all apps including Test Store candidates) ===\n'
apps_response=$(rc_api_v2 GET "/projects/{project_id}/apps?limit=50")
printf '%s\n' "$apps_response" | jq '.items[] | {id, type, name}'

printf '\n=== Filter by type matching "test" (case-insensitive) ===\n'
printf '%s\n' "$apps_response" | jq '.items[] | select(.type | test("test"; "i")) | {id, type, name}'

printf '\n=== GET /projects/{pid}/products (inspect app_id linkage) ===\n'
products_response=$(rc_api_v2 GET "/projects/{project_id}/products?limit=50")
printf '%s\n' "$products_response" | jq '.items[] | {id, store_identifier, app_id, type}'

printf '\n=== Hint ===\n'
printf '- Test Store app が type=??? で返る場合、その type 値を lookup_test_store_app.sh の candidate 配列に追加\n'
printf '- 返らない場合は env 経由 (REVENUECAT_TEST_STORE_APP_ID) で ID を手動注入する fallback を使う\n'
```

### 2. `lookup_test_store_app.sh` (新規)

```bash
#!/usr/bin/env bash
# Dashboard で作成済みの Test Store App の id を取得する。
# API で発見できなければ REVENUECAT_TEST_STORE_APP_ID env fallback。
# Usage:
#   lookup_test_store_app.sh
#   lookup_test_store_app.sh --dry-run

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

# 1) Env fallback 優先 (Dashboard URL から手動取得した app_id を注入可能)
if [[ -n "${REVENUECAT_TEST_STORE_APP_ID:-}" ]]; then
  printf 'Reusing Test Store app_id from env: %s\n' "$REVENUECAT_TEST_STORE_APP_ID" >&2
  printf 'Test Store app_id: %s\n' "$REVENUECAT_TEST_STORE_APP_ID"
  exit 0
fi

# 2) API v2 で自動発見を試す
if [[ "$DRY_RUN" -eq 1 ]]; then
  rc_api_v2 GET "/projects/{project_id}/apps?limit=50" >/dev/null
  printf '[DRY RUN] Would filter apps by type matching test store\n' >&2
  exit 0
fi

apps_response=$(rc_api_v2 GET "/projects/{project_id}/apps?limit=50")

# Phase A の inspect 結果で判明した type 値を先頭に置く
# 現時点では候補を列挙 (実機確認で確定後に配列を絞る)
for candidate_type in test_store test; do
  test_store_id=$(printf '%s' "$apps_response" | jq -r --arg t "$candidate_type" \
    '.items[] | select(.type == $t) | .id' | head -1)
  if [[ -n "$test_store_id" ]]; then
    printf 'Found Test Store app (type=%s): %s\n' "$candidate_type" "$test_store_id" >&2
    printf 'Test Store app_id: %s\n' "$test_store_id"
    exit 0
  fi
done

cat >&2 <<EOF

================================================================
[Manual Step] Test Store App が REST API から発見できませんでした。

1. Dashboard で Test Store を作成:
   https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/apps
   → "Apps and providers" → "Test configuration" で新規作成
2. 発行された Test Store API Key を REVENUECAT_TEST_STORE_API_KEY に export
3. Dashboard URL に表示される appXXX 形式の ID を REVENUECAT_TEST_STORE_APP_ID に export
4. 本スクリプトを再実行

参考: https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
================================================================
EOF
exit 1
```

### 3. `create_products.sh` 修正

引数検証行のみ差し替え。store_identifier 組立ロジックは既存のまま (Play subscription 分岐以外は本番と同じ命名で OK、Offering 共有のため):

```bash
: "${APP_TYPE:?--app-type is required (app_store|play_store|mac_app_store|amazon|test_store)}"
```

その他のロジックは無変更。`rc_type` マッピング (`subscription` / `consumable` / `non_consumable`) はそのまま有効。

### 4. `config_template.json` 追記

```json
{
  ...
  "revenuecat": {
    "entitlement_lookup_key": "Premium",
    "entitlement_display_name": "プレミアム",
    "test_store": {
      "enabled": false
    },
    "offerings": [
      ...
    ]
  }
}
```

`revenuecat.test_store` 配下に置く理由: `app.*` は「ストアに登録する物理アプリの情報」のため、Dashboard にしか存在しない Test Store は意味論的にこちらが自然。app_id は env 経由で渡すため config には書かない (個人差を git に載せないため)。

### 5. `validate.sh` 追記

既存の必須フィールドチェック末尾に追加:

```bash
if jq -e '.revenuecat.test_store.enabled == true' "$CONFIG" >/dev/null; then
  if [[ -z "${REVENUECAT_TEST_STORE_API_KEY:-}" ]]; then
    printf '[warning] revenuecat.test_store.enabled=true but REVENUECAT_TEST_STORE_API_KEY is not set.\n' >&2
  fi
fi
```

### 6. `orchestrate.sh` Phase 3 追記

env チェック箇所の直後 (既存の SKIP_RC 判定付近):

```bash
TEST_STORE_ENABLED=0
if [[ "$SKIP_RC" -ne 1 ]] && jq -e '.revenuecat.test_store.enabled == true' "$CONFIG" >/dev/null; then
  TEST_STORE_ENABLED=1
fi
```

Android App 作成ブロック (L234-244) の直後に追加:

```bash
  RC_TEST_STORE_APP_ID=""
  if [[ "$TEST_STORE_ENABLED" -eq 1 ]]; then
    printf '\n# RC App: test_store (Dashboard 作成済みを lookup)\n'
    test_store_out=$(bash "${RC_SETUP_SKILL}/lookup_test_store_app.sh" $DRY_RUN_FLAG 2>&1 || true)
    printf '%s\n' "$test_store_out"
    if [[ -n "$DRY_RUN_FLAG" ]]; then
      RC_TEST_STORE_APP_ID="DRY_RUN_TEST_STORE_APP_ID"
    else
      RC_TEST_STORE_APP_ID=$(printf '%s' "$test_store_out" | awk '/Test Store app_id:/ {print $NF; exit}')
      if [[ -z "$RC_TEST_STORE_APP_ID" ]]; then
        printf 'Test Store app_id lookup failed. Dashboard 作成 + REVENUECAT_TEST_STORE_APP_ID env を確認してください。\n' >&2
        TEST_STORE_ENABLED=0
      fi
    fi
    printf 'RC Test Store app_id: %s\n' "$RC_TEST_STORE_APP_ID"
  fi
```

Android Products 登録ブロック (L256-263) の直後に追加:

```bash
  if [[ "$TEST_STORE_ENABLED" -eq 1 && -n "$RC_TEST_STORE_APP_ID" ]]; then
    printf '\n# RC Products (Test Store): %s\n' "$product_ids"
    bash "${RC_SETUP_SKILL}/create_products.sh" \
      --app-id "$RC_TEST_STORE_APP_ID" \
      --app-type test_store \
      --product-ids "$product_ids" \
      $DRY_RUN_FLAG || true
  fi
```

**Entitlement / Offering / Package は改変不要**: `create_entitlement.sh` の `resolve_rc_product_ids_by_sid` が store_identifier 一致で全 App (iOS / Android / Test Store) の prodXXX を拾う。Offering / Package も store 非依存ループで Test Store Product が attach される。

### 7. `manual-steps.md` 追記

既存の末尾に節を追加:

```markdown
## 8. Test Store の作成と API Key 発行 (開発時のみ)

**いつ**: 実 ASC/Play に商品登録せずに IAP フローをテストしたいとき。

**なぜ手動**: REST API v2 の `POST /projects/{pid}/apps` の `type` enum に `test_store` が含まれないため、Dashboard 作成が必須。
(確認済み: https://www.revenuecat.com/docs/api-v2 および https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml で `test_store` 不在を確定)

**手順**:
1. https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/apps にアクセス
2. "Apps and providers" → "Test configuration" セクションから新規作成
3. 発行される Test Store Public API Key を `REVENUECAT_TEST_STORE_API_KEY` として export
4. Dashboard URL から Test Store App の内部 ID (appXXX) を控え、`REVENUECAT_TEST_STORE_APP_ID` として export (inspect で自動発見できる場合は不要)
5. config の `revenuecat.test_store.enabled` を `true` にして orchestrate.sh --phase 3 を実行
6. Products は自動登録される (Entitlement / Offering / Package は本番 App と共有)

**参考**: https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
```

---

## 別 Issue 化する内容 (Flutter 側対応)

Skill では扱わず、実装フェーズで以下の内容で `gh issue create` する。

```markdown
# Title
feat(purchase): RevenueCat Test Store 用 API Key 切替対応

## 背景
Skill (revenuecat-setup / iap-orchestrator) 側で Test Store Products 自動登録が実装された
(plans/peppy-munching-kitten.md 参照)。これを Flutter アプリから実際に使うには
`Purchases.configure()` に渡す API Key を開発時のみ Test Store 用に切り替える必要がある。

## 実装内容

### 1. `lib/utils/config/environment.dart`
`useRCTestStore` getter を追加:
- `--dart-define=USE_RC_TEST_STORE=true` で true
- `isProduction` の場合は常に false (Release build で誤って Test Store Key を使わないガード)

### 2. `lib/secret/secret.dart`
`revenueCatTestStorePublicAPIKey` 定数を追加 (`String.fromEnvironment('REVENUECAT_TEST_STORE_API_KEY')`)。
ハードコードはせず、`--dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx` で注入する。

### 3. `lib/utils/purchase/purchase.dart`
`initializePurchase()` で `Environment.useRCTestStore` 判定して Key を切り替え。
Debug 時に Test Store Key が空のままだと `assert` で早期検知。

## 検証
- `flutter run --dart-define=USE_RC_TEST_STORE=true --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx`
  で起動し、購入ボタンで mock purchase modal が出ることを確認
- `flutter build ipa --release --dart-define=USE_RC_TEST_STORE=true` でビルドしたアプリが
  本番キーで起動 (ガードが効いている) ことを確認

## 前提
- purchases_flutter 9.8.0 以上が必要 (本リポジトリは ^9.11.0 で OK)
- RC Dashboard で Test Store を作成済み + API Key 発行済み

## 参考
- RevenueCat Test Store docs: https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
- 親プラン: plans/peppy-munching-kitten.md
```

---

## 検証手順

### 事前準備
1. ユーザーが RC Dashboard で Test Store を作成 (https://app.revenuecat.com/projects/a9466f75/apps)
2. `export REVENUECAT_TEST_STORE_API_KEY=...`
3. (任意) `export REVENUECAT_TEST_STORE_APP_ID=appXXX`

### A. 先行調査
```bash
bash .claude/skills/revenuecat-setup/scripts/inspect_test_store.sh
```

**判定**: GET /apps のレスポンスに Test Store app が含まれるか、含まれる場合の `type` 値を確認して `lookup_test_store_app.sh` の candidate 配列に反映。

### B. dry-run
```bash
bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --phase 3 --dry-run
```
(tmp/iap-config.json の `revenuecat.test_store.enabled` を true にしておく)

**判定**: `[DRY RUN] curl -sS -X POST ... /projects/.../products ... app_id=<test_store_id>` が 3 件分出力される。

### C. 本番実行
```bash
bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --phase 3
```

**判定ログ**:
- `RC Test Store app_id: appXXX`
- `Creating product: shoppinglist_500yen_1month (store_identifier=shoppinglist_500yen_1month type=subscription)` → `→ created: id=prodXXX` (3 件)
- `Attaching N RC product IDs to entitlement Premium` の N が iOS + Android + TestStore の合計と一致

### D. RC Dashboard 目視
- https://app.revenuecat.com/projects/a9466f75/apps で Test Store App の Products に 3 件登録
- Entitlement `Premium` の Attached Products に Test Store 用 prodXXX が含まれる

### E. 冪等性
同コマンドを 2 回連続実行して 2 回目も失敗なしで完走。

---

## 既知の不確実性

| # | 内容 | 対処 |
|---|---|---|
| U-1 | Dashboard 作成済み Test Store App の REST API v2 `type` 値 | Phase A の `inspect_test_store.sh` で実機確認。判明次第 `lookup_test_store_app.sh` の candidate 配列を更新 |
| U-2 | GET /apps に Test Store が含まれない可能性 | env fallback (`REVENUECAT_TEST_STORE_APP_ID`) で手動 ID 注入 |
| U-3 | POST /products の `app_id` に Test Store ID を渡して 400 が返る可能性 | dry-run で先に curl 内容確認。400 の場合は `manual-steps.md` に Dashboard UI 登録手順の fallback を追記 |
| U-4 | Offering 共有時に SDK が API Key に応じて適切な product を自動選択してくれるか | Flutter 側 issue 対応後に実機確認。共有案で破綻する場合は Test Store 専用 Offering 案に切替 (別途プラン) |

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### 共通
- [ ] Phase A の `inspect_test_store.sh` を実行して REST API 可視性を確定させてから `lookup_test_store_app.sh` の candidate 配列を最終決定する
- [ ] Phase 3 の再実行で既存リソースが再利用され冪等性が保たれる
- [ ] `manual-steps.md` に Test Store の Dashboard 作成手順が追記されている
- [ ] エラーメッセージはそのまま表示 (加工しない)
- [ ] Flutter 側対応は別 Issue として `gh issue create` で登録 (本プラン末尾のテンプレを使用)
- [ ] 実行後に RC Dashboard の Test Store App の Products セクションに 3 件追加されていることを目視確認
