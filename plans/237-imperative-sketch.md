# Skill 更新: revenuecat-setup に Test Store product Base price 必須を反映

## Context

### きっかけ
Issue #237 (Maestro `clearState=true + clearKeychain=true` で `Purchases.getOfferings()` が `CONFIGURATION_ERROR(23)` を返す) の根本原因調査の結果、**Test Store product に Base price (currency / 価格) が未設定**だったことが判明した。
- `/v1/.../offerings` は package 一覧を返す（`platform_product_identifier` 入り）
- `/rcbilling/v1/.../products?id=shoppinglist_500yen_1month&...` は `{"product_details":[]}` を返却
- 結果 SDK が `OfferingsManager.Error error 1` を発生させ Flutter 側に `PlatformException(23, CONFIGURATION_ERROR)` として透過

ユーザーが本リポジトリの `.claude/skills/revenuecat-setup` で Test Store products を作成した際、price 設定が必要なことを知らなかったため発生した。

### 発見したこと
- RC v2 OpenAPI YAML (`https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml`) を全文確認
- `POST /v2/projects/{pid}/products` (create-product, line 3692-) の requestBody schema に `price` / `currency` フィールド **なし** (`store_identifier`, `app_id`, `type`, `display_name`, `subscription`, `title` のみ)
- `POST /v2/projects/{pid}/products/{prod_id}` (update-product, line 3216-) の requestBody は `display_name` のみ
- `POST /v2/projects/{pid}/products/{prod_id}/create_in_store` (line 3493-) は **App Store 向け** push であり Test Store 用ではない、価格は ASC 側に渡される
- 結論: **REST API v2 で Test Store product の Base price を設定する手段は存在しない**。Dashboard 専用操作

### 期待するアウトカム
- 本リポジトリの `.claude/skills/revenuecat-setup` を更新し、`create_products.sh --app-type test_store` 実行時に Dashboard で Base price を設定するリマインダーを出すようにする
- `SKILL.md` の「できないこと」と「動作確認」に Base price 必須を明記
- `references/manual-steps.md` に Issue #237 で確認したメカニズム + 設定手順 + curl 検証コマンドを追加
- 将来同じ罠を踏まないよう SSOT で記録

### スコープ外
- Issue #237 本体の追従（base price 設定後の Maestro 再実行・14 flow 一括・ADR 0010 追記）は別タスク
- `~/.claude/skills/` に同名 skill が無いことの整合性検討（本リポジトリ専用の skill としてそのまま運用継続）
- iap-orchestrator, app-store-connect-iap 等の他関連 skill への波及

---

## 変更対象ファイル

### 1. `.claude/skills/revenuecat-setup/scripts/create_products.sh`

**変更ポイント**: Test Store product 作成成功直後に Dashboard URL を含む price 設定リマインダーを stderr に出力する。

**変更後の該当箇所** (現行 line 96-107 周辺、`rc_product_id` 取得後):

```bash
  rc_product_id=$(printf '%s' "$response" | jq -r '.id // empty')
  if [[ -z "$rc_product_id" ]]; then
    if printf '%s' "$response" | jq -e '.type == "resource_already_exists" or .code == 7263' >/dev/null 2>&1; then
      printf '  → already exists, skipping\n'
      continue
    fi
    printf 'Failed to create product %s. Response: %s\n' "$product_id" "$response" >&2
    exit 1
  fi
  printf '  → created: id=%s\n' "$rc_product_id"

  # Test Store product は Base price を Dashboard で設定しないと
  # /rcbilling/.../products が空配列を返し、SDK が CONFIGURATION_ERROR(23) になる (Issue #237)。
  # API v2 では price 設定エンドポイントが存在しないため Dashboard 必須。
  if [[ "$APP_TYPE" == "test_store" ]]; then
    printf '  ⚠️  Set Base price in Dashboard (REQUIRED, not supported via API):\n' >&2
    printf '      https://app.revenuecat.com/projects/%s/products/%s\n' \
      "${REVENUECAT_PROJECT_ID}" "$rc_product_id" >&2
    printf '      Detail: references/manual-steps.md section 9\n' >&2
  fi
done
```

整合性: 既存の `printf` 出力スタイル（`→` プレフィックス、stderr 直書き）を踏襲。`already exists` ブランチでも同じ警告を出すべきか迷うが、既に作成済みなら price も設定済みである可能性が高いので「新規作成時のみ」に絞る（誤検知より見逃しの方が今回の失敗パターンに合致）。

trade-off: 既に price 未設定で作成済みのケース（今回のユーザーがハマったケース）には警告が出ない。これは `manual-steps.md` の「未設定の検出方法（curl 検証）」を別途明記することでカバーする。

### 2. `.claude/skills/revenuecat-setup/SKILL.md`

**変更ポイント A**: 「できないこと（手動が必要）」セクション (line 32-37) に Test Store product Base price を追記。

```markdown
## できないこと（手動が必要）
詳細は `references/manual-steps.md` を参照。
- **Project 自体の作成**: Dashboard で 1 回だけ作成 (https://app.revenuecat.com)
- **Google Play Service Account JSON のアップロード**: `play_store` 型の App を API で作っても、JSON は別途 Dashboard アップロード必要
- **App Store Connect の API Key (.p8) を Dashboard 経由でアップロードする方が楽**: API でも `subscription_private_key` フィールドに渡せるが、運用上は Dashboard 推奨
- **Test Store App の作成**: REST API v2 の `type` enum に `test_store` が含まれないため Dashboard 専用。開発時に実ストア登録なしで IAP フローをテストしたいときに Dashboard で作成 → `lookup_test_store_app.sh` で API 経由 ID 解決 → `create_products.sh --app-type test_store` で Products 登録
- **Test Store Product の Base price 設定**: REST API v2 の Product create / update / create_in_store のいずれにも `price` / `currency` フィールドが無いため Dashboard 専用。**未設定だと SDK 側で `CONFIGURATION_ERROR(23)` を踏み Offerings 取得失敗**（Issue #237 で確認済み）
```

**変更ポイント B**: 「使い方 → Test Store」例 (line 87-95) の直後に Base price 設定リンクを追加。

```markdown
# Test Store (開発時のみ、Dashboard で作成済みが前提)
# 事前調査
bash ~/.claude/skills/revenuecat-setup/scripts/inspect_test_store.sh
# Test Store app_id の解決
bash ~/.claude/skills/revenuecat-setup/scripts/lookup_test_store_app.sh
# Test Store Products 登録
bash ~/.claude/skills/revenuecat-setup/scripts/create_products.sh \
  --app-id app_xxx --app-type test_store \
  --product-ids shoppinglist_480yen_1month,shoppinglist_2580yen_6month,shoppinglist_4800yen_1year
# ⚠️ 上記の後、Dashboard で各 Test Store product に Base price を必ず設定する
#    詳細: references/manual-steps.md section 9
```

**変更ポイント C**: 「動作確認」セクション (line 105-111) に Base price 設定確認ステップを追加。

```markdown
## 動作確認
1. Project を https://app.revenuecat.com で作成（手動、1 回のみ）
2. `REVENUECAT_V2_SECRET_KEY` と `REVENUECAT_PROJECT_ID` を export
3. `create_app.sh` で App 作成 → Dashboard で確認
4. `create_entitlement.sh` で `lookup_key=Premium` の Entitlement を作成
5. `grant_promotional.sh` で自分の Firebase UID にプレミアムを付与
6. アプリ側で `customerInfoProvider` の `isPremium=true` になることを確認
7. (Test Store のみ) `create_products.sh --app-type test_store` 後、Dashboard で各 product に Base price を設定し、curl で `/rcbilling/v1/subscribers/dummy/products?id=...` が `product_details` 非空を返すことを確認（`references/manual-steps.md` section 9）
```

整合性: 既存の番号付きステップに 7. を追加するだけで、他の段は無変更。Test Store を使わないプロジェクトでは無視できるよう「(Test Store のみ)」のラベル付き。

### 3. `.claude/skills/revenuecat-setup/references/manual-steps.md`

**変更ポイント**: 末尾 (line 104) に新セクション「9. Test Store Product の Base price 設定」を追加。

```markdown
## 9. Test Store Product の Base price 設定（必須・Dashboard のみ）

**いつ**: `create_products.sh --app-type test_store` で Test Store product を作成した直後。

**なぜ手動**: REST API v2 の以下のいずれの endpoint にも `price` / `currency` フィールドが存在しない（OpenAPI YAML 全文確認済み）:
- `POST /v2/projects/{pid}/products` (create-product)
- `POST /v2/projects/{pid}/products/{prod_id}` (update-product, `display_name` のみ更新可)
- `POST /v2/projects/{pid}/products/{prod_id}/create_in_store` (App Store 向け push)

つまり Base price は Dashboard でしか設定できない。

**症状（未設定時）**: SDK が CONFIGURATION_ERROR(23) を返し Paywall が表示できない。
- `GET /v1/.../offerings` は package 一覧を返す（`platform_product_identifier` 入り、正常）
- `GET /rcbilling/v1/subscribers/{uid}/products?id=shoppinglist_500yen_1month&...` は `{"product_details":[]}` を返す（**price 未設定の product は除外される**）
- iOS SDK は `OfferingsManager.Error error 1` を発生 → Flutter 側に `PlatformException(code:23, CONFIGURATION_ERROR)` として透過
- Issue #237 で再現と root cause 特定済み

**手順**:
1. https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/products にアクセス
2. 対象 Test Store product (例: `shoppinglist_500yen_1month`) をクリック
3. **Base price** セクションの **+ Add currency** で通貨と金額を追加
   - 日本円なら `JPY` / `500` 等、product_id 末尾の `_500yen_` から自然に読み取れる値を入れる
4. 全 Test Store product に対して繰り返す
5. 設定後、curl で確認:
   ```bash
   curl -H "Authorization: Bearer ${REVENUECAT_TEST_STORE_API_KEY}" \
     "https://api.revenuecat.com/rcbilling/v1/subscribers/dummy/products?id=shoppinglist_500yen_1month"
   # → product_details が非空配列で返れば OK
   # → product_details: [] のままなら設定が反映されていない（数秒〜1分待って再試行）
   ```

**参考**:
- OpenAPI YAML (`POST /products` schema 確認用): https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml
- Test Store overview: https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
- shoppinglist Issue #237: 本症状の Maestro E2E 経由再現と log stream 解析
```

整合性: 既存の section 1〜8 と同じ「**いつ / なぜ手動 / 手順 / 参考**」構造に合わせる。`references/links.md` に load される URL は変更しない（重複を避ける）。

trade-off: 「price」の URL を Dashboard で確実に開ける形で書くために `${REVENUECAT_PROJECT_ID}` 変数展開記法を使う。これはシェルで export されている前提で、未 export 時は人間が手で URL を組み立てる。SKILL.md 全体で同じ慣習なので統一性 OK。

---

## Critical Files
- `/Users/bannzai/ghq/github.com/bannzai/shoppinglist/.claude/skills/revenuecat-setup/scripts/create_products.sh`
- `/Users/bannzai/ghq/github.com/bannzai/shoppinglist/.claude/skills/revenuecat-setup/SKILL.md`
- `/Users/bannzai/ghq/github.com/bannzai/shoppinglist/.claude/skills/revenuecat-setup/references/manual-steps.md`

## 検証方法

### 1. dry-run でリマインダー出力確認
```bash
bash /Users/bannzai/ghq/github.com/bannzai/shoppinglist/.claude/skills/revenuecat-setup/scripts/create_products.sh \
  --app-id app_xxx --app-type test_store \
  --product-ids shoppinglist_500yen_1month --dry-run
```
→ stderr に `[DRY RUN] curl ...` が出ること（dry-run では rc_product_id が無いので Base price 警告は出ない）

### 2. 実実行リマインダー確認（既に作成済みなら再現せず）
- 新規 Test Store product を 1 つ作って `--app-type test_store` 経由で登録
- stderr に `⚠️  Set Base price in Dashboard...` と Dashboard URL が出力されることを確認
- 既存 product は `→ already exists, skipping` のまま（trade-off で意図通り）

### 3. SKILL.md / manual-steps.md レンダリング確認
- `cat SKILL.md` / `cat references/manual-steps.md` でセクション追加が崩れていないこと
- markdown linter (任意) でリンク切れ・見出しレベル整合を確認

### 4. RC v2 API の price field 不在を再確認（追加調査時のみ）
```bash
curl -s https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml \
  | grep -nE '/products' \
  | head -20
# create-product / update-product / create_in_store の各 schema に price / currency が無いことを確認
```

### 5. Issue #237 の現状解決リンクを後追い
本タスクのスコープ外だが、Dashboard で実際に Base price を設定した後:
```bash
curl -H "Authorization: Bearer test_xxx" \
  "https://api.revenuecat.com/rcbilling/v1/subscribers/dummy/products?id=shoppinglist_500yen_1month"
# product_details 非空が返れば skill ドキュメントの正当性が裏付けられる
```

---

## Out-of-scope（現時点で別管理）

以下は本タスクで触らないが、関連タスクとしてユーザーに引き継ぐ:
- shoppinglist リポジトリの purchases_flutter / RC iOS pod 更新（10.0.1 → 9.16.1 ロールバック済み、`pubspec.yaml` / `ios/Podfile.lock` 編集済み）
- `~/.claude/skills/maestro-flutter/scripts/build-and-install.sh` の `--dart-define` 伝播追加（1-A、編集済み）
- `lib/utils/purchase/purchase.dart` の retry + barrier (1-B/1-C、編集済み + build_runner 実行済み)
- `lib/features/paywall/paywall_page.dart` の retry UI 追加 (1-D、編集済み)
- ADR 0010 の Follow-up 更新（未着手、Base price 設定後に Maestro 14 flow が通ってから記載が望ましい）

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- 該当なし（lib/ への新規変更は本タスクでは行わない）

### Firebase（firebase/ に変更がある場合）
- 該当なし

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
