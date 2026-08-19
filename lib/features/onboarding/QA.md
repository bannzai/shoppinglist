---
feature: onboarding
verification: mobile-mcp, maestro
last_verified_commit: 8ee973c31d4b8e2d333a459d1bfe8173e03384f7
last_verified_at: 2026-08-19
---

# onboarding QA

オンボーディングは「未認証 かつ hasSeenOnboarding=false」のユーザーにのみ表示される（`lib/features/resolver/auth.dart`）。再現するにはアプリ削除では不十分で（Keychain に認証が残存する）、`clearState: true` + `clearKeychain: true`、または新規シミュレータで未認証状態に戻す必要がある。位置情報機能は `shoppingLocationFeatureEnabled = false` で無効のため、店舗近接通知を訴求するスライド 3 は表示されず、スライドは 2 枚構成になる（`OnboardingPage._slideCount = 2`）。

## 1. 初回起動時の表示

- [x] **スライド 2 枚が表示される**: 1 枚目「家族と作る、買い物リスト」、2 枚目「同じリストを同時に編集」の 2 スライドが表示される。位置情報スライドはフラグ無効のため出ない（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）
- [x] **eyebrow が `01/02` 形式で表示される**: 各スライド上部に `現在番号/総数` を 2 桁ゼロ埋めした mono 表記（例: `01/02`）が accent 色で表示される
- [x] **ドットインジケータが 2 個表示される**: 下部に 2 個のドットが並び、現在ページのドットのみ横長（幅 22）で accent 色になる
- [x] **右上にスキップ、下部に進行ボタンが表示される**: 右上に「スキップ」テキストボタン、最下部に横幅いっぱいの accent ピルボタンが表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スライド 2 枚が表示される**: 1 枚目「家族と作る、買い物リスト」、2 枚目「同じリストを同時に編集」の 2 スライドが表示される。位置情報スライドはフラグ無効のため出ない（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/e38447b2-6f60-430f-beff-f50ade776847.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/ee224cd5-05ba-4e3e-a2af-c013003515f0.png" width="320">

gen-l10n 導入後（UI 文字列の l10n 化）も ja ロケールで文言・改行位置・レイアウトは従来どおり。3 枚目（位置情報）は表示されず 2 枚構成。

</details>

### **eyebrow が `01/02` 形式で表示される**: 各スライド上部に `現在番号/総数` を 2 桁ゼロ埋めした mono 表記（例: `01/02`）が accent 色で表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/e38447b2-6f60-430f-beff-f50ade776847.png" width="320">

</details>

### **ドットインジケータが 2 個表示される**: 下部に 2 個のドットが並び、現在ページのドットのみ横長（幅 22）で accent 色になる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/e38447b2-6f60-430f-beff-f50ade776847.png" width="320">

</details>

### **右上にスキップ、下部に進行ボタンが表示される**: 右上に「スキップ」テキストボタン、最下部に横幅いっぱいの accent ピルボタンが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/e38447b2-6f60-430f-beff-f50ade776847.png" width="320">

</details>

</details>

---

## 2. スライド操作

- [x] **「次へ」ボタンで次スライドへ進む**: 最終スライド以外ではボタンラベルが「次へ」で、タップすると 240ms のアニメーションで次のページへ遷移する
- [x] **最終スライドではボタンが「はじめる」になる**: 最後のスライド（2 枚目）ではボタンラベルが「はじめる」に変わる
- [x] **左スワイプでスライドを移動できる**: PageView を左スワイプすると次スライドへ移動し、ドットインジケータと eyebrow が追従する（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「次へ」ボタンで次スライドへ進む**: 最終スライド以外ではボタンラベルが「次へ」で、タップすると 240ms のアニメーションで次のページへ遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/754d3fdc-19bf-4ca4-8b57-7c8215e0f9ba.png" width="320">

1 枚目（01/02・ボタン「次へ」）でボタンをタップした結果、2 枚目（02/02）へ遷移した。

</details>

### **最終スライドではボタンが「はじめる」になる**: 最後のスライド（2 枚目）ではボタンラベルが「はじめる」に変わる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/754d3fdc-19bf-4ca4-8b57-7c8215e0f9ba.png" width="320">

</details>

### **左スワイプでスライドを移動できる**: PageView を左スワイプすると次スライドへ移動し、ドットインジケータと eyebrow が追従する（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/ee224cd5-05ba-4e3e-a2af-c013003515f0.png" width="320">

mobile-mcp の `mobile_swipe_on_screen`（direction: left、開始 x=330 / y=400、distance 280）で 1 枚目から 2 枚目へ移動し、eyebrow が `02/02`、ドットインジケータの横長ドットが右側へ追従した。右スワイプ（開始 x=80）で 1 枚目へ戻れることも確認。

</details>

</details>

---

## 3. 完了・スキップと再表示抑止

- [x] **「スキップ」で認証画面へ遷移する**: 右上「スキップ」タップで hasSeenOnboarding を true に保存し、AuthPage（認証画面）が表示される
- [x] **最終スライドの「はじめる」で認証画面へ遷移する**: 最終スライドで「はじめる」をタップすると hasSeenOnboarding を true に保存し、AuthPage が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）
- [x] **一度完了すると再表示されない**: 完了・スキップ後にアプリを再起動しても（Keychain / SharedPreferences を保持したまま）オンボーディングは表示されず、未認証なら AuthPage が表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「スキップ」で認証画面へ遷移する**: 右上「スキップ」タップで hasSeenOnboarding を true に保存し、AuthPage（認証画面）が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9d0c1790-a546-4c4f-9dfa-66ebd8848ec0.png" width="320">

2026-08-19 の再検証は未実施。オンボーディングを再表示させるため `maestro/flows/auth_page_test_01.yaml`（`clearState: true` + `clearKeychain: true`）を実行したところ、以降アプリが LaunchLoading（白画面）のまま起動を完了しなくなり、この項目だけ再確認できなかった（詳細は root QA.md の実行ナレッジ「clearState + clearKeychain 後に起動が完了しなくなる」を参照）。同セッションで「はじめる」からの AuthPage 遷移は確認済みで、スキップ・はじめるは同じ `finish(reason:)` 経由のため、l10n 化による影響は無いと判断している。

</details>

### **最終スライドの「はじめる」で認証画面へ遷移する**: 最終スライドで「はじめる」をタップすると hasSeenOnboarding を true に保存し、AuthPage が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/5c904ee9-36b3-4484-af42-fc346ea4fb6d.png" width="320">

2 枚目で「はじめる」をタップして AuthPage へ遷移した直後の画面。

</details>

### **一度完了すると再表示されない**: 完了・スキップ後にアプリを再起動しても（Keychain / SharedPreferences を保持したまま）オンボーディングは表示されず、未認証なら AuthPage が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/712f2a38-3080-4c4f-ae05-9a86ed269528.png" width="320">

「はじめる」でオンボーディングを完了した後、`xcrun simctl terminate` → `xcrun simctl launch`（clearState なし）で再起動すると、オンボーディングを経由せず AuthPage が表示された。

</details>

</details>

---

## 4. 画像フォールバック

- [ ] **スライド画像の読み込み失敗時に Flutter 描画アートが表示される**: `images/onboarding/slide_N.png` のロードに失敗した場合、各スライド固有の Flutter 描画（傾いたリストカード / アバターの周回図）にフォールバックしてレイアウトが崩れない
  - ⏭️ 通常はアセットが同梱されているため画像側が表示される。フォールバックは画像を意図的に欠損させないと再現できないため、必要時のみ確認する
  - 2026-07-15 の QA で slide_1.png / slide_2.png が実機で正しくイラストとして表示されること（Flutter 描画フォールバックではなく本来の画像）を確認済み（セクション1・2のスクショ参照）。フォールバック自体（画像欠損時の挙動）は本項目の通り未検証のまま

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スライド画像の読み込み失敗時に Flutter 描画アートが表示される**: `images/onboarding/slide_N.png` のロードに失敗した場合、各スライド固有の Flutter 描画（傾いたリストカード / アバターの周回図）にフォールバックしてレイアウトが崩れない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
