# App Store Connect 手動操作が必要なタイミング

## 1. **初回 Subscription はバイナリ提出と一緒に Web 経由で提出（最重要）**

**いつ**: 新規アプリで初めて IAP / Subscription を提出するとき。

**なぜ**: Apple 公式「Managing auto-renewable subscriptions」「Managing in-app purchases」両方に明記:
> "The first in-app purchase must be submitted with an app binary submission through appstoreconnect.apple.com."

**手順**:
1. Skill で Subscription メタデータを作成（`create_subscription.sh` 等）
2. Xcode で IPA / バイナリをビルド・アーカイブし、`xcrun altool` または Xcode Organizer から App Store Connect にアップロード
3. App Store Connect Web → アプリのバージョンページ
4. **「In-App Purchases or Subscriptions」セクション** で対象 IAP/サブスクをチェック
5. バイナリと一緒に審査提出

→ Skill の `submit_subscription.sh` (= `POST /v1/subscriptionSubmissions`) は **2 回目以降のサブスク追加でしか動作しない**

## 2. API Key の発行

**いつ**: Skill 初回利用時。

**手順**:
1. App Store Connect → Users and Access → **Integrations** → **App Store Connect API**
2. **Generate API Key** を押下（最低 App Manager 以上のロールを選択）
3. 生成された **`.p8` ファイルを必ずダウンロード**（一度しか取得できない）
4. **Issuer ID** と **Key ID** を控える
5. base64 エンコードして export:
   ```bash
   ASC_KEY_P8_BASE64=$(base64 -i AuthKey_XXX.p8)
   ASC_KEY_ID=XXXXXXXXXX
   ASC_ISSUER_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   ```

## 3. Sandbox Tester の作成・削除

**いつ**: Sandbox 環境で実機購入テストしたいとき。

**なぜ**: API は `GET /v2/sandboxTesters` / `PATCH` / `purchase history clear` のみで、**`POST` (作成) と `DELETE` が存在しない**。

**手順**:
1. App Store Connect → **Users and Access** → **Sandbox Testers**
2. **+ ボタン** で Apple ID を作成（実在しないメールアドレスでも可）
3. 実機 Settings → App Store → **Sandbox Account** にサインイン

## 4. Sandbox 反映の遅延

**いつ**: API でメタデータを変更した直後。

**注意**: API 成功後も sandbox 環境への反映に **最大 1 時間** かかる（公式注意書き）。即時テストは不可。

## 5. Review Screenshot 画像の準備

**いつ**: 提出前。

**Skill では `templates/paywall.png` のテンプレを使い回す**（運用上問題なし）。
ただし、**初回リリース時にテンプレ画像が `templates/` に置かれていなければ Skill が動かない** のでユーザーが事前配置必須。

**画像要件**:
- 機能リスト（プレミアム機能の概要）
- 価格表示
- Subscribe / 購入ボタン
- 推奨サイズ: 6.5" iPhone (1242 × 2688) または 6.7" (1290 × 2796)

## 6. App Store Connect Web での提出後の状態確認

**いつ**: Skill で `submit_subscription.sh` を実行した後。

**自動 polling 推奨**: `GET /v1/subscriptions/{id}` で `state` を polling。`MISSING_METADATA` → `READY_TO_SUBMIT` → `WAITING_FOR_REVIEW` → `IN_REVIEW` → `APPROVED` の遷移を追う。

## 7. 価格 territory ループの長時間実行

**いつ**: 全 territory に価格を設定するとき。

**注意**: 175 territory × 3 サブスク = 525 リクエスト/初期セットアップ。`set_prices.sh` は 200ms スペーシングで送るので約 **2 分** かかる。レート制限 3500 req/hour 内には収まる。
