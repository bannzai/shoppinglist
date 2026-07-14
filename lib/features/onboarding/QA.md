---
feature: onboarding
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# onboarding QA

オンボーディングは「未認証 かつ hasSeenOnboarding=false」のユーザーにのみ表示される（`lib/features/resolver/auth.dart`）。再現するにはアプリ削除では不十分で（Keychain に認証が残存する）、`clearState: true` + `clearKeychain: true`、または新規シミュレータで未認証状態に戻す必要がある。位置情報機能は `shoppingLocationFeatureEnabled = false` で無効のため、店舗近接通知を訴求するスライド 3 は表示されず、スライドは 2 枚構成になる（`OnboardingPage._slideCount = 2`）。

## 1. 初回起動時の表示

- [ ] **スライド 2 枚が表示される**: 1 枚目「家族と作る、買い物リスト」、2 枚目「同じリストを同時に編集」の 2 スライドが表示される。位置情報スライドはフラグ無効のため出ない（既存 E2E: maestro/flows/design_v2_entry.yaml）
- [ ] **eyebrow が `01/02` 形式で表示される**: 各スライド上部に `現在番号/総数` を 2 桁ゼロ埋めした mono 表記（例: `01/02`）が accent 色で表示される
- [ ] **ドットインジケータが 2 個表示される**: 下部に 2 個のドットが並び、現在ページのドットのみ横長（幅 22）で accent 色になる
- [ ] **右上にスキップ、下部に進行ボタンが表示される**: 右上に「スキップ」テキストボタン、最下部に横幅いっぱいの accent ピルボタンが表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スライド 2 枚が表示される**: 1 枚目「家族と作る、買い物リスト」、2 枚目「同じリストを同時に編集」の 2 スライドが表示される。位置情報スライドはフラグ無効のため出ない（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **eyebrow が `01/02` 形式で表示される**: 各スライド上部に `現在番号/総数` を 2 桁ゼロ埋めした mono 表記（例: `01/02`）が accent 色で表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **ドットインジケータが 2 個表示される**: 下部に 2 個のドットが並び、現在ページのドットのみ横長（幅 22）で accent 色になる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **右上にスキップ、下部に進行ボタンが表示される**: 右上に「スキップ」テキストボタン、最下部に横幅いっぱいの accent ピルボタンが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. スライド操作

- [ ] **「次へ」ボタンで次スライドへ進む**: 最終スライド以外ではボタンラベルが「次へ」で、タップすると 240ms のアニメーションで次のページへ遷移する
- [ ] **最終スライドではボタンが「はじめる」になる**: 最後のスライド（2 枚目）ではボタンラベルが「はじめる」に変わる
- [ ] **左スワイプでスライドを移動できる**: PageView を左スワイプすると次スライドへ移動し、ドットインジケータと eyebrow が追従する（既存 E2E: maestro/flows/design_v2_entry.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「次へ」ボタンで次スライドへ進む**: 最終スライド以外ではボタンラベルが「次へ」で、タップすると 240ms のアニメーションで次のページへ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **最終スライドではボタンが「はじめる」になる**: 最後のスライド（2 枚目）ではボタンラベルが「はじめる」に変わる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **左スワイプでスライドを移動できる**: PageView を左スワイプすると次スライドへ移動し、ドットインジケータと eyebrow が追従する（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 完了・スキップと再表示抑止

- [ ] **「スキップ」で認証画面へ遷移する**: 右上「スキップ」タップで hasSeenOnboarding を true に保存し、AuthPage（認証画面）が表示される
- [ ] **最終スライドの「はじめる」で認証画面へ遷移する**: 最終スライドで「はじめる」をタップすると hasSeenOnboarding を true に保存し、AuthPage が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml）
- [ ] **一度完了すると再表示されない**: 完了・スキップ後にアプリを再起動しても（Keychain / SharedPreferences を保持したまま）オンボーディングは表示されず、未認証なら AuthPage が表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「スキップ」で認証画面へ遷移する**: 右上「スキップ」タップで hasSeenOnboarding を true に保存し、AuthPage（認証画面）が表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **最終スライドの「はじめる」で認証画面へ遷移する**: 最終スライドで「はじめる」をタップすると hasSeenOnboarding を true に保存し、AuthPage が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **一度完了すると再表示されない**: 完了・スキップ後にアプリを再起動しても（Keychain / SharedPreferences を保持したまま）オンボーディングは表示されず、未認証なら AuthPage が表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. 画像フォールバック

- [ ] **スライド画像の読み込み失敗時に Flutter 描画アートが表示される**: `images/onboarding/slide_N.png` のロードに失敗した場合、各スライド固有の Flutter 描画（傾いたリストカード / アバターの周回図）にフォールバックしてレイアウトが崩れない
  - ⏭️ 通常はアセットが同梱されているため画像側が表示される。フォールバックは画像を意図的に欠損させないと再現できないため、必要時のみ確認する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スライド画像の読み込み失敗時に Flutter 描画アートが表示される**: `images/onboarding/slide_N.png` のロードに失敗した場合、各スライド固有の Flutter 描画（傾いたリストカード / アバターの周回図）にフォールバックしてレイアウトが崩れない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
