---
feature: shopping_list
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# shopping_list QA

## 1. 表示状態・グループ切替

- [ ] **リストなし状態**: 買い物リストが 0 件のとき「買い物リストがありません」「新しい買い物リストを作成しましょう」と案内し、「買い物リストを作成」ボタンで空リストを 1 件作成する。無料上限超過時は上限 SnackBar（アップグレード導線付き）を出す
- [ ] **空リスト状態のスターター行・ヒント**: アイテム 0 件のリストで「タップで入力開始」の空行、例文ゴースト行 5 件、「こんな風に使えます」ヒントカード（タップで入力 / return で次の行 / 空行で delete / 右下 FAB 長押しで写真・URL）を表示する（既存 E2E: maestro/flows/add_and_check_item.yaml）
- [ ] **グループ切替チップ**: グループが 2 つ以上あるとき上部に横スクロールチップを表示し、タップで表示グループを切り替える（選択中はチェック付き）。グループが 1 つのときは非表示（既存 E2E: maestro/flows/empty_shopping_list_create.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リストなし状態**: 買い物リストが 0 件のとき「買い物リストがありません」「新しい買い物リストを作成しましょう」と案内し、「買い物リストを作成」ボタンで空リストを 1 件作成する。無料上限超過時は上限 SnackBar（アップグレード導線付き）を出す

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空リスト状態のスターター行・ヒント**: アイテム 0 件のリストで「タップで入力開始」の空行、例文ゴースト行 5 件、「こんな風に使えます」ヒントカード（タップで入力 / return で次の行 / 空行で delete / 右下 FAB 長押しで写真・URL）を表示する（既存 E2E: maestro/flows/add_and_check_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループ切替チップ**: グループが 2 つ以上あるとき上部に横スクロールチップを表示し、タップで表示グループを切り替える（選択中はチェック付き）。グループが 1 つのときは非表示（既存 E2E: maestro/flows/empty_shopping_list_create.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. アイテムの追加・入力

- [ ] **FAB タップで空行追加**: 右下 FAB（add_task アイコン）タップで空の入力行を 1 件追加し、自動フォーカスしてキーボードを開く（既存 E2E: maestro/flows/design_v2_list_core.yaml）
- [ ] **Enter 連続入力**: 入力行で文字を入力し Enter（改行）で確定すると、確定アイテムが上に積まれ、入力行は空のまま末尾に残ってフォーカス・キーボードを維持し連続入力できる（既存 E2E: maestro/flows/shopping_list_enter_and_empty_row_removal.yaml）
- [ ] **空行の自動削除**: 空の入力行からフォーカスが外れる、または空欄で Backspace を押すとその行を削除する。入力途中のテキストがあればフォーカス喪失時に確定保存する（既存 E2E: maestro/flows/add_and_check_item.yaml）
- [ ] **キーボード閉じるツールバー**: アイテム入力でキーボード表示中、キーボード直上に「閉じる」ツールバーを出し、タップでフォーカスを外してキーボードを閉じる。キーボード表示中も FAB は表示し続け、タップ・長押しでキーボードを閉じる（空行追加はしない）（既存 E2E: maestro/flows/keyboard_close_toolbar.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **FAB タップで空行追加**: 右下 FAB（add_task アイコン）タップで空の入力行を 1 件追加し、自動フォーカスしてキーボードを開く（既存 E2E: maestro/flows/design_v2_list_core.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **Enter 連続入力**: 入力行で文字を入力し Enter（改行）で確定すると、確定アイテムが上に積まれ、入力行は空のまま末尾に残ってフォーカス・キーボードを維持し連続入力できる（既存 E2E: maestro/flows/shopping_list_enter_and_empty_row_removal.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空行の自動削除**: 空の入力行からフォーカスが外れる、または空欄で Backspace を押すとその行を削除する。入力途中のテキストがあればフォーカス喪失時に確定保存する（既存 E2E: maestro/flows/add_and_check_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キーボード閉じるツールバー**: アイテム入力でキーボード表示中、キーボード直上に「閉じる」ツールバーを出し、タップでフォーカスを外してキーボードを閉じる。キーボード表示中も FAB は表示し続け、タップ・長押しでキーボードを閉じる（空行追加はしない）（既存 E2E: maestro/flows/keyboard_close_toolbar.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. アイテムのチェック

- [ ] **チェックボックスでチェック切替**: 行頭の円形チェックボックスをタップするとチェック / 解除が切り替わり、チェック時はポップアニメ + テキストに取り消し線 + checked 色になる。メッセージが空の行はタップ不可（既存 E2E: maestro/flows/add_and_check_item.yaml）
- [ ] **右スワイプでチェック切替**: アイテムを右スワイプするとチェック状態がトグルし、行は残る。空行は右スワイプ無効（既存 E2E: maestro/flows/design_v2_list_core.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チェックボックスでチェック切替**: 行頭の円形チェックボックスをタップするとチェック / 解除が切り替わり、チェック時はポップアニメ + テキストに取り消し線 + checked 色になる。メッセージが空の行はタップ不可（既存 E2E: maestro/flows/add_and_check_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **右スワイプでチェック切替**: アイテムを右スワイプするとチェック状態がトグルし、行は残る。空行は右スワイプ無効（既存 E2E: maestro/flows/design_v2_list_core.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. アイテムの編集・削除

- [ ] **既存アイテムの編集確定**: 既存アイテムのテキストを編集し Enter で確定すると内容を更新し、末尾の入力行へフォーカスを移す（入力行が無ければ新規作成）。空にして Enter するとその既存アイテムを削除する
- [ ] **左スワイプ削除 + Undo**: アイテムを左スワイプすると削除し、「アイテムを削除しました」SnackBar の「元に戻す」で復元できる（既存 E2E: maestro/flows/swipe_delete_item.yaml）
- [ ] **詳細シートからの削除**: 詳細シート右上のゴミ箱アイコン →「このアイテムを削除しますか？」の確認 →「削除」でアイテムを削除しシートを閉じる（「キャンセル」で閉じる）（既存 E2E: maestro/flows/item_detail_and_delete.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **既存アイテムの編集確定**: 既存アイテムのテキストを編集し Enter で確定すると内容を更新し、末尾の入力行へフォーカスを移す（入力行が無ければ新規作成）。空にして Enter するとその既存アイテムを削除する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **左スワイプ削除 + Undo**: アイテムを左スワイプすると削除し、「アイテムを削除しました」SnackBar の「元に戻す」で復元できる（既存 E2E: maestro/flows/swipe_delete_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **詳細シートからの削除**: 詳細シート右上のゴミ箱アイコン →「このアイテムを削除しますか？」の確認 →「削除」でアイテムを削除しシートを閉じる（「キャンセル」で閉じる）（既存 E2E: maestro/flows/item_detail_and_delete.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. アイテム詳細・カテゴリ割り当て

- [ ] **詳細シート表示**: 行末尾の詳細アイコン（more_horiz）でアイテム名・カテゴリ・削除のシートを開く。説明・写真・カラーの編集項目は表示しない（既存 E2E: maestro/flows/item_detail_and_delete.yaml）
- [ ] **カテゴリの確認・変更**: カテゴリ軸があるとき、現在の分類カテゴリ（未分類含む）を表示し「カテゴリを選択 / 変更」でカテゴリ選択画面へ遷移してアイテムを割り当てる。未分類の確定済み行に出る「カテゴリ +」チップからも割り当てられる。軸が無いときはカテゴリ行を表示しない（既存 E2E: maestro/flows/category_select_from_item.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **詳細シート表示**: 行末尾の詳細アイコン（more_horiz）でアイテム名・カテゴリ・削除のシートを開く。説明・写真・カラーの編集項目は表示しない（既存 E2E: maestro/flows/item_detail_and_delete.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カテゴリの確認・変更**: カテゴリ軸があるとき、現在の分類カテゴリ（未分類含む）を表示し「カテゴリを選択 / 変更」でカテゴリ選択画面へ遷移してアイテムを割り当てる。未分類の確定済み行に出る「カテゴリ +」チップからも割り当てられる。軸が無いときはカテゴリ行を表示しない（既存 E2E: maestro/flows/category_select_from_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 6. 並び替え・カテゴリ間移動

- [ ] **アイテムの並び替え**: 確定アイテム行を長押しドラッグで並び替えでき、順序が保存される。入力行（空行）はドラッグ対象外
- [ ] **カテゴリ間移動**: カテゴリ表示時、アイテムを別カテゴリのセクションへドラッグすると移動先カテゴリへ分類が変わり（完全一致キーワードの付け替え）、順序も保存される
- [ ] **セクション並び替え**: カテゴリのセクションヘッダーを長押しドラッグでセクション単位に並び替えできる。「未分類」セクションは常に末尾でドラッグ不可（既存 E2E: maestro/flows/category_section_reorder.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **アイテムの並び替え**: 確定アイテム行を長押しドラッグで並び替えでき、順序が保存される。入力行（空行）はドラッグ対象外

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カテゴリ間移動**: カテゴリ表示時、アイテムを別カテゴリのセクションへドラッグすると移動先カテゴリへ分類が変わり（完全一致キーワードの付け替え）、順序も保存される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **セクション並び替え**: カテゴリのセクションヘッダーを長押しドラッグでセクション単位に並び替えできる。「未分類」セクションは常に末尾でドラッグ不可（既存 E2E: maestro/flows/category_section_reorder.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 7. AI 自動カテゴリ分け

- [ ] **ボタン表示・分類プレビュー・登録**: 未分類アイテムが 1 件以上あるときリスト上部に「自動でカテゴリ分け（N 件）」ボタンを表示（入力中の空行は件数から除外）。タップ → AI 処理（処理中バナー）→ プレビューシートでカテゴリ変更・除外 →「N 件を登録」で分類を永続化しアイテムが各カテゴリへ移動、「N 件をカテゴリに登録しました」SnackBar を出す
- [ ] **利用上限**: 当月の残回数が 0 のとき「自動カテゴリ分けの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き。プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ボタン表示・分類プレビュー・登録**: 未分類アイテムが 1 件以上あるときリスト上部に「自動でカテゴリ分け（N 件）」ボタンを表示（入力中の空行は件数から除外）。タップ → AI 処理（処理中バナー）→ プレビューシートでカテゴリ変更・除外 →「N 件を登録」で分類を永続化しアイテムが各カテゴリへ移動、「N 件をカテゴリに登録しました」SnackBar を出す

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **利用上限**: 当月の残回数が 0 のとき「自動カテゴリ分けの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き。プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 8. 写真・URL からの追加（AI 抽出）

- [ ] **FAB 長押しメニュー**: FAB 長押しで「写真から追加 / URL から追加 / テキスト貼り付け」メニューを上方向に展開する。AI 処理中は写真・URL 項目を無効化する。「テキスト貼り付け」はクリップボードの複数行を行ごとに追加（空行・既存と同名はスキップ）
- [ ] **写真 / URL から追加**: 「写真から追加」→ カメラ / フォトライブラリ選択、「URL から追加」→ HTTPS URL 入力 →「生成」で、いずれも AI 抽出（処理中バナー）→ review sheet で候補を選んで追加する。候補が空でも review sheet に「候補がありませんでした」を表示する。空・非 HTTPS の URL はトーストで弾く（既存 E2E: maestro/flows/design_v2_ai_review.yaml）
- [ ] **AI 利用上限（画像 / URL）**: 画像 / URL 読み取りの月間上限に達すると「〇〇読み取りの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き）（既存 E2E: maestro/flows/ai_image_recognition_limit.yaml, maestro/flows/ai_url_recognition_limit.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **FAB 長押しメニュー**: FAB 長押しで「写真から追加 / URL から追加 / テキスト貼り付け」メニューを上方向に展開する。AI 処理中は写真・URL 項目を無効化する。「テキスト貼り付け」はクリップボードの複数行を行ごとに追加（空行・既存と同名はスキップ）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **写真 / URL から追加**: 「写真から追加」→ カメラ / フォトライブラリ選択、「URL から追加」→ HTTPS URL 入力 →「生成」で、いずれも AI 抽出（処理中バナー）→ review sheet で候補を選んで追加する。候補が空でも review sheet に「候補がありませんでした」を表示する。空・非 HTTPS の URL はトーストで弾く（既存 E2E: maestro/flows/design_v2_ai_review.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **AI 利用上限（画像 / URL）**: 画像 / URL 読み取りの月間上限に達すると「〇〇読み取りの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き）（既存 E2E: maestro/flows/ai_image_recognition_limit.yaml, maestro/flows/ai_url_recognition_limit.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 9. リストの作成・複製・切替

- [ ] **リスト追加メニュー**: 上部バー右の「リストを追加」ボタンで「今日の日付でリストを追加 / 現在のリストを複製 / 未チェックのみ引き継いで複製」メニューを開く。「今日の日付でリストを追加」は日付名リスト作成 → 切替 → 空アイテム追加 → フォーカスまで連鎖する。複製は各アイテム（未チェックのみ含む）を引き継いだリストを作成し複製先へ表示を切り替える（既存 E2E: maestro/flows/shopping_list_crud.yaml, maestro/flows/shopping_list_name_sequence.yaml）
- [ ] **リスト切替シート**: 上部バーのリスト名（▼）タップで切替シートを開き、選択中リストにチェックマーク、末尾の「+ 新しいリストを追加」で新規作成して切り替える

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト追加メニュー**: 上部バー右の「リストを追加」ボタンで「今日の日付でリストを追加 / 現在のリストを複製 / 未チェックのみ引き継いで複製」メニューを開く。「今日の日付でリストを追加」は日付名リスト作成 → 切替 → 空アイテム追加 → フォーカスまで連鎖する。複製は各アイテム（未チェックのみ含む）を引き継いだリストを作成し複製先へ表示を切り替える（既存 E2E: maestro/flows/shopping_list_crud.yaml, maestro/flows/shopping_list_name_sequence.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **リスト切替シート**: 上部バーのリスト名（▼）タップで切替シートを開き、選択中リストにチェックマーク、末尾の「+ 新しいリストを追加」で新規作成して切り替える

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 10. グループ通知・プレミアム制限

- [ ] **グループへの更新通知**: グループに自分以外のメンバーが居るときだけ上部バーに通知ボタン（ベルアイコン）を表示（ソロでは非表示）。初回タップ時のみ説明ダイアログを出し「通知を送る」で送信 + 説明済みフラグ保存、2 回目以降は確認なしで他メンバー全員へ送信し「グループに通知しました」トーストを出す（開発者オプション →「グループにデバッグユーザーを追加」で他メンバーを用意して確認）
- [ ] **リスト数上限**: 無料プランで 1 グループのアクティブリストが上限（20 件）に達した状態で追加・複製すると上限 SnackBar（アップグレード導線）を出す。プレミアムでは上限を超えて作成できる（既存 E2E: maestro/flows/shopping_list_limit_non_premium.yaml, maestro/flows/premium_shopping_list_limit.yaml）
- [ ] **リテンションバナー・AI 上限のプレミアム拡張**: 無料プランでアイテムが 50 件超のとき最下部に「無料プランは作成から30日でリストが整理されます」バナーを出し「詳しく」でペイウォールを開く。プレミアムでは AI 画像 / URL / カテゴリ分けの月間上限が拡張される（既存 E2E: maestro/flows/premium_ai_image_recognition.yaml, maestro/flows/premium_ai_url_recognition.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループへの更新通知**: グループに自分以外のメンバーが居るときだけ上部バーに通知ボタン（ベルアイコン）を表示（ソロでは非表示）。初回タップ時のみ説明ダイアログを出し「通知を送る」で送信 + 説明済みフラグ保存、2 回目以降は確認なしで他メンバー全員へ送信し「グループに通知しました」トーストを出す（開発者オプション →「グループにデバッグユーザーを追加」で他メンバーを用意して確認）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **リスト数上限**: 無料プランで 1 グループのアクティブリストが上限（20 件）に達した状態で追加・複製すると上限 SnackBar（アップグレード導線）を出す。プレミアムでは上限を超えて作成できる（既存 E2E: maestro/flows/shopping_list_limit_non_premium.yaml, maestro/flows/premium_shopping_list_limit.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **リテンションバナー・AI 上限のプレミアム拡張**: 無料プランでアイテムが 50 件超のとき最下部に「無料プランは作成から30日でリストが整理されます」バナーを出し「詳しく」でペイウォールを開く。プレミアムでは AI 画像 / URL / カテゴリ分けの月間上限が拡張される（既存 E2E: maestro/flows/premium_ai_image_recognition.yaml, maestro/flows/premium_ai_url_recognition.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
