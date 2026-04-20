# 全手動チェックポイント統合

各依存スキルが手動を要する箇所を一覧化。Skill 経由で自動化できない / Web UI が必須の項目。

## App Store Connect 関連
1. **API Key (.p8) 発行と base64 エンコード** → 環境変数 `ASC_KEY_P8_BASE64`
2. **Sandbox Tester の作成・削除** (App Store Connect Web で実施)
3. **初回 Subscription はバイナリと同時に Web から提出が必須** ← 最重要
4. **Sandbox 反映に最大 1 時間遅延**

## Google Play Console 関連
1. **アプリ (package name) の Play Console 初回作成**
2. **Service Account の Play Console 初回招待** (作成後の権限変更は API で可能)
3. **Internal testing track への初回 AAB アップロード** (これをやらないと Monetize メニューが使えない)
4. **RTDN の Topic 名登録** (Cloud Pub/Sub Topic 作成は API 化可能、Play Console 側登録は UI 必須)
5. **個別 email の License Tester 追加** (Google Group 経由なら API 可能)
6. **Data Safety フォーム**
7. **2026 から Closed Testing で 12 名以上が 14 日間アクティブ要件**

## RevenueCat 関連
1. **Project 自体の作成** (REST API には作成エンドポイントなし、Dashboard 必須)
2. **Google Play Service Account JSON のアップロード** (`play_store` 型 App は API 作成可能だが JSON は Dashboard 必須)
3. **App Store Connect API Key (.p8) のアップロード** (API でも可能だが運用上 Dashboard 推奨)
4. **OAuth Client 登録** (本 Skill 群では Secret Key を使うので不要)

## 推奨実施順
```
[事前準備（人間）]
1. ASC: Bundle ID 登録、API Key 発行
2. Play: package name 作成、AAB 1 回 Internal track にアップロード、SA 招待
3. RC: Project 作成、SA JSON Dashboard アップロード

[Skill 実行]
4. iap-orchestrator orchestrate config.json

[Skill 完了後]
5. ASC Web で初回バイナリ + Subscription を一緒に提出
6. Sandbox / License Tester で動作確認
```
