# Google Play Console 手動操作が必要なタイミング

## 1. アプリ (package name) の新規作成

**いつ**: 新しいアプリを Play Console に登録するとき。

**なぜ**: `applications` リソースは `dataSafety` 宣言用のみで `create` メソッドなし。

**手順**:
1. Play Console → **Home → Create app**
2. 言語、アプリ名、無料/有料、宣言（広告 / 子供向け等）を入力
3. **package name は作成後変更不可・削除不可・再利用不可**
4. 作成後、Internal testing トラックに 1 度 AAB をアップロード（これをやらないと Monetize メニューが使えない）

## 2. Service Account の作成と Play Console 招待

**いつ**: Skill 初回利用時。

**手順**:
1. Google Cloud Console → IAM & Admin → **Service Accounts** で作成
2. **JSON キーを発行・ダウンロード**
3. base64 エンコードして export:
   ```bash
   GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64=$(base64 -i service-account.json)
   ```
4. **Play Console → Users and Permissions → Invite new users** で Service Account の email を招待（**この初回招待は UI 必須**）
5. 権限を割り当て:
   - 「Manage orders and subscriptions」
   - 「View financial data, orders, and cancellation survey responses」（任意）
   - アプリ単位 / 全体権限を選択

## 3. Real-time Developer Notifications (RTDN) の設定

**いつ**: RC 連携 or 自前で購入イベントを受けたいとき。

**Pub/Sub 側**:
1. Cloud Console で **Pub/Sub Topic を作成** (`projects/<gcp-project>/topics/<topic-name>`)
2. Topic に **`google-play-developer-notifications@system.gserviceaccount.com` の Pub/Sub Publisher 権限**を付与
3. ここまでは IAM API で自動化可能

**Play Console 側 (UI 必須)**:
1. Play Console → Monetize → **Monetization setup → Real-time developer notifications**
2. Topic 名を入力して有効化

## 4. 個別 email の License Tester 追加

**API は Google Groups のみ受付**。個別 email を直接登録したい場合は:
- Play Console → Setup → **License testing** で UI 操作、または
- Google Group を作成して email を group に追加し、Skill から `googleGroups[]` 経由で API 登録

## 5. Data Safety フォーム

**いつ**: 初回 production 提出時。

**API**: `applications.dataSafety` リソースは存在するが、本 Skill では未実装。Play Console UI で入力推奨。

## 6. ストア掲載情報 (Store listing)

API で `edits.listings` (タイトル / 説明 / 短い説明) と `edits.images` (スクリーンショット / アイコン) は登録可能。
ただし **コンテンツレーティング・ターゲット年齢層**などは UI 入力が必要な項目あり。

## 7. Closed Testing 14 日 / 12 名要件 (2026 ポリシー変更)

**いつ**: 2026 から本番公開前。

**要件**: closed testing で **12 名以上が 14 日間アクティブに利用** する必要あり。

**手順**: 
- Play Console → Testing → Closed testing でテスター email リストを管理
- API でトラック操作は可能だが、**テスター集めは別途必要**（Skill では自動化不可）

## 8. Edits の楽観ロック (409 Conflict)

**いつ**: Skill が `upload_aab.sh` 実行中に他のセッションが edit を作成したとき。

**対応**: Skill 内で `cleanup_edits.sh` を実行、または **5 秒待ってリトライ**。
