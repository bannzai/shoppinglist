# お問い合わせ (inquiry)

## 概要
アプリ内のお問い合わせフォーム。ユーザーがメールアドレス・種類・内容を入力して送信すると、
Firebase Functions(`submitInquiry`)経由で Firestore への保存と Slack 通知を行う。
従来の Google Forms へのリンク方式を置き換えたもの。

## 画面
- **InquiryPage** (`lib/features/inquiry/page.dart`)
  - 表示条件: 設定画面 (`lib/features/settings/page.dart`) の「お問い合わせ」セルから `Navigator.push` で遷移
  - 入力項目:
    - メールアドレス (必須・形式チェックあり。返信先)
    - お問い合わせの種類 (必須。不具合報告 / 操作方法について / ご要望・改善要望 / その他)
    - お問い合わせ内容 (必須・最大5000文字)
  - 端末プラットフォーム・アプリバージョンは送信時に自動付与する

## フロー
1. ユーザーが設定画面で「お問い合わせ」をタップ → InquiryPage へ遷移
2. メールアドレス・種類・内容を入力して「送信する」をタップ
3. クライアントでバリデーション (メール形式・必須項目)
4. `functions.submitInquiry(...)` を呼び出し (`lib/utils/functions/firebase_function.dart`)
5. Functions 側で以下を実行:
   - 送信ユーザーの関連データ (users/{uid} とサブコレクション、所属 groups と全サブコレクション) をスナップショット
   - `inquiries/{id}` ドキュメントを作成 (スナップショットを `snapshotJson` に格納)
   - Slack へ Block Kit メッセージで通知 (問い合わせ ID・ユーザー情報・内容・復元コマンド例)
     - 投稿先は Secret `SLACK_INQUIRY_CHANNEL_ID` のチャンネル。DEBUG ビルドのアプリはテスト用の引数 `test: true` を付けて呼ぶため、
       その通知は bannzai のプロジェクト共通の `#test-notification` に届く (dev / prod のプロジェクトでは切り替えない)
6. 成功時はトーストを表示して画面を閉じる。失敗時はエラーメッセージをそのまま表示

## データ形式
- カテゴリの `wireValue` は Functions 側 (`firebase/functions/src/entity/inquiry.ts` の `InquiryCategorySchema`) と一致させること
  - `lib/entity/inquiry_category.dart` の `InquiryCategory` enum が正
- `inquiries` コレクションはクライアントから直接 read/write 禁止 (Functions Admin SDK 経由のみ。`firebase/firestore.rules` 参照)

## DB スナップショットの復元
お問い合わせ送信時に保存されたスナップショットは、開発者が以下のコマンドで Firestore へ書き戻して
不具合を再現できる (`firebase/functions/src/script/restoreInquirySnapshot.ts`)。

```
GOOGLE_APPLICATION_CREDENTIALS=../.secret/GOOGLE_APPLICATION_CREDENTIALS.json \
  npm run script-restore-inquiry-snapshot -- <inquiryID> [--apply]
```

- 既定はドライラン (復元対象の一覧表示のみ)。`--apply` で実際に書き込む (set(merge:true) で冪等)
- 本番プロジェクトへの `--apply` は `ALLOW_PROD_RESTORE=true` がない限り拒否する
