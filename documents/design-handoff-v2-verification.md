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
| 1 | OnboardingPage Slide 1 | #262, #264 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light 実画像比較 PASS。Dark は WDA flakiness で要再撮 |
| 2 | OnboardingPage Slide 2 | #262, #264 | 🟡 | 🟡 | Maestro flow が Slide 1 のみ撮影。Slide 2/3 は手動 swipe で別途取得要 |
| 3 | OnboardingPage Slide 3 | #262, #264 | 🟡 | 🟡 | 同上 |
| 4 | AuthPage | #262, #264 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light 通常状態 PASS。loading/error は別途検証要 |
| 5 | HomePage (paper surface) | #264 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light PASS |
| 6 | ShoppingListPage | #265 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light PASS。Preview wrapper 経由 |
| 7 | ShoppingListItemFilterPage | #266 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`06-filter`) PASS |
| 8 | ShoppingListSettingPage | #266 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`05-list-setting`) PASS |
| 9 | GroupListPage | #267 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`07-grp-list`) PASS |
| 10 | GroupCreatePage | #267 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`08-grp-create`) PASS |
| 11 | GroupSettingPage | #267 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`09-grp-set`) PASS |
| 12 | GroupInvitationPage | #267 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`10-grp-accept`) PASS |
| 13 | GroupCategoryPage | #268 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`11-cat-list`) PASS |
| 14 | ShoppingLocationPage | #268 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`13-loc-list`) PASS |
| 15 | SettingPage | #269 | ✅ | 🟡 | 2026-05-17: iOS Light vs Web Light (`15-settings-free`) PASS |
| 16 | PaywallPage | #269 | 🟡 | 🟡 | iOS Preview に直接 entry なし、SettingPage 経由で確認可。手動目視要 |
| 17 | ThemeColorSelectionPage | #269 | 🟡 | 🟡 | iOS Preview に直接 entry なし、SettingPage 経由で確認可。手動目視要 |
| W-iOS | iOS Widget | #270 | ⏸️ | ⏸️ | PR-8 残作業 (Swift dark mode)。Widget は Preview entry 範囲外 |
| W-Android | Android Widget | #270 | ✅ | ✅ | PR-8 で layout-night 追加 |
| Pseudo-1 | AIReviewSheet | #265 follow-up | ✅ | 🟡 | 2026-05-17: iOS Light 取得済み (Web SSOT 対応 artboard なし) |
| Pseudo-2 | SignOutDialog | #269 follow-up | ✅ | 🟡 | 2026-05-17: iOS Light 取得済み (Web SSOT 対応 artboard なし) |
| Pseudo-3 | GroupInvitationVerifying | #267 follow-up | ✅ | 🟡 | 2026-05-17: iOS Light 取得済み (Web SSOT 対応 artboard なし) |

凡例:
- ✅ 実装+ローカル検証完了
- 🟡 実装完了、3 環境スクショ比較は手動目視 (Maestro flow は CI に組み込み済み)
- ⏸️ 実装途中（部分マージ済 / 次セッション継続）

## 本セッションの追加実装

`tmp/goal-prompt.md` 完遂のため、各 issue の残作業を補完 PR で追加実装した。

| issue | 追加 PR | 内容 |
|---|---|---|
| #265 | #282 | AI review sheet 新規 + 長押し context menu + maestro flows |
| #266 | #283 | Functions 側 autoNotifyEnabled AND 条件 + maestro flow |
| #267 | #284 | 作成後招待 dialog + maestro flow (CreateGroup 戻り値を String に拡張) |
| #268 | #285 | LocationPicker address 永続化 + maestro flow |
| #269 | #286 | サインアウト dialog の AppDialogShell 化 + maestro flow |
| #270 | #287 | iOS Widget dark mode 明示化 (@Environment(\.colorScheme)) + maestro flow |
| #271 | #288 (本 PR) | design_v2_dark_mode maestro flow + 本ドキュメント更新 |

## 補完 PR で扱わなかった残作業 (将来 issue で扱う)

- 設定画面の全 ListTile を AppCell に置き換える page 全面再構成 (#269 のフォロー)
- group_setting/page.dart 1000 行のカテゴリ/場所インライン管理を外す (#267 のフォロー)
- group_invitation/page.dart の verifying 状態色 (#267 のフォロー、該当 state 未実装)
- preview_flows 13 → 17 画面拡張 (#271 のフォロー、preview entry 拡張要)
- 3 環境 (iOS Simulator / Android Emulator / agent-browser) スクショ目視比較 (#271 のフォロー、手動 QA 範囲)

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
