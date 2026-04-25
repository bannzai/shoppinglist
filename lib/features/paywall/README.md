# ペイウォール (Paywall)

## 概要
プレミアムプランへのアップグレード画面。現在 RevenueCat Offering から monthly / annual / lifetime の 3 Package を提示し、購入フローを起動する。

## 導線
- 設定画面の「プレミアム会員」ListTile（未加入時のみ `onTap` 有効）
- 各 premium gate の SnackBar action「アップグレード」
  - テーマカラー設定 / 位置情報リマインダー / リストエクスポート / グループ作成上限 /
    アイテム写真添付 / 買い物場所順 / AI 画像・URL 認識上限 / リスト作成・複製上限

## 機能
- monthly / annual / lifetime の 3 Package を `Card` + `ListTile` で表示
- 各購入ボタンに `Key('paywall_subscribe_{packageType}')` を付与（Maestro E2E から id 指定で tap するため）
- 購入実行は `ref.read(purchaseProvider).call(package)` に委譲
  - 成功: "購入ありがとうございました" SnackBar → 画面を pop
  - 失敗: 例外の `toString()` を SnackBar で表示（加工なし）

## Test Store 挙動（Debug ビルド時）
`--dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx` を設定した debug ビルドでは、
購入ボタンタップ時に RC Test Store の mock purchase modal が表示される（実課金なし）。
Release ビルドでは本番 Store を使用する。詳細は PR #233 と `lib/utils/purchase/purchase.dart` の `initializePurchase()` を参照。

## 関連ファイル
- `lib/utils/purchase/purchase.dart` - 購入ロジック（`Purchase` class / `purchaseProvider` / `monthlyPackageProvider` 等）
- `lib/features/paywall/paywall_page.dart` - PaywallPage 本体
- `lib/features/paywall/paywall.dart` - `showPaywall({required context})` 遷移関数
- `maestro/flows/shared/mock_purchase.yaml` - E2E 用購入サブフロー
