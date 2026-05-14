# design v2 完全準拠 検証マトリクス

Issue #261 メタプランに基づく design_handoff_shoppinglist v2 完全準拠 (PR-0 〜 PR-9) の検証記録。

## 検証 3 環境

`plans/261-warm-engelbart.md` の運用ルール 3 で定義される 3 環境で同じ画面・同じテーマを比較する。

| 環境 | 用途 | スクショ取得方法 |
|---|---|---|
| iOS Simulator iPhone 16 Plus | 実機 iOS 表現 | `sim-manager` + `verify-ui-mobile-mcp` or Maestro |
| Android Emulator | 実機 Android 表現 | Maestro / Android Studio |
| Web HTML preview | SSOT 仕様 | `agent-browser` で `design_handoff_shoppinglist/preview/買い物リスト UI再設計.html` を開く |

## 17 画面 × Light/Dark マトリクス

| # | 画面 | 関連 issue | Light | Dark | 備考 |
|---|---|---|---|---|---|
| 1 | OnboardingPage Slide 1 | #262, #264 | 🟡 | 🟡 | PR-0 で画像、PR-2 で SSOT 文言。実機目視は次セッション |
| 2 | OnboardingPage Slide 2 | #262, #264 | 🟡 | 🟡 | 同上 |
| 3 | OnboardingPage Slide 3 | #262, #264 | 🟡 | 🟡 | 同上 |
| 4 | AuthPage | #262, #264 | 🟡 | 🟡 | PR-2 で SSOT 文言。eyebrow / 規約注記 確認次セッション |
| 5 | HomePage (paper surface) | #264 | 🟡 | 🟡 | PR-2 で `tokens.neutral.paper` 明示済み |
| 6 | ShoppingListPage | #265 | 🟡 | 🟡 | PR-3 (#265) で i-7/i-8 左右スワイプ実装。残作業多数 |
| 7 | ShoppingListItemFilterPage | #266 | ⏸️ | ⏸️ | PR-4 残作業 (hifi 化) |
| 8 | ShoppingListSettingPage | #266 | 🟡 | 🟡 | PR-4 で autoNotifyEnabled Switch 追加 |
| 9 | GroupListPage | #267 | ⏸️ | ⏸️ | PR-5 残作業 |
| 10 | GroupCreatePage | #267 | 🟡 | 🟡 | PR-5 で iconName 6 種選択追加 |
| 11 | GroupSettingPage | #267 | ⏸️ | ⏸️ | PR-5 残作業 (再構成) |
| 12 | GroupInvitationPage | #267 | ⏸️ | ⏸️ | PR-5 残作業 (verifying AppDialogShell) |
| 13 | GroupCategoryPage | #268 | 🟡 | 🟡 | PR-6 で regex 選択肢追加 |
| 14 | ShoppingLocationPage | #268 | ⏸️ | ⏸️ | PR-6 残作業 (address / map PRO gate) |
| 15 | SettingPage | #269 | 🟡 | 🟡 | PR-7 でサインアウト追加 |
| 16 | PaywallPage | #269 | ⏸️ | ⏸️ | PR-7 残作業 (状態確認) |
| 17 | ThemeColorSelectionPage | #269 | ⏸️ | ⏸️ | PR-7 残作業 (props 整理) |
| W-iOS | iOS Widget | #270 | ⏸️ | ⏸️ | PR-8 残作業 (Swift dark mode) |
| W-Android | Android Widget | #270 | ✅ | ✅ | PR-8 で layout-night 追加 |

凡例:
- ✅ 実装+ローカル検証完了
- 🟡 実装完了、3 環境スクショ比較は次セッション継続
- ⏸️ 実装途中（部分マージ済 / 次セッション継続）

## 決定事項 (Web preview と意図的差分)

`plans/261-warm-engelbart.md` 運用ルール 4 参照。以下は PASS 扱い:

- Onboarding 本文: JSX SSOT 採用 (README §7-1 と乖離)
- ThemeColorSelection 色数: 5 色 canonical 固定 (JSX 10 色不採用)
- Auth ゲストリンク: 本番導線なし (debug 匿名のみ)
- 5 accent: shu / matcha / ai / sumi / kuchiba 固定
- ShoppingLocation 地図設定: PRO 限定 (場所名のみ無料)
- Android Widget: AppWidgetProvider + RemoteViews 継続 (Compose 非採用)
- AI アイコン生成タイル: Group / Category 共に非表示
- ItemRow 担当者: 非表示
- 画像素材: PR-0 で生成・同梱したもの (placeholder と意匠差分許容)
- フォント: 実機 `google_fonts` vs Web CSS の差は許容

## 残作業 (issue 単位)

`tmp/goal/skipped.json` 参照。各 issue で部分実装をマージ済み、残りは次セッション継続。

| issue | 残作業の代表 |
|---|---|
| #265 | AI review sheet / 長押し context menu / SnackBar 統一 / maestro flows |
| #266 | Functions 側 autoNotifyEnabled / Filter hifi / maestro flow |
| #267 | 作成後招待画面遷移 / GroupSetting 再構成 / Invitation verifying / maestro flow |
| #268 | LocationPicker address 永続化 / map PRO gate / maestro flow |
| #269 | AppCell/AppDialogShell 再構成 / ThemeColorSelection 整理 / Paywall 状態 / maestro flow |
| #270 | iOS Widget dark mode 明示化 / 5 accent 動作確認 / maestro flow |
| #271 | preview_flows 13 → 17 画面拡張 / design_v2_dark_mode.yaml / 全 17 画面の Light/Dark スクショ比較 |
