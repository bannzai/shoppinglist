#!/bin/bash
#
# .github/workflows/firebase-deploy.yml が使う Workload Identity Federation を GCP 側に用意する。
# GitHub の OIDC トークンを、デプロイ専用 SA github-firebase-deployer@<projectId> の短命な access token に
# 交換できるようにする(Issue #694。手本: bannzai/Alarmify documents/functions-deploy.md)。
#
# 使い方(IAM の変更を含むため owner の認証情報で実行する):
#   bash scripts/setup-github-actions-wif.sh          # dev と prod の両方
#   bash scripts/setup-github-actions-wif.sh dev      # 片方だけ
#
# 冪等: Pool / Provider は存在すれば作らず、Provider の条件は毎回同じ値に更新する。binding の追加は重複しない。

set -euo pipefail

# リポジトリ名の変更で壊れないよう、Provider の条件は名前ではなく ID で絞る。
REPOSITORY_OWNER_ID="10897361"
REPOSITORY_ID="906071405"
POOL_ID="github"
PROVIDER_ID="shoppinglist"

setup() {
  local environment="$1"
  local project_id
  case "$environment" in
    dev) project_id="shoppinglist-dev-b2787" ;;
    prod) project_id="shoppinglist-prod-857bb" ;;
    *) echo "unknown environment: $environment (dev / prod)" >&2; return 1 ;;
  esac
  local project_number
  project_number="$(gcloud projects describe "$project_id" --format='value(projectNumber)')"
  # environment claim は GitHub Environment(dev / prod)を使う job のトークンにだけ付く。
  # dev のトークンで prod の SA を借りられないよう、プロジェクトごとに environment 名で絞る。
  local attribute_condition="assertion.repository_owner_id == '${REPOSITORY_OWNER_ID}' && assertion.repository_id == '${REPOSITORY_ID}' && assertion.environment == '${environment}'"
  local attribute_mapping="google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.repository_owner_id=assertion.repository_owner_id,attribute.environment=assertion.environment"

  echo "== ${environment} (${project_id} / ${project_number})"
  gcloud services enable sts.googleapis.com --project="$project_id"

  if ! gcloud iam workload-identity-pools describe "$POOL_ID" --project="$project_id" --location=global >/dev/null 2>&1; then
    gcloud iam workload-identity-pools create "$POOL_ID" --project="$project_id" --location=global --display-name="GitHub Actions"
  fi

  if gcloud iam workload-identity-pools providers describe "$PROVIDER_ID" --project="$project_id" --location=global --workload-identity-pool="$POOL_ID" >/dev/null 2>&1; then
    gcloud iam workload-identity-pools providers update-oidc "$PROVIDER_ID" --project="$project_id" --location=global --workload-identity-pool="$POOL_ID" \
      --display-name="bannzai/shoppinglist" \
      --issuer-uri="https://token.actions.githubusercontent.com" \
      --attribute-mapping="$attribute_mapping" \
      --attribute-condition="$attribute_condition"
  else
    gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" --project="$project_id" --location=global --workload-identity-pool="$POOL_ID" \
      --display-name="bannzai/shoppinglist" \
      --issuer-uri="https://token.actions.githubusercontent.com" \
      --attribute-mapping="$attribute_mapping" \
      --attribute-condition="$attribute_condition"
  fi

  gcloud iam service-accounts add-iam-policy-binding "github-firebase-deployer@${project_id}.iam.gserviceaccount.com" --project="$project_id" \
    --role=roles/iam.workloadIdentityUser \
    --member="principalSet://iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.repository_id/${REPOSITORY_ID}"
}

if [ $# -eq 0 ]; then
  set -- dev prod
fi
for environment in "$@"; do
  setup "$environment"
done
