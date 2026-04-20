# RevenueCat Setup Skill — Phase 3 残4バグ修正

## Context

IAP 3ストア (ASC / Play / RC) 横断セットアップの Skill 群で、RC Phase 3 の最終段で 4 件のバグが残り実行が止まっている。詳細な経緯は `tmp/handover-iap-phase3-continue.md` に記載。本プランでは該当 4 件を修正して Phase 3 を完走させる。

### 現在の状態
- Project `a9466f75` に iOS App (`appde3e336d9a`) / Android App (`app5c10588d85`) 作成済
- iOS Products 3件 (prodb3bd027267 / prod8ac1d0c96d / prodd73b8dc479) 作成済
- Entitlement `Premium` (`entlc13ddeef52`) 作成済 (attach は未完)
- Offering `default` (`ofrngfa5c5fdbb0`) 作成済
- Packages 3件 (pkge85635f422d / pkgec04da6d95f / pkge8e130afdfc) 作成済 (attach は未完)
- Android Products / 各 attach / set current は失敗中

### 残バグ
1. **create_products.sh**: Play Store subscription の `store_identifier` が `<sid>:<basePlanId>` 形式必須 (2023/02 以降の RC 規約) だが product_id をそのまま送っている
2. **create_entitlement.sh**: attach API (`actions/attach_products`) の `product_ids` は RC 内部 ID (`prodXXX`) が必要だが、store_identifier を送っている → 404
3. **create_package.sh**: attach body が `{product_relations: [...]}` だが RC v2 は `{products: [...]}` を要求 (エラー `'products' is a required property`)
4. **set_current_offering.sh**: `/actions/set_current` エンドポイントは RC v2 に存在しない (公式は Dashboard 手動前提) → 404

### ユーザー方針 (`tmp/handover-iap-phase3-continue.md` より)
- Auto モードで進める (細かい確認なし)
- **嘘を書かない**。不確実な点は実装時に API 応答で判断
- **既存リソースはそのまま再利用** (409 → GET で既存 ID 取得、冪等性担保)

### 設計方針
- 手動 fallback は set_current_offering のみ (v2 に API が存在しないため)。残 3 バグはスクリプト内完結
- RC v2 公式仕様: https://www.revenuecat.com/docs/getting-started/entitlements/android-products (`<subscription_id>:<base_plan_id>` 規約) / https://www.revenuecat.com/docs/api-v2#tag/Entitlements (attach は内部 ID 使用)

---

## 変更対象ファイル一覧

| ファイル | 変更概要 |
|---|---|
| `.claude/skills/revenuecat-setup/scripts/_common.sh` | `resolve_rc_product_ids_by_sid` 共通関数を追加 |
| `.claude/skills/revenuecat-setup/scripts/create_products.sh` | `--app-type` 引数追加 + Play subscription の `{sid}:{basePlanId}` 形式対応 |
| `.claude/skills/revenuecat-setup/scripts/create_entitlement.sh` | store_identifier → prodXXX 解決を追加 + 409 冪等化 |
| `.claude/skills/revenuecat-setup/scripts/create_package.sh` | attach body を `{products: [...]}` に修正 + 既存 lookup を共通関数に置換 + 409 冪等化 |
| `.claude/skills/revenuecat-setup/scripts/set_current_offering.sh` | v2 API 非対応のため Dashboard URL 出力のみに変更 |
| `.claude/skills/iap-orchestrator/scripts/orchestrate.sh` | Phase 3 の `create_products.sh` 呼び出しに `--app-type` 追加 |

---

## 実装コード提案

### 1. `_common.sh` — 共通関数追加

L109 の `require_jq` 関数の後ろに追加:

```bash
# store_identifier から RC 内部 Product ID (prodXXX) を解決する
# iOS/Android 両ストアに同 logical product があれば両方の ID を改行区切りで返す
# Play subscription の `{sid}:{basePlanId}` 形式には prefix 一致でもマッチさせる
resolve_rc_product_ids_by_sid() {
  local sid="$1"
  local products_response
  products_response=$(rc_api_v2 GET "/projects/{project_id}/products?limit=50")
  printf '%s' "$products_response" | jq -r --arg sid "$sid" \
    '.items[] | select(.store_identifier == $sid or (.store_identifier | startswith($sid + ":"))) | .id'
}

resolve_rc_product_id_by_sid() {
  resolve_rc_product_ids_by_sid "$1" | head -1
}
```

### 2. `create_products.sh` — Play subscription 形式対応

**L14-26 の引数パース**:

```bash
APP_ID=""
APP_TYPE=""
PRODUCT_IDS=""
DISPLAY_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-id) APP_ID="$2"; shift 2 ;;
    --app-type) APP_TYPE="$2"; shift 2 ;;
    --product-ids) PRODUCT_IDS="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${APP_ID:?--app-id is required}"
: "${APP_TYPE:?--app-type is required (app_store|play_store|mac_app_store|amazon)}"
: "${PRODUCT_IDS:?--product-ids is required (comma-separated)}"
```

**L54-64 の body 組み立て**:

```bash
  display_name="${DISPLAY_NAME:-$product_id}"

  # Play Store subscription のみ {sid}:{basePlanId} 形式
  # https://www.revenuecat.com/docs/getting-started/entitlements/android-products
  store_identifier="$product_id"
  if [[ "$APP_TYPE" == "play_store" && "$rc_type" == "subscription" ]]; then
    store_identifier="${product_id}:${product_type}"
  fi

  body=$(jq -n \
    --arg sid "$store_identifier" \
    --arg type "$rc_type" \
    --arg aid "$APP_ID" \
    --arg dn "$display_name" \
    '{store_identifier: $sid, type: $type, app_id: $aid, display_name: $dn}')

  printf 'Creating product: %s (store_identifier=%s type=%s)\n' "$product_id" "$store_identifier" "$rc_type"
  response=$(rc_api_v2 POST "/projects/{project_id}/products" "$body")
```

### 3. `create_entitlement.sh` — 409 冪等化 + store_identifier 解決

**L34-48 の作成ブロック**:

```bash
response=$(rc_api_v2 POST "/projects/{project_id}/entitlements" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  if [[ -n "$ATTACH_PRODUCTS" ]]; then
    printf '\n[DRY RUN] Would attach products: %s\n' "$ATTACH_PRODUCTS" >&2
  fi
  exit 0
fi

entitlement_id=$(printf '%s' "$response" | jq -r '.id // empty')

# 409 (resource_already_exists) なら既存 ID を GET で取得して再利用
if [[ -z "$entitlement_id" ]] && printf '%s' "$response" | jq -e '.type == "resource_already_exists" or .code == 7263' >/dev/null 2>&1; then
  printf '  → already exists, looking up existing id...\n'
  list_response=$(rc_api_v2 GET "/projects/{project_id}/entitlements?limit=50")
  entitlement_id=$(printf '%s' "$list_response" | jq -r --arg lk "$LOOKUP_KEY" \
    '.items[] | select(.lookup_key == $lk) | .id' | head -1)
fi

if [[ -z "$entitlement_id" ]]; then
  printf 'Failed to create entitlement. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → ready: id=%s lookup_key=%s\n' "$entitlement_id" "$LOOKUP_KEY"
```

**L50-64 の attach ブロック**:

```bash
if [[ -n "$ATTACH_PRODUCTS" ]]; then
  IFS=',' read -ra SIDS <<< "$ATTACH_PRODUCTS"

  rc_ids=()
  for sid in "${SIDS[@]}"; do
    # shellcheck disable=SC2207
    ids_for_sid=($(resolve_rc_product_ids_by_sid "$sid"))
    if [[ ${#ids_for_sid[@]} -eq 0 ]]; then
      printf 'Warning: No RC product found for store_identifier="%s" (skipping)\n' "$sid" >&2
      continue
    fi
    rc_ids+=("${ids_for_sid[@]}")
  done

  if [[ ${#rc_ids[@]} -eq 0 ]]; then
    printf 'Error: No RC products resolved for attach. Create products first.\n' >&2
    exit 1
  fi

  product_id_list=$(printf '%s\n' "${rc_ids[@]}" | jq -R . | jq -s .)
  attach_body=$(jq -n --argjson pids "$product_id_list" '{product_ids: $pids}')

  printf '\nAttaching %d RC product IDs to entitlement %s\n' "${#rc_ids[@]}" "$LOOKUP_KEY"
  printf '  target ids: %s\n' "$(printf '%s ' "${rc_ids[@]}")"
  attach_response=$(rc_api_v2 POST "/projects/{project_id}/entitlements/${entitlement_id}/actions/attach_products" "$attach_body")

  if printf '%s' "$attach_response" | jq -e '.id' >/dev/null 2>&1; then
    printf '  → attached\n'
  elif [[ -z "$attach_response" ]]; then
    printf '  → attached (empty body)\n'
  else
    printf 'Attach response: %s\n' "$attach_response"
  fi
fi
```

### 4. `create_package.sh` — attach body / 409 冪等化 / 共通関数置換

**L51-59 の product lookup を共通関数呼び出しに**:

```bash
printf 'Looking up product: %s\n' "$PRODUCT_ID"
rc_product_id=$(resolve_rc_product_id_by_sid "$PRODUCT_ID")

if [[ -z "$rc_product_id" ]]; then
  printf 'Product with store_identifier="%s" not found in RevenueCat.\n' "$PRODUCT_ID" >&2
  exit 1
fi
```

**L73-91 の Package 作成 + attach ブロック**:

```bash
package_id=$(printf '%s' "$pkg_response" | jq -r '.id // empty')

# 409 なら既存 package を再利用
if [[ -z "$package_id" ]] && printf '%s' "$pkg_response" | jq -e '.type == "resource_already_exists" or .code == 7263' >/dev/null 2>&1; then
  printf '  → already exists, looking up existing id...\n'
  list_response=$(rc_api_v2 GET "/projects/{project_id}/offerings/${offering_id}/packages?limit=50")
  package_id=$(printf '%s' "$list_response" | jq -r --arg lk "$PACKAGE_KEY" \
    '.items[] | select(.lookup_key == $lk) | .id' | head -1)
fi

if [[ -z "$package_id" ]]; then
  printf 'Failed to create package. Response: %s\n' "$pkg_response" >&2
  exit 1
fi
printf '  → ready: id=%s\n' "$package_id"

# RC v2: POST /projects/{pid}/offerings/{oid}/packages/{pkid}/actions/attach_products
# body: {products: [{product_id, eligibility_criteria}]}
attach_body=$(jq -n --arg pid "$rc_product_id" \
  '{products: [{product_id: $pid, eligibility_criteria: "all"}]}')

printf 'Attaching product %s to package %s\n' "$PRODUCT_ID" "$PACKAGE_KEY"
attach_response=$(rc_api_v2 POST \
  "/projects/{project_id}/offerings/${offering_id}/packages/${package_id}/actions/attach_products" \
  "$attach_body")

if printf '%s' "$attach_response" | jq -e '.id' >/dev/null 2>&1; then
  printf '  → attached\n'
elif [[ -z "$attach_response" ]]; then
  printf '  → attached (empty body)\n'
elif printf '%s' "$attach_response" | jq -e '(.message // "") | test("already|exists"; "i")' >/dev/null 2>&1; then
  printf '  → already attached, skipping\n'
else
  printf 'Attach response: %s\n' "$attach_response"
fi
```

### 5. `set_current_offering.sh` — Dashboard 手動案内

ファイル全体を以下に置き換え:

```bash
#!/usr/bin/env bash
# Current Offering は RC API v2 に対応エンドポイントが無いため Dashboard 手動が必要
# https://www.revenuecat.com/docs/offerings/overview
# Usage: set_current_offering.sh --lookup-key default

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

LOOKUP_KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lookup-key) LOOKUP_KEY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${LOOKUP_KEY:?--lookup-key is required (e.g., default)}"

offerings_response=$(rc_api_v2 GET "/projects/{project_id}/offerings")
offering_id=$(printf '%s' "$offerings_response" | jq -r --arg lk "$LOOKUP_KEY" \
  '.items[] | select(.lookup_key == $lk) | .id' | head -1)

if [[ -z "$offering_id" ]]; then
  printf 'Offering with lookup_key="%s" not found.\n' "$LOOKUP_KEY" >&2
  exit 1
fi

cat >&2 <<EOF

================================================================
[Manual Step] Current Offering は RC Dashboard で設定してください
(RC API v2 にエンドポイントが存在しないため自動化不可)

1. https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/offerings/${offering_id}
2. "Make Current" を押下
3. lookup_key=${LOOKUP_KEY} に "current" バッジが付けば完了

出典: https://www.revenuecat.com/docs/offerings/overview
================================================================

EOF

exit 0
```

### 6. `orchestrate.sh` — Phase 3 呼び出しに `--app-type` 追加

**L249-255**:

```bash
  printf '\n# RC Products (iOS): %s\n' "$product_ids"
  bash "${RC_SETUP_SKILL}/create_products.sh" \
    --app-id "$RC_IOS_APP_ID" \
    --app-type app_store \
    --product-ids "$product_ids" \
    $DRY_RUN_FLAG || true

  if [[ -n "$RC_ANDROID_APP_ID" ]]; then
    printf '\n# RC Products (Android): %s\n' "$product_ids"
    bash "${RC_SETUP_SKILL}/create_products.sh" \
      --app-id "$RC_ANDROID_APP_ID" \
      --app-type play_store \
      --product-ids "$product_ids" \
      $DRY_RUN_FLAG || true
  fi
```

---

## 既知の不確実性と対処法

### 不確実性: `create_package.sh` の attach body キー名

現行エラー `'products' is a required property` から `products` が最有力。もし修正後に別のキー要求エラーが出たら実装側でログを見て対応:
- `'product_associations' is a required property` → `product_associations` に書換
- エンドポイントパス `/offerings/${offering_id}/packages/${package_id}/...` 形式に合わせた (現行は `/packages/${package_id}/...` で offering_id 欠け)

### 不確実性: RC v2 の 409 エラー型

`create_products.sh` 既存は `.code == 7263` で判定。`create_app.sh` は `.type == "resource_already_exists"` 方式。本プランでは両対応 (`.type == "resource_already_exists" or .code == 7263`) で統一。

### 後続 TODO (本プラン範囲外)
- Play lifetime 商品: AAB に `com.android.vending.BILLING` permission 追加 → Internal testing track upload 後に `create_inapp_product.sh` で登録 → 本 Skill 再実行で RC Android 側にも `shoppinglist_10000yen_lifetime` が作成される

---

## 検証手順

### 1. Phase 3 再実行

```bash
bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --phase 3
```

### 2. 成功判定ログ

| ステップ | 期待ログ |
|---|---|
| RC iOS App | `RC iOS app_id: appde3e336d9a` (既存再利用) |
| RC Android App | `RC Android app_id: app5c10588d85` (既存再利用) |
| Products (iOS) ×3 | `→ ready: id=prodXXX` (全件。409 でも OK) |
| Products (Android) ×2 | 同上。`store_identifier=shoppinglist_500yen_1month:1month` 形式であることをログで確認 |
| Entitlement | `→ ready: id=entlc13ddeef52` (409 再利用)、`Attaching N RC product IDs` で N≥5 (iOS 3 + Android 2 subscription) |
| Offering | `→ ready: id=ofrngfa5c5fdbb0` (409 再利用) |
| Packages ×3 | 各 package で `→ attached` |
| Set current | `[Manual Step] Current Offering は RC Dashboard で設定してください` の案内 + URL |

### 3. RC Dashboard で目視確認

- https://app.revenuecat.com/projects/a9466f75/entitlements/entlc13ddeef52 → Attached Products が 5 以上 (iOS 3 + Android 2 subscription)
- https://app.revenuecat.com/projects/a9466f75/offerings/ofrngfa5c5fdbb0 → Packages 3 件にそれぞれ Product が attach されている
- Offering `default` に手動で "Make Current" を押下

### 4. 冪等性確認

同コマンドを 2 回連続実行。2 回目も失敗なしで最後まで到達 (全リソースが既存再利用される) ことを確認。

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
- [ ] 既存リソースを再作成せず再利用する冪等性が担保されている (409 → GET)
- [ ] Phase 3 の再実行 `bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --phase 3` が完走する
- [ ] `set_current_offering.sh` は Dashboard URL を出力し exit 0 する
- [ ] RC Dashboard で Entitlement / Offering / Packages に期待通り Products が attach されている
- [ ] 冪等性確認: 同コマンドを 2 回連続実行しても失敗しない
