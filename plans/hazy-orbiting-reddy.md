# IAP Skill 群 venv 化 + Play lifetime (inappproducts) 実装

## Context

shoppinglist で自作 IAP Skill 4 本 (`app-store-connect-iap`, `google-play-iap`, `revenuecat-setup`, `iap-orchestrator`) を実地テスト中。2 つの問題を同時に解決する必要がある。

1. **PyJWT が macOS Homebrew Python の PEP 668 で install 不可** → JWT 生成がブロックされ、ASC / Play いずれの API も叩けない
2. **Play 側 lifetime (inappproducts) 用スクリプトが未実装** → `shoppinglist_10000yen_lifetime` を Play Console 側に登録できず、orchestrate.sh が該当商品を continue でスキップしている

ユーザー指示:
- 全ストア (iOS + Play + RC) を対象にテストする
- `GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64` は export 済み
- lifetime も Play 側実装を含めて対応する

狙い: 本作業完了後、`orchestrate.sh tmp/iap-config.json --phase 1` と `--phase 3` を通し、ASC / Play / RC それぞれに 3 商品 (月額 / 年額 / 買い切り) が登録された状態を作る。

関連ブランチ: PR #219 (`feat/iap-automation-skills`)

---

## A. venv 化

### A-1. 設計判断

- **Skill ごとに独立 venv** (`${SKILL_DIR}/.venv/`)。`_shared/` には切り出さない。Skill のポータビリティを維持する。
- **パッケージピン留め**: `pyjwt==2.9.0` `cryptography==43.0.1`。PyJWT 3.x 系で `jwt.encode` の戻り値型が変わった前例があるため再現性を優先する。
- **冪等性**: `${SKILL_DIR}/.venv/bin/python` が存在すれば即 return。初回のみ stderr に構築ログを出す。
- **`require_python_jwt` は廃止**: `generate_jwt` / `get_access_token` が内部で `ensure_venv` を呼ぶため、呼び出し側での事前チェックは不要になる。

### A-2. `app-store-connect-iap/scripts/_common.sh`

```diff
@@ -8,12 +8,40 @@ set -euo pipefail
 readonly ASC_API_BASE="https://api.appstoreconnect.apple.com"
 readonly ASC_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'
 readonly ASC_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+readonly ASC_VENV_DIR="${ASC_SCRIPT_DIR}/../.venv"
+readonly ASC_VENV_PYTHON="${ASC_VENV_DIR}/bin/python"
+# PyJWT 3.x 系で jwt.encode の戻り値型が str ↔ bytes で変わった前例があるためピン留め
+readonly ASC_VENV_PACKAGES=("pyjwt==2.9.0" "cryptography==43.0.1")
 
-# JWT を生成して echo。Skill 内では JWT_TOKEN 変数にキャッシュして使う。
+ensure_venv() {
+  if [[ -x "${ASC_VENV_PYTHON}" ]]; then
+    return 0
+  fi
+  if ! command -v python3 >/dev/null 2>&1; then
+    printf 'Error: python3 is required to bootstrap venv.\n' >&2
+    exit 1
+  fi
+  printf 'Creating venv: %s\n' "${ASC_VENV_DIR}" >&2
+  python3 -m venv "${ASC_VENV_DIR}"
+  printf 'Installing packages: %s\n' "${ASC_VENV_PACKAGES[*]}" >&2
+  "${ASC_VENV_PYTHON}" -m pip install --quiet --upgrade pip
+  "${ASC_VENV_PYTHON}" -m pip install --quiet "${ASC_VENV_PACKAGES[@]}"
+}
+
 generate_jwt() {
-  python3 "${ASC_SCRIPT_DIR}/_jwt.py"
+  ensure_venv
+  "${ASC_VENV_PYTHON}" "${ASC_SCRIPT_DIR}/_jwt.py"
 }
@@ -110,16 +138,3 @@ require_jq() {
     exit 1
   fi
 }
-
-require_python_jwt() {
-  if ! command -v python3 >/dev/null 2>&1; then
-    printf 'Error: python3 is required.\n' >&2
-    exit 1
-  fi
-  if ! python3 -c "import jwt" 2>/dev/null; then
-    printf 'Error: PyJWT is required. Install with: pip3 install pyjwt cryptography\n' >&2
-    exit 1
-  fi
-}
```

### A-3. ASC Skill 10 本から `require_python_jwt` 行を削除

対象: `create_iap_v2.sh`, `create_subscription.sh`, `create_subscription_group.sh`, `get_app_id.sh`, `set_iap_v2_localization.sh`, `set_iap_v2_price.sh`, `set_localization.sh`, `set_prices.sh`, `submit_subscription.sh`, `upload_review_screenshot.sh`

```diff
 source "${SCRIPT_DIR}/_common.sh"
 
 require_jq
-require_python_jwt
```

### A-4. `google-play-iap/scripts/_common.sh`

ASC と同型。`PLAY_` プレフィックスで命名。

```diff
@@ -7,11 +7,37 @@ set -euo pipefail
 readonly PLAY_API_BASE="https://androidpublisher.googleapis.com/androidpublisher/v3"
 readonly PLAY_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'
 readonly PLAY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+readonly PLAY_VENV_DIR="${PLAY_SCRIPT_DIR}/../.venv"
+readonly PLAY_VENV_PYTHON="${PLAY_VENV_DIR}/bin/python"
+# PyJWT 3.x 系で jwt.encode の戻り値型が str ↔ bytes で変わった前例があるためピン留め
+readonly PLAY_VENV_PACKAGES=("pyjwt==2.9.0" "cryptography==43.0.1")
 
-# Access token を生成して echo
+ensure_venv() {
+  if [[ -x "${PLAY_VENV_PYTHON}" ]]; then
+    return 0
+  fi
+  if ! command -v python3 >/dev/null 2>&1; then
+    printf 'Error: python3 is required to bootstrap venv.\n' >&2
+    exit 1
+  fi
+  printf 'Creating venv: %s\n' "${PLAY_VENV_DIR}" >&2
+  python3 -m venv "${PLAY_VENV_DIR}"
+  printf 'Installing packages: %s\n' "${PLAY_VENV_PACKAGES[*]}" >&2
+  "${PLAY_VENV_PYTHON}" -m pip install --quiet --upgrade pip
+  "${PLAY_VENV_PYTHON}" -m pip install --quiet "${PLAY_VENV_PACKAGES[@]}"
+}
+
 get_access_token() {
-  python3 "${PLAY_SCRIPT_DIR}/_auth.py"
+  ensure_venv
+  "${PLAY_VENV_PYTHON}" "${PLAY_SCRIPT_DIR}/_auth.py"
 }
@@ -80,16 +106,3 @@ require_jq() {
     exit 1
   fi
 }
-
-require_python_jwt() {
-  if ! command -v python3 >/dev/null 2>&1; then
-    printf 'Error: python3 is required.\n' >&2
-    exit 1
-  fi
-  if ! python3 -c "import jwt" 2>/dev/null; then
-    printf 'Error: PyJWT is required. Install with: pip3 install pyjwt cryptography\n' >&2
-    exit 1
-  fi
-}
```

### A-5. Play Skill 6 本から `require_python_jwt` 削除

対象: `activate_base_plan.sh`, `cleanup_edits.sh`, `create_base_plan.sh`, `create_subscription.sh`, `promote_track.sh`, `upload_aab.sh`

```diff
 source "${SCRIPT_DIR}/_common.sh"
 
 require_jq
-require_python_jwt
```

### A-6. `.gitignore`

```diff
@@ -68,3 +68,5 @@ tmp/implement-issue/
 
 # run-pr-quality-checks skill temp files
 tmp/pr-quality-checks/
+
+.claude/skills/*/.venv/
```

---

## B. Play inappproducts (lifetime) 新規実装

### B-1. 設計判断

- **エンドポイント**: `PUT /androidpublisher/v3/applications/{packageName}/inappproducts/{sku}?autoConvertMissingPrices=false`
  - Subscriptions と違い Edits セッション不要
  - PUT は upsert 相当なので **再実行しても 409 にならない** (POST だと既存と衝突して 409)
- **Body**:
  - `status: "active"` (即販売可化)
  - `purchaseType: "managedUser"` (非消費型)
  - `defaultPrice` と `prices.JP` の両方に同じ priceMicros を設定
  - `defaultLanguage: "ja-JP"`, `listings.ja-JP` / `listings.en-US`
  - `regionsVersion` は subscriptions 固有のため不要
- **価格変換**: JPY は小数点なし通貨 → `${PRICE_JP}000000` で priceMicros 化
- **response 判定**: `.sku` フィールドの存在で成功判定 (既存 `create_subscription.sh` が `.productId` で判定しているのと同じ流儀)
- `_common.sh` の `play_api` ヘルパは method を引数で受け取る実装 (L47 `local method="$1"`) で PUT 対応済み。

### B-2. 新規ファイル `google-play-iap/scripts/create_inapp_product.sh`

```bash
#!/usr/bin/env bash
# inappproduct (one-time / lifetime) を upsert する。
# subscriptions と異なり Edits セッション不要で /inappproducts エンドポイントを直接叩く。
# Usage:
#   create_inapp_product.sh \
#     --package-name com.foo.bar \
#     --product-id shoppinglist_10000yen_lifetime \
#     --price-jp 10000 \
#     --display-name-ja "プレミアム（買い切り）" \
#     --display-name-en "Premium Lifetime" \
#     [--description-ja "..."] [--description-en "..."]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

PACKAGE_NAME=""
PRODUCT_ID=""
PRICE_JP=""
DISPLAY_NAME_JA=""
DISPLAY_NAME_EN=""
DESCRIPTION_JA=""
DESCRIPTION_EN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --price-jp) PRICE_JP="$2"; shift 2 ;;
    --display-name-ja) DISPLAY_NAME_JA="$2"; shift 2 ;;
    --display-name-en) DISPLAY_NAME_EN="$2"; shift 2 ;;
    --description-ja) DESCRIPTION_JA="$2"; shift 2 ;;
    --description-en) DESCRIPTION_EN="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${PRICE_JP:?--price-jp is required (JPY integer)}"
: "${DISPLAY_NAME_JA:?--display-name-ja is required}"
: "${DISPLAY_NAME_EN:?--display-name-en is required}"

validate_product_id "$PRODUCT_ID"

# JPY は小数点なし通貨
PRICE_MICROS="${PRICE_JP}000000"

body=$(jq -n \
  --arg package "$PACKAGE_NAME" \
  --arg sku "$PRODUCT_ID" \
  --arg priceMicros "$PRICE_MICROS" \
  --arg ja_title "$DISPLAY_NAME_JA" \
  --arg ja_desc "$DESCRIPTION_JA" \
  --arg en_title "$DISPLAY_NAME_EN" \
  --arg en_desc "$DESCRIPTION_EN" \
  '{
    packageName: $package,
    sku: $sku,
    status: "active",
    purchaseType: "managedUser",
    defaultPrice: {priceMicros: $priceMicros, currency: "JPY"},
    prices: {JP: {priceMicros: $priceMicros, currency: "JPY"}},
    defaultLanguage: "ja-JP",
    listings: {
      "ja-JP": {title: $ja_title, description: $ja_desc},
      "en-US": {title: $en_title, description: $en_desc}
    }
  }')

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_sku=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)

printf 'Upserting in-app product: %s (JPY %s)\n' "$PRODUCT_ID" "$PRICE_JP"
response=$(play_api PUT "/applications/${PACKAGE_NAME}/inappproducts/${encoded_sku}?autoConvertMissingPrices=false" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.sku' >/dev/null 2>&1; then
  printf '  → upserted: id=%s\n' "$PRODUCT_ID"
else
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
```

ファイルモード: `chmod 755` (他の `*.sh` と同じ)。

---

## C. `orchestrate.sh` の lifetime 分岐修正

現状 L166-169 で lifetime/consumable をスキップしているロジックを解除し、subscription 分岐と並列に inappproduct 分岐を差し込む。

```diff
--- a/.claude/skills/iap-orchestrator/scripts/orchestrate.sh
+++ b/.claude/skills/iap-orchestrator/scripts/orchestrate.sh
@@ -163,38 +163,43 @@ if [[ "$SKIP_PLAY" -ne 1 && ( -z "$RUN_PHASE" || "$RUN_PHASE" == "1" ) ]]; then
     desc_en=$(jq -r ".products[$i].description[\"en-US\"] // \"\"" "$CONFIG")
     pid=$(build_product_id "$PROJECT" "$price" "$type")
 
-    if is_iap_v2_type "$type"; then
-      printf '\n# Play: type=%s (lifetime/consumable) は inappproducts スクリプト未実装のためスキップ: %s\n' "$type" "$pid" >&2
-      continue
-    fi
-
-    bpid="$type"
-
-    printf '\n# Play Subscription: %s\n' "$pid"
-    bash "${PLAY_IAP_SKILL}/create_subscription.sh" \
-      --package-name "$PACKAGE_NAME" \
-      --product-id "$pid" \
-      --display-name-ja "$name_ja" \
-      --display-name-en "$name_en" \
-      --description-ja "$desc_ja" \
-      --description-en "$desc_en" \
-      $DRY_RUN_FLAG || true
-
-    printf '\n# Play Base Plan: %s/%s\n' "$pid" "$bpid"
-    bash "${PLAY_IAP_SKILL}/create_base_plan.sh" \
-      --package-name "$PACKAGE_NAME" \
-      --product-id "$pid" \
-      --base-plan-id "$bpid" \
-      --price-jp "$price" \
-      $DRY_RUN_FLAG || true
-
-    printf '\n# Play Activate: %s/%s\n' "$pid" "$bpid"
-    bash "${PLAY_IAP_SKILL}/activate_base_plan.sh" \
-      --package-name "$PACKAGE_NAME" \
-      --product-id "$pid" \
-      --base-plan-id "$bpid" \
-      $DRY_RUN_FLAG || true
+    if is_subscription_type "$type"; then
+      bpid="$type"
+
+      printf '\n# Play Subscription: %s\n' "$pid"
+      bash "${PLAY_IAP_SKILL}/create_subscription.sh" \
+        --package-name "$PACKAGE_NAME" \
+        --product-id "$pid" \
+        --display-name-ja "$name_ja" \
+        --display-name-en "$name_en" \
+        --description-ja "$desc_ja" \
+        --description-en "$desc_en" \
+        $DRY_RUN_FLAG || true
+
+      printf '\n# Play Base Plan: %s/%s\n' "$pid" "$bpid"
+      bash "${PLAY_IAP_SKILL}/create_base_plan.sh" \
+        --package-name "$PACKAGE_NAME" \
+        --product-id "$pid" \
+        --base-plan-id "$bpid" \
+        --price-jp "$price" \
+        $DRY_RUN_FLAG || true
+
+      printf '\n# Play Activate: %s/%s\n' "$pid" "$bpid"
+      bash "${PLAY_IAP_SKILL}/activate_base_plan.sh" \
+        --package-name "$PACKAGE_NAME" \
+        --product-id "$pid" \
+        --base-plan-id "$bpid" \
+        $DRY_RUN_FLAG || true
+    elif is_iap_v2_type "$type"; then
+      printf '\n# Play In-App Product (lifetime): %s\n' "$pid"
+      bash "${PLAY_IAP_SKILL}/create_inapp_product.sh" \
+        --package-name "$PACKAGE_NAME" \
+        --product-id "$pid" \
+        --price-jp "$price" \
+        --display-name-ja "$name_ja" \
+        --display-name-en "$name_en" \
+        --description-ja "$desc_ja" \
+        --description-en "$desc_en" \
+        $DRY_RUN_FLAG || true
+    else
+      printf 'Unknown type %s for %s, skipping Play phase\n' "$type" "$pid" >&2
+    fi
   done
 fi
```

ASC 側 (orchestrate.sh L103-149) は既に `is_subscription_type` / `is_iap_v2_type` で分岐済みのため変更不要。

---

## D. 作業順序とコミット単位

1. venv 化を先に実装 (A-2 → A-4) → venv 単体で JWT 発行できるか確認
2. ASC / Play の各スクリプトから `require_python_jwt` を削除 (A-3, A-5)
3. `.gitignore` 追加 (A-6)
4. `create_inapp_product.sh` 新規作成 (B-2)
5. `orchestrate.sh` の lifetime 分岐差し替え (C)
6. DRY-RUN → 本実行 (下記「動作確認」)

PR #219 (`feat/iap-automation-skills`) に追加コミットする。目的が「Skill を shoppinglist で実地運用するための修正」で一貫しているため PR 分割はしない。

コミット単位:
- `feat(iap-skills): PyJWT を Skill ローカル venv に隔離 (PEP 668 対応)`
- `feat(google-play-iap): inappproducts upsert スクリプトを追加`
- `feat(iap-orchestrator): Play 側 lifetime/consumable 分岐を有効化`
- `chore: .gitignore に Skill ローカル venv を追加`

---

## 動作確認

### 1. venv 自動構築の冪等性

```bash
rm -rf .claude/skills/app-store-connect-iap/.venv
rm -rf .claude/skills/google-play-iap/.venv

# ASC 側の任意スクリプトで venv が自動構築されること確認
bash .claude/skills/app-store-connect-iap/scripts/get_app_id.sh --bundle-id com.bannzai.shoppinglist
# 期待: stderr に "Creating venv: ..." "Installing packages: ..." が出て、その後 API が叩かれる

# 再実行で venv ログが出ない (冪等)
bash .claude/skills/app-store-connect-iap/scripts/get_app_id.sh --bundle-id com.bannzai.shoppinglist
# 期待: Creating venv のログは出ない

# Play 側も同様
bash .claude/skills/google-play-iap/scripts/cleanup_edits.sh --package-name com.bannzai.shoppinglist
```

### 2. DRY-RUN 通し

```bash
bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --dry-run --phase 1
```

確認項目:
- ASC: 3 商品それぞれに `[DRY RUN] curl` が出ること (月額 / 年額 Subscription、買い切り IAP V2)
- Play: 3 商品それぞれに `[DRY RUN] curl` が出ること
- lifetime 商品 (`shoppinglist_10000yen_lifetime`) が `PUT /applications/.../inappproducts/shoppinglist_10000yen_lifetime?autoConvertMissingPrices=false` として組み立てられていること (誤って `/subscriptions/` に飛んでいないこと)

### 3. 本実行 (Phase 1)

```bash
bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --phase 1
```

確認項目:
- App Store Connect: 月額 Subscription / 年額 Subscription / 買い切り IAP V2 の 3 商品が作成されている
- Google Play Console:
  - `shoppinglist_500yen_1month`: Subscription (ACTIVE base plan)
  - `shoppinglist_4000yen_1year`: Subscription (ACTIVE base plan)
  - `shoppinglist_10000yen_lifetime`: In-app product (status=active, JPY 10,000)

### 4. 本実行 (Phase 3, RevenueCat)

```bash
bash .claude/skills/iap-orchestrator/scripts/orchestrate.sh tmp/iap-config.json --phase 3
```

確認項目:
- iOS アプリと Android アプリに 3 商品ずつ (合計 6 products) 登録済
- `Premium` entitlement に 3 商品すべてアタッチ
- `default` offering に `$rc_monthly` / `$rc_annual` / `$rc_lifetime` の 3 package

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している (`create_subscription.sh` を雛形に `create_inapp_product.sh` を書く)

### venv 化
- [ ] `app-store-connect-iap/scripts/_common.sh` に `ASC_VENV_*` 定数と `ensure_venv` を追加
- [ ] `generate_jwt` が `ensure_venv` → venv Python 実行に書き換わっている
- [ ] `require_python_jwt` を `_common.sh` から削除
- [ ] ASC Skill 10 本のスクリプトから `require_python_jwt` 行を削除
- [ ] `google-play-iap/scripts/_common.sh` にも同型の venv ヘルパを追加
- [ ] `get_access_token` が `ensure_venv` 経由になっている
- [ ] Play Skill 6 本のスクリプトから `require_python_jwt` 行を削除
- [ ] `.gitignore` に `.claude/skills/*/.venv/` を追加
- [ ] `git status` で `.venv/` が untracked (実体は ignore されて表示されない) であること確認

### Play inappproducts
- [ ] `google-play-iap/scripts/create_inapp_product.sh` 新規作成 (モード 755)
- [ ] `PUT /inappproducts/{sku}?autoConvertMissingPrices=false` で upsert
- [ ] `defaultPrice` と `prices.JP` の両方に priceMicros
- [ ] `listings.ja-JP` と `listings.en-US`、`defaultLanguage: "ja-JP"`
- [ ] `status: "active"`, `purchaseType: "managedUser"`
- [ ] DRY_RUN 分岐対応
- [ ] `orchestrate.sh` で `is_subscription_type` / `is_iap_v2_type` の elif 分岐に差し替え
- [ ] 既存 lifetime スキップコード (L166-169) が削除されている

### 動作確認
- [ ] venv 削除後、任意スクリプト実行で自動構築されること
- [ ] 再実行で venv 構築ログが出ないこと (冪等)
- [ ] `orchestrate.sh --dry-run --phase 1` で 3 商品 × 2 ストア分の curl ログが出ること
- [ ] Play の lifetime 商品が `/inappproducts/...` エンドポイントに飛ぶこと
- [ ] `orchestrate.sh --phase 1` で ASC / Play 両方に 3 商品ずつ登録されること
- [ ] `orchestrate.sh --phase 3` で RC に 6 products + Entitlement + Offering が登録されること

### 共通
- [ ] エラーメッセージはそのまま表示 (加工・プレフィックス除去なし)
- [ ] `require_python_jwt` の呼び出し箇所が 1 件も残っていないこと (`grep -r require_python_jwt .claude/skills/` で 0 件)
