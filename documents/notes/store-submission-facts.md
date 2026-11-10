---
scope: repository
recorded: 2026-11-10
---
# ストアの申請で使う ID と、申請の時に App Store Connect が返したエラー

2026-08-08 の 1.0 の申請の作業で確かめた。ストアの側の状態は API で読めるので、迷ったら実際の値を読む。

## ID

- App Store Connect の App ID: `6739724511` (`lib/utils/config/platform.dart` のストアの URL と一致)
- サブスクリプションのグループ (Premium): `22042037`。サブスクリプション 4 商品と、買い切りの `shoppinglist_10000yen_lifetime` (2026-08-08 に App Store Connect API で読んだ値。2026-11-10 にメモへ移した時は API で読み直していない)
- Google Play の package: `com.bannzai.shoppinglist`

## アプリ名

「買い物リスト」「Shopping List」は、どちらも他のアカウントが使っていて、App Store Connect が `DUPLICATE.DIFFERENT_ACCOUNT` で拒否した。登録できた名前は「買い物リスト - 家族と共有」「Shopping List - Family Share」で、`ios/fastlane/metadata/` はこの値になっている。en-US のサブタイトルは 30 字までだった。

## 審査への提出で返ったエラー

1. `STATE_ERROR.BINARY_INDICATES_APP_TRACKS_USERS`: 広告の SDK を外しても、`NSUserTrackingUsageDescription` が Info.plist に残っていると返る。`GADApplicationIdentifier` と `SKAdNetworkItems` も一緒に消す
2. `STATE_ERROR.APP_DATA_USAGES_REQUIRED`: App Privacy が未回答の時に返る (回答の内容は `documents/app-privacy-answers.md`)

サブスクリプションは、審査の提出の項目 (`reviewSubmissionItems`) に個別に足せなかった (`'subscription' is not a relationship`)。アプリのバージョンの提出に含めて審査される。

**なぜ:** 名前の衝突と提出のエラーは、提出して初めて分かり、原因がエラーの文言から読み取りにくい。

**どう使う:** アプリ名・サブタイトルを変える時は、元の短い名前に戻そうとしない。提出が上のエラーで止まったら、書いてある原因から確かめる。
