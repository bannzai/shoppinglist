#!/usr/bin/env bash
# 3 Skill を順次起動して IAP 全セットアップを完結させる
# Usage: orchestrate.sh config.json [--dry-run] [--phase 1|2|3] [--skip-asc] [--skip-play] [--skip-rc]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

CONFIG=""
DRY_RUN_FLAG=""
RUN_PHASE=""
SKIP_ASC=0
SKIP_PLAY=0
SKIP_RC=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN_FLAG="--dry-run"; shift ;;
    --phase) RUN_PHASE="$2"; shift 2 ;;
    --skip-asc) SKIP_ASC=1; shift ;;
    --skip-play) SKIP_PLAY=1; shift ;;
    --skip-rc) SKIP_RC=1; shift ;;
    *) CONFIG="$1"; shift ;;
  esac
done

: "${CONFIG:?Usage: orchestrate.sh config.json [--dry-run] [--phase N] [--skip-asc|--skip-play|--skip-rc]}"

# Phase 0: 検証
printf '\n=== Phase 0: validate ===\n'
bash "${SCRIPT_DIR}/validate.sh" "$CONFIG"

# 環境変数チェックは skip 状況に応じて
if [[ "$SKIP_ASC" -ne 1 ]]; then
  : "${ASC_KEY_P8_BASE64:?ASC_KEY_P8_BASE64 required}"
  : "${ASC_KEY_ID:?ASC_KEY_ID required}"
  : "${ASC_ISSUER_ID:?ASC_ISSUER_ID required}"
fi
if [[ "$SKIP_PLAY" -ne 1 ]]; then
  : "${GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64:?GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 required}"
fi
if [[ "$SKIP_RC" -ne 1 ]]; then
  : "${REVENUECAT_V2_SECRET_KEY:?REVENUECAT_V2_SECRET_KEY required}"
  : "${REVENUECAT_PROJECT_ID:?REVENUECAT_PROJECT_ID required}"
fi

PROJECT=$(jq -r '.project' "$CONFIG")
BUNDLE_ID=$(jq -r '.app.bundle_id' "$CONFIG")
PACKAGE_NAME=$(jq -r '.app.package_name // empty' "$CONFIG")
DISPLAY_NAME_EN=$(jq -r '.app.display_name["en-US"]' "$CONFIG")
GROUP_REF=$(jq -r '.subscription_group_reference_name // "Premium"' "$CONFIG")
ENTITLEMENT_KEY=$(jq -r '.revenuecat.entitlement_lookup_key' "$CONFIG")
ENTITLEMENT_NAME=$(jq -r '.revenuecat.entitlement_display_name // "Premium"' "$CONFIG")

# Subscription type が 1 つでもあるか判定
HAS_SUBSCRIPTION=0
HAS_IAP_V2=0
product_count=$(jq '.products | length' "$CONFIG")
for ((i=0; i<product_count; i++)); do
  type=$(jq -r ".products[$i].type" "$CONFIG")
  if is_subscription_type "$type"; then HAS_SUBSCRIPTION=1; fi
  if is_iap_v2_type "$type"; then HAS_IAP_V2=1; fi
done

# create スクリプトの出力 (例: "  → created: id=12345") から ID をパース
extract_created_id() {
  printf '%s' "$1" | grep -oE 'id=[a-zA-Z0-9_-]+' | head -1 | sed 's/id=//'
}

# Phase 1a: ASC
if [[ "$SKIP_ASC" -ne 1 && ( -z "$RUN_PHASE" || "$RUN_PHASE" == "1" ) ]]; then
  printf '\n=== Phase 1a: App Store Connect ===\n'

  printf '\n# Resolving ASC app_id from bundle_id %s\n' "$BUNDLE_ID"
  if [[ -n "$DRY_RUN_FLAG" ]]; then
    ASC_APP_ID="DRY_RUN_APP_ID"
  else
    ASC_APP_ID=$(bash "${ASC_IAP_SKILL}/get_app_id.sh" --bundle-id "$BUNDLE_ID")
  fi
  printf 'ASC app_id: %s\n' "$ASC_APP_ID"

  # Subscription Group は Subscription type product がある場合のみ
  ASC_GROUP_ID=""
  if [[ $HAS_SUBSCRIPTION -eq 1 ]]; then
    printf '\n# Creating ASC subscription group: %s\n' "$GROUP_REF"
    group_out=$(bash "${ASC_IAP_SKILL}/create_subscription_group.sh" --app-id "$ASC_APP_ID" --reference-name "$GROUP_REF" $DRY_RUN_FLAG 2>&1 || true)
    printf '%s\n' "$group_out"
    if [[ -n "$DRY_RUN_FLAG" ]]; then
      ASC_GROUP_ID="DRY_RUN_GROUP_ID"
    else
      ASC_GROUP_ID=$(extract_created_id "$group_out")
      if [[ -z "$ASC_GROUP_ID" ]]; then
        printf 'Failed to extract ASC group id. Set ASC_GROUP_ID env to continue.\n' >&2
        : "${ASC_GROUP_ID:?ASC_GROUP_ID env required}"
      fi
    fi
    printf 'ASC group_id: %s\n' "$ASC_GROUP_ID"
  fi

  # Product ごとに type 分岐
  for ((i=0; i<product_count; i++)); do
    price=$(jq -r ".products[$i].price_jp" "$CONFIG")
    type=$(jq -r ".products[$i].type" "$CONFIG")
    name_ja=$(jq -r ".products[$i].display_name[\"ja\"]" "$CONFIG")
    name_en=$(jq -r ".products[$i].display_name[\"en-US\"]" "$CONFIG")
    desc_ja=$(jq -r ".products[$i].description[\"ja\"] // \"\"" "$CONFIG")
    desc_en=$(jq -r ".products[$i].description[\"en-US\"] // \"\"" "$CONFIG")
    pid=$(build_product_id "$PROJECT" "$price" "$type")

    if is_subscription_type "$type"; then
      printf '\n# ASC Subscription: %s\n' "$pid"
      sub_out=$(bash "${ASC_IAP_SKILL}/create_subscription.sh" --group-id "$ASC_GROUP_ID" --product-id "$pid" --reference-name "$name_en" $DRY_RUN_FLAG 2>&1 || true)
      printf '%s\n' "$sub_out"
      if [[ -n "$DRY_RUN_FLAG" ]]; then
        sub_id="DRY_RUN_SUB_ID"
      else
        sub_id=$(extract_created_id "$sub_out")
      fi

      if [[ -n "$sub_id" ]]; then
        bash "${ASC_IAP_SKILL}/set_localization.sh" --subscription-id "$sub_id" --locale ja --name "$name_ja" --description "$desc_ja" $DRY_RUN_FLAG || true
        bash "${ASC_IAP_SKILL}/set_localization.sh" --subscription-id "$sub_id" --locale en-US --name "$name_en" --description "$desc_en" $DRY_RUN_FLAG || true
        bash "${ASC_IAP_SKILL}/set_prices.sh" --subscription-id "$sub_id" --price-jp "$price" --territories JPN $DRY_RUN_FLAG || true
      else
        printf 'Skip localization/prices for %s (no sub_id parsed)\n' "$pid" >&2
      fi
    elif is_iap_v2_type "$type"; then
      printf '\n# ASC IAP V2: %s\n' "$pid"
      iap_out=$(bash "${ASC_IAP_SKILL}/create_iap_v2.sh" --app-id "$ASC_APP_ID" --product-id "$pid" --reference-name "$name_en" $DRY_RUN_FLAG 2>&1 || true)
      printf '%s\n' "$iap_out"
      if [[ -n "$DRY_RUN_FLAG" ]]; then
        iap_id="DRY_RUN_IAP_ID"
      else
        iap_id=$(extract_created_id "$iap_out")
      fi

      if [[ -n "$iap_id" ]]; then
        bash "${ASC_IAP_SKILL}/set_iap_v2_localization.sh" --iap-id "$iap_id" --locale ja --name "$name_ja" --description "$desc_ja" $DRY_RUN_FLAG || true
        bash "${ASC_IAP_SKILL}/set_iap_v2_localization.sh" --iap-id "$iap_id" --locale en-US --name "$name_en" --description "$desc_en" $DRY_RUN_FLAG || true
        bash "${ASC_IAP_SKILL}/set_iap_v2_price.sh" --iap-id "$iap_id" --price-jp "$price" $DRY_RUN_FLAG || true
      else
        printf 'Skip localization/price for %s (no iap_id parsed)\n' "$pid" >&2
      fi
    else
      printf 'Unknown type %s for %s, skipping\n' "$type" "$pid" >&2
    fi
  done
fi

# Phase 1b: Play (Subscription は monetization.subscriptions, lifetime/consumable は inappproducts)
if [[ "$SKIP_PLAY" -ne 1 && ( -z "$RUN_PHASE" || "$RUN_PHASE" == "1" ) ]]; then
  printf '\n=== Phase 1b: Google Play ===\n'
  : "${PACKAGE_NAME:?app.package_name required in config for Play phase}"

  for ((i=0; i<product_count; i++)); do
    price=$(jq -r ".products[$i].price_jp" "$CONFIG")
    type=$(jq -r ".products[$i].type" "$CONFIG")
    name_ja=$(jq -r ".products[$i].display_name[\"ja\"]" "$CONFIG")
    name_en=$(jq -r ".products[$i].display_name[\"en-US\"]" "$CONFIG")
    desc_ja=$(jq -r ".products[$i].description[\"ja\"] // \"\"" "$CONFIG")
    desc_en=$(jq -r ".products[$i].description[\"en-US\"] // \"\"" "$CONFIG")
    pid=$(build_product_id "$PROJECT" "$price" "$type")

    if is_subscription_type "$type"; then
      bpid="$type"

      printf '\n# Play Subscription + Base Plan: %s/%s\n' "$pid" "$bpid"
      bash "${PLAY_IAP_SKILL}/create_subscription.sh" \
        --package-name "$PACKAGE_NAME" \
        --product-id "$pid" \
        --base-plan-id "$bpid" \
        --price-jp "$price" \
        --display-name-ja "$name_ja" \
        --display-name-en "$name_en" \
        --description-ja "$desc_ja" \
        --description-en "$desc_en" \
        $DRY_RUN_FLAG || true

      printf '\n# Play Activate: %s/%s\n' "$pid" "$bpid"
      bash "${PLAY_IAP_SKILL}/activate_base_plan.sh" \
        --package-name "$PACKAGE_NAME" \
        --product-id "$pid" \
        --base-plan-id "$bpid" \
        $DRY_RUN_FLAG || true
    elif is_iap_v2_type "$type"; then
      printf '\n# Play In-App Product (%s): %s\n' "$type" "$pid"
      bash "${PLAY_IAP_SKILL}/create_inapp_product.sh" \
        --package-name "$PACKAGE_NAME" \
        --product-id "$pid" \
        --price-jp "$price" \
        --display-name-ja "$name_ja" \
        --display-name-en "$name_en" \
        --description-ja "$desc_ja" \
        --description-en "$desc_en" \
        $DRY_RUN_FLAG || true
    else
      printf 'Unknown type %s for %s, skipping Play phase\n' "$type" "$pid" >&2
    fi
  done
fi

# Phase 2: 手動チェックポイント表示
if [[ -z "$RUN_PHASE" || "$RUN_PHASE" == "2" ]]; then
  printf '\n=== Phase 2: 手動チェックポイント ===\n'
  bash "${SCRIPT_DIR}/manual_checkpoints.sh"
  printf '\n[操作後] 上記を完了したら --phase 3 で再実行してください。\n'
  if [[ -z "$RUN_PHASE" ]]; then
    printf 'Aborting before Phase 3 to give you time for manual steps.\n'
    exit 0
  fi
fi

# Phase 3: RevenueCat
if [[ "$SKIP_RC" -ne 1 && ( -z "$RUN_PHASE" || "$RUN_PHASE" == "3" ) ]]; then
  printf '\n=== Phase 3: RevenueCat ===\n'

  printf '\n# RC App: app_store\n'
  ios_out=$(bash "${RC_SETUP_SKILL}/create_app.sh" --type app_store --bundle-id "$BUNDLE_ID" --name "$DISPLAY_NAME_EN (iOS)" $DRY_RUN_FLAG 2>&1 || true)
  printf '%s\n' "$ios_out"
  if [[ -n "$DRY_RUN_FLAG" ]]; then
    RC_IOS_APP_ID="DRY_RUN_IOS_APP_ID"
  else
    RC_IOS_APP_ID=$(extract_created_id "$ios_out")
    if [[ -z "$RC_IOS_APP_ID" ]]; then
      printf 'Failed to extract RC iOS app_id. Set RC_IOS_APP_ID env to continue.\n' >&2
      : "${RC_IOS_APP_ID:?RC_IOS_APP_ID env required}"
    fi
  fi
  printf 'RC iOS app_id: %s\n' "$RC_IOS_APP_ID"

  RC_ANDROID_APP_ID=""
  if [[ -n "$PACKAGE_NAME" ]]; then
    printf '\n# RC App: play_store\n'
    android_out=$(bash "${RC_SETUP_SKILL}/create_app.sh" --type play_store --package-name "$PACKAGE_NAME" --name "$DISPLAY_NAME_EN (Android)" $DRY_RUN_FLAG 2>&1 || true)
    printf '%s\n' "$android_out"
    if [[ -n "$DRY_RUN_FLAG" ]]; then
      RC_ANDROID_APP_ID="DRY_RUN_ANDROID_APP_ID"
    else
      RC_ANDROID_APP_ID=$(extract_created_id "$android_out")
    fi
    printf 'RC Android app_id: %s\n' "$RC_ANDROID_APP_ID"
  fi

  # Product ID リスト
  product_ids=$(list_product_ids "$CONFIG" | tr '\n' ',' | sed 's/,$//')

  printf '\n# RC Products (iOS): %s\n' "$product_ids"
  bash "${RC_SETUP_SKILL}/create_products.sh" --app-id "$RC_IOS_APP_ID" --product-ids "$product_ids" $DRY_RUN_FLAG || true

  if [[ -n "$RC_ANDROID_APP_ID" ]]; then
    printf '\n# RC Products (Android): %s\n' "$product_ids"
    bash "${RC_SETUP_SKILL}/create_products.sh" --app-id "$RC_ANDROID_APP_ID" --product-ids "$product_ids" $DRY_RUN_FLAG || true
  fi

  printf '\n# RC Entitlement: %s\n' "$ENTITLEMENT_KEY"
  bash "${RC_SETUP_SKILL}/create_entitlement.sh" \
    --lookup-key "$ENTITLEMENT_KEY" \
    --display-name "$ENTITLEMENT_NAME" \
    --attach-products "$product_ids" \
    $DRY_RUN_FLAG || true

  # Offering / Package
  offering_count=$(jq '.revenuecat.offerings | length' "$CONFIG")
  for ((oi=0; oi<offering_count; oi++)); do
    offering_key=$(jq -r ".revenuecat.offerings[$oi].lookup_key" "$CONFIG")
    offering_name=$(jq -r ".revenuecat.offerings[$oi].display_name" "$CONFIG")
    printf '\n# RC Offering: %s\n' "$offering_key"
    bash "${RC_SETUP_SKILL}/create_offering.sh" --lookup-key "$offering_key" --display-name "$offering_name" $DRY_RUN_FLAG || true

    package_count=$(jq ".revenuecat.offerings[$oi].packages | length" "$CONFIG")
    for ((pi=0; pi<package_count; pi++)); do
      pkg_key=$(jq -r ".revenuecat.offerings[$oi].packages[$pi].package_key" "$CONFIG")
      pkg_type=$(jq -r ".revenuecat.offerings[$oi].packages[$pi].type" "$CONFIG")
      price_for_type=$(jq -r --arg t "$pkg_type" '.products[] | select(.type == $t) | .price_jp' "$CONFIG" | head -1)
      pid=$(build_product_id "$PROJECT" "$price_for_type" "$pkg_type")
      printf '\n# RC Package: %s in offering %s → %s\n' "$pkg_key" "$offering_key" "$pid"
      bash "${RC_SETUP_SKILL}/create_package.sh" \
        --offering-key "$offering_key" \
        --package-key "$pkg_key" \
        --product-id "$pid" \
        $DRY_RUN_FLAG || true
    done

    if [[ "$offering_key" == "default" ]]; then
      printf '\n# RC Set current offering: %s\n' "$offering_key"
      bash "${RC_SETUP_SKILL}/set_current_offering.sh" --lookup-key "$offering_key" $DRY_RUN_FLAG || true
    fi
  done
fi

printf '\n=== Done ===\n'
