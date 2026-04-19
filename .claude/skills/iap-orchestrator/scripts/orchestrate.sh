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

: "${CONFIG:?Usage: orchestrate.sh config.json [--dry-run]}"

# Phase 0: 検証
printf '\n=== Phase 0: validate ===\n'
bash "${SCRIPT_DIR}/validate.sh" "$CONFIG"
require_all_env

PROJECT=$(jq -r '.project' "$CONFIG")
BUNDLE_ID=$(jq -r '.app.bundle_id' "$CONFIG")
PACKAGE_NAME=$(jq -r '.app.package_name' "$CONFIG")
DISPLAY_NAME_JA=$(jq -r '.app.display_name["ja"]' "$CONFIG")
DISPLAY_NAME_EN=$(jq -r '.app.display_name["en-US"]' "$CONFIG")
GROUP_REF=$(jq -r '.subscription_group_reference_name // "Premium"' "$CONFIG")
ENTITLEMENT_KEY=$(jq -r '.revenuecat.entitlement_lookup_key' "$CONFIG")
ENTITLEMENT_NAME=$(jq -r '.revenuecat.entitlement_display_name // "Premium"' "$CONFIG")

# Phase 1: ASC
if [[ "$SKIP_ASC" -ne 1 && ( -z "$RUN_PHASE" || "$RUN_PHASE" == "1" ) ]]; then
  printf '\n=== Phase 1a: App Store Connect ===\n'

  printf '\n# Resolving ASC app_id from bundle_id %s\n' "$BUNDLE_ID"
  ASC_APP_ID=$(bash "${ASC_IAP_SKILL}/get_app_id.sh" --bundle-id "$BUNDLE_ID" $DRY_RUN_FLAG)
  printf 'ASC app_id: %s\n' "$ASC_APP_ID"

  printf '\n# Creating ASC subscription group: %s\n' "$GROUP_REF"
  bash "${ASC_IAP_SKILL}/create_subscription_group.sh" --app-id "$ASC_APP_ID" --reference-name "$GROUP_REF" $DRY_RUN_FLAG

  printf '\n[手動] ASC Web で作成された subscription group の id を確認し、ASC_GROUP_ID 環境変数に export して再実行してください。\n'
  printf '       cf. https://appstoreconnect.apple.com/\n'
  printf '       Skip して以降の Subscription 作成も続行する場合は ASC_GROUP_ID をダミー値に設定してください。\n'
  : "${ASC_GROUP_ID:?ASC_GROUP_ID env required after subscription group creation}"

  product_count=$(jq '.products | length' "$CONFIG")
  for ((i=0; i<product_count; i++)); do
    price=$(jq -r ".products[$i].price_jp" "$CONFIG")
    type=$(jq -r ".products[$i].type" "$CONFIG")
    name_ja=$(jq -r ".products[$i].display_name[\"ja\"]" "$CONFIG")
    name_en=$(jq -r ".products[$i].display_name[\"en-US\"]" "$CONFIG")
    desc_ja=$(jq -r ".products[$i].description[\"ja\"] // \"\"" "$CONFIG")
    desc_en=$(jq -r ".products[$i].description[\"en-US\"] // \"\"" "$CONFIG")
    pid=$(build_product_id "$PROJECT" "$price" "$type")

    printf '\n# ASC Subscription: %s\n' "$pid"
    bash "${ASC_IAP_SKILL}/create_subscription.sh" --group-id "$ASC_GROUP_ID" --product-id "$pid" --reference-name "$name_en" $DRY_RUN_FLAG

    printf '[note] subscription_id を取得して set_localization / set_prices / upload_review_screenshot を実行する場合は手動でつないでください\n'
  done
fi

# Phase 1: Play
if [[ "$SKIP_PLAY" -ne 1 && ( -z "$RUN_PHASE" || "$RUN_PHASE" == "1" ) ]]; then
  printf '\n=== Phase 1b: Google Play ===\n'
  product_count=$(jq '.products | length' "$CONFIG")
  for ((i=0; i<product_count; i++)); do
    price=$(jq -r ".products[$i].price_jp" "$CONFIG")
    type=$(jq -r ".products[$i].type" "$CONFIG")
    name_ja=$(jq -r ".products[$i].display_name[\"ja\"]" "$CONFIG")
    name_en=$(jq -r ".products[$i].display_name[\"en-US\"]" "$CONFIG")
    desc_ja=$(jq -r ".products[$i].description[\"ja\"] // \"\"" "$CONFIG")
    desc_en=$(jq -r ".products[$i].description[\"en-US\"] // \"\"" "$CONFIG")
    pid=$(build_product_id "$PROJECT" "$price" "$type")
    bpid="$type"

    printf '\n# Play Subscription: %s\n' "$pid"
    bash "${PLAY_IAP_SKILL}/create_subscription.sh" \
      --package-name "$PACKAGE_NAME" \
      --product-id "$pid" \
      --display-name-ja "$name_ja" \
      --display-name-en "$name_en" \
      --description-ja "$desc_ja" \
      --description-en "$desc_en" \
      $DRY_RUN_FLAG

    printf '\n# Play Base Plan: %s/%s\n' "$pid" "$bpid"
    bash "${PLAY_IAP_SKILL}/create_base_plan.sh" \
      --package-name "$PACKAGE_NAME" \
      --product-id "$pid" \
      --base-plan-id "$bpid" \
      --price-jp "$price" \
      $DRY_RUN_FLAG

    printf '\n# Play Activate: %s/%s\n' "$pid" "$bpid"
    bash "${PLAY_IAP_SKILL}/activate_base_plan.sh" \
      --package-name "$PACKAGE_NAME" \
      --product-id "$pid" \
      --base-plan-id "$bpid" \
      $DRY_RUN_FLAG
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
  bash "${RC_SETUP_SKILL}/create_app.sh" --type app_store --bundle-id "$BUNDLE_ID" --name "$DISPLAY_NAME_EN (iOS)" $DRY_RUN_FLAG

  printf '\n# RC App: play_store\n'
  bash "${RC_SETUP_SKILL}/create_app.sh" --type play_store --package-name "$PACKAGE_NAME" --name "$DISPLAY_NAME_EN (Android)" $DRY_RUN_FLAG

  printf '\n[手動] RC Dashboard で iOS/Android App の app_id を取得し、RC_IOS_APP_ID / RC_ANDROID_APP_ID 環境変数を export してください\n'
  : "${RC_IOS_APP_ID:?RC_IOS_APP_ID env required}"
  : "${RC_ANDROID_APP_ID:?RC_ANDROID_APP_ID env required}"

  # Product ID リスト
  product_ids=$(list_product_ids "$CONFIG" | tr '\n' ',' | sed 's/,$//')

  printf '\n# RC Products (iOS): %s\n' "$product_ids"
  bash "${RC_SETUP_SKILL}/create_products.sh" --app-id "$RC_IOS_APP_ID" --product-ids "$product_ids" $DRY_RUN_FLAG

  printf '\n# RC Products (Android): %s\n' "$product_ids"
  bash "${RC_SETUP_SKILL}/create_products.sh" --app-id "$RC_ANDROID_APP_ID" --product-ids "$product_ids" $DRY_RUN_FLAG

  printf '\n# RC Entitlement: %s\n' "$ENTITLEMENT_KEY"
  bash "${RC_SETUP_SKILL}/create_entitlement.sh" \
    --lookup-key "$ENTITLEMENT_KEY" \
    --display-name "$ENTITLEMENT_NAME" \
    --attach-products "$product_ids" \
    $DRY_RUN_FLAG

  # Offering / Package
  offering_count=$(jq '.revenuecat.offerings | length' "$CONFIG")
  for ((oi=0; oi<offering_count; oi++)); do
    offering_key=$(jq -r ".revenuecat.offerings[$oi].lookup_key" "$CONFIG")
    offering_name=$(jq -r ".revenuecat.offerings[$oi].display_name" "$CONFIG")
    printf '\n# RC Offering: %s\n' "$offering_key"
    bash "${RC_SETUP_SKILL}/create_offering.sh" --lookup-key "$offering_key" --display-name "$offering_name" $DRY_RUN_FLAG

    package_count=$(jq ".revenuecat.offerings[$oi].packages | length" "$CONFIG")
    for ((pi=0; pi<package_count; pi++)); do
      pkg_key=$(jq -r ".revenuecat.offerings[$oi].packages[$pi].package_key" "$CONFIG")
      pkg_type=$(jq -r ".revenuecat.offerings[$oi].packages[$pi].type" "$CONFIG")
      # type に対応する price_jp を取得して product ID を組み立て
      price_for_type=$(jq -r --arg t "$pkg_type" '.products[] | select(.type == $t) | .price_jp' "$CONFIG" | head -1)
      pid=$(build_product_id "$PROJECT" "$price_for_type" "$pkg_type")
      printf '\n# RC Package: %s in offering %s → %s\n' "$pkg_key" "$offering_key" "$pid"
      bash "${RC_SETUP_SKILL}/create_package.sh" \
        --offering-key "$offering_key" \
        --package-key "$pkg_key" \
        --product-id "$pid" \
        $DRY_RUN_FLAG
    done

    if [[ "$offering_key" == "default" ]]; then
      printf '\n# RC Set current offering: %s\n' "$offering_key"
      bash "${RC_SETUP_SKILL}/set_current_offering.sh" --lookup-key "$offering_key" $DRY_RUN_FLAG
    fi
  done
fi

printf '\n=== Done ===\n'
