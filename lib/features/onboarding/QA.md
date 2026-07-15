---
feature: onboarding
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
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

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3625c1c1-d668-4233-a3a3-eda6ed9f9115.png" width="320">

</details>

### **eyebrow が `01/02` 形式で表示される**: 各スライド上部に `現在番号/総数` を 2 桁ゼロ埋めした mono 表記（例: `01/02`）が accent 色で表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3625c1c1-d668-4233-a3a3-eda6ed9f9115.png" width="320">

</details>

### **ドットインジケータが 2 個表示される**: 下部に 2 個のドットが並び、現在ページのドットのみ横長（幅 22）で accent 色になる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3625c1c1-d668-4233-a3a3-eda6ed9f9115.png" width="320">

</details>

### **右上にスキップ、下部に進行ボタンが表示される**: 右上に「スキップ」テキストボタン、最下部に横幅いっぱいの accent ピルボタンが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3625c1c1-d668-4233-a3a3-eda6ed9f9115.png" width="320">

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

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d49d84ec-cca0-473c-ab66-6820eac671e7.png" width="320">

</details>

### **最終スライドではボタンが「はじめる」になる**: 最後のスライド（2 枚目）ではボタンラベルが「はじめる」に変わる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d49d84ec-cca0-473c-ab66-6820eac671e7.png" width="320">

</details>

### **左スワイプでスライドを移動できる**: PageView を左スワイプすると次スライドへ移動し、ドットインジケータと eyebrow が追従する（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/4ac0334c-b2af-43a4-b79a-55386df1f96a.png" width="320">

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

</details>

### **最終スライドの「はじめる」で認証画面へ遷移する**: 最終スライドで「はじめる」をタップすると hasSeenOnboarding を true に保存し、AuthPage が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml は 3 スライド前提のstale flowのため未使用。手順は本ファイル末尾の「再現手順」参照）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/f2d01ffb-4ffd-433a-9924-6e4ec62efe6a.png" width="320">

</details>

### **一度完了すると再表示されない**: 完了・スキップ後にアプリを再起動しても（Keychain / SharedPreferences を保持したまま）オンボーディングは表示されず、未認証なら AuthPage が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/bfaf7be7-ba20-41f4-911f-9cb14ac3853a.png" width="320">

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
