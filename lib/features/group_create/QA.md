---
feature: group_create
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-14
---

# group_create QA

## 1. グループ名の入力とボタン活性

- [x] **名前入力欄のオートフォーカス**: 画面表示時にグループ名 TextField が autofocus され、hint「グループ名を入力」を表示する
- [x] **空名では作成ボタン無効**: グループ名が空、または空白のみのとき「作成する」ボタンは無効（onPressed: null）（Issue #432）
- [x] **入力で作成ボタン有効化**: グループ名に非空の文字（trim 後）を入力すると「作成する」ボタンが有効になる（Issue #432）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前入力欄のオートフォーカス**: 画面表示時にグループ名 TextField が autofocus され、hint「グループ名を入力」を表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/bb6e5acc-d686-4236-baa8-680cb60bfd23.png" width="320">

</details>

### **空名では作成ボタン無効**: グループ名が空、または空白のみのとき「作成する」ボタンは無効（onPressed: null）（Issue #432）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/bb6e5acc-d686-4236-baa8-680cb60bfd23.png" width="320">

</details>

### **入力で作成ボタン有効化**: グループ名に非空の文字（trim 後）を入力すると「作成する」ボタンが有効になる（Issue #432）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/f3101b36-a58b-4bea-b46e-c77ad6c6fb3d.png" width="320">

</details>

</details>

---

## 2. アイコン選択

- [x] **6種アイコンの表示**: home/cart/fork/cookie/pets/bag の6アイコンを3x2グリッドで表示する（既定選択は home）
- [x] **アイコン選択の切替**: アイコンをタップすると選択状態がそのアイコンに切り替わり、選択中のアイコンが accentSoft 背景・accent 枠で強調表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **6種アイコンの表示**: home/cart/fork/cookie/pets/bag の6アイコンを3x2グリッドで表示する（既定選択は home）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/bb6e5acc-d686-4236-baa8-680cb60bfd23.png" width="320">

</details>

### **アイコン選択の切替**: アイコンをタップすると選択状態がそのアイコンに切り替わり、選択中のアイコンが accentSoft 背景・accent 枠で強調表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/f1363abc-7c0f-43c8-bbc4-94d769471974.png" width="320">

</details>

</details>

---

## 3. グループ作成

- [x] **作成の実行**: 「作成する」をタップすると createGroup を実行し、実行中はボタン表示が「作成中...」に変わる（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）
- [x] **作成エラー表示**: 作成に失敗した場合、名前入力欄の下に赤いエラーコンテナでエラーメッセージ（そのまま表示）を出す
- [x] **プレミアム時の2個目作成**: プレミアム状態では2個目以降のグループも作成でき、上限 SnackBar は出ない（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **作成の実行**: 「作成する」をタップすると createGroup を実行し、実行中はボタン表示が「作成中...」に変わる（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

タップとスクリーンショットを並列実行して撮影（トースト撮影と同じ技法）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/236fab29-1188-444f-9b55-faca4540d118.png" width="320">

</details>

### **作成エラー表示**: 作成に失敗した場合、名前入力欄の下に赤いエラーコンテナでエラーメッセージ（そのまま表示）を出す

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

サーバー側バリデーション（グループ名101文字以上入力、`MAX_GROUP_NAME_LENGTH=100`）でエラーを発生させて確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/6dce71e8-da29-436f-ab55-64a1f256c362.png" width="320">

</details>

### **プレミアム時の2個目作成**: プレミアム状態では2個目以降のグループも作成でき、上限 SnackBar は出ない（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/9f9f5115-c6f1-4c64-b78d-6caf7212b372.png" width="320">

</details>

</details>

---

## 4. 作成後の招待ダイアログ

- [x] **招待コードの表示**: グループ作成成功後、招待コードを自動発行して「メンバーを招待」ダイアログに招待コードを表示する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）
- [x] **招待コードのコピー**: 「コピー」でクリップボードにコピーし、「招待コードをコピーしました」のグローバルトーストを前面に表示する
- [x] **招待コードの共有**: 「共有」で OS の共有シートを開く
- [x] **閉じて画面終了**: 「閉じる」でダイアログを閉じ、グループ作成画面も pop してグループ一覧へ戻る（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コードの表示**: グループ作成成功後、招待コードを自動発行して「メンバーを招待」ダイアログに招待コードを表示する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/d7462a7b-6e55-4234-b3b7-55c8a4a31cf9.png" width="320">

</details>

### **招待コードのコピー**: 「コピー」でクリップボードにコピーし、「招待コードをコピーしました」のグローバルトーストを前面に表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

タップ操作とスクリーンショット撮影を並列実行（同一メッセージ内で2ツールを同時発行）することで撮影に成功した。逐次実行では5秒間のトースト表示時間内でも撮り逃す（タップ→スクショの往復レイテンシが積み重なるため）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/7e495d44-7774-4c63-92ea-f73d87666c98.png" width="320">

</details>

### **招待コードの共有**: 「共有」で OS の共有シートを開く

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a26e6b85-b9f3-4f49-93ce-c7acc952d4d1.png" width="320">

</details>

### **閉じて画面終了**: 「閉じる」でダイアログを閉じ、グループ作成画面も pop してグループ一覧へ戻る（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/29cba321-ed29-425b-8c40-e89207ec8d6b.png" width="320">

</details>

</details>

---
