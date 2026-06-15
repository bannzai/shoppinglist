# 0029. 復元コマンドの uid 載せ替え (--target-uid)

## Status
Accepted

## Context
ADR 0028 で、お問い合わせ時点のスナップショットを named database `development` へ復元する仕組みを導入した。そこでは「スナップショットは本番ユーザーの uid のまま `development` に復元される。dev の別ユーザーで『自分のデータ』として再現するには uid 載せ替えが別途必要(今回は未対応)」と明記し、uid 載せ替えを将来課題として残していた。

実際の運用では、不具合を再現する開発者は問い合わせ元ユーザー(User A)とは別の端末・別アカウントで作業する。本アプリの認証は Firebase Auth(project 単位)で、別端末では匿名サインイン(`auth/page.dart` の `signInAnonymously`、debug ビルドで許可)により**別の uid** になる。スナップショットは User A の uid で全パス・全フィールドが構成されているため、そのまま `development` に復元しても、別 uid のユーザーが開いた home には何も表示されない(groups の `memberUserIDs` に自分が含まれず、`users/{自分のuid}` も存在しないため)。

そこで、スナップショットを「復元する端末のユーザー uid」へ載せ替える機能が必要になった。

## Decision
復元スクリプト `firebase/functions/src/script/restoreInquirySnapshot.ts` に `--target-uid <uid>` を追加する。

- スナップショット内の元 uid を `users/{uid}` エントリ(パスが `^users/[^/]+$` に一致するもの)から自動検出する。
- 元 uid を target uid へ、**全エントリの path と data(`JSON.stringify` した文字列)に対して一括文字列置換**する。これにより `memberUserIDs` / `ownerUserID` / `userID` 等のフィールド値も、`GroupUserProfile_..._users_{uid}` のような Composite ID も、`users/{uid}` のドキュメントパスもまとめて置換される。
- 復元先は ADR 0028 どおり既定で `development`。

代替案として「フィールド単位で remap 対象を列挙して構造的に置換する」も検討したが、uid が現れる箇所(配列・Composite ID・パス・各種フィールド)が多岐にわたり列挙漏れのリスクが高い。**uid は十分に長い一意文字列**であり、スナップショット内で uid 以外の文字列と偶然一致することは実質起こらないため、単純な全文字列置換を採用した(実装も最小で済む)。これは参考実装 Riamo の `restore_inquiry_snapshot`(prod accountId を devUserId へ置換)と同方針。

## Consequences
- 別端末で匿名サインインして得た別 uid に正規ユーザーのデータを載せ替えて復元でき、**本人視点(home に自分のリストが並ぶ状態)で不具合を再現**できる。
- クロスユーザー復元を E2E で検証済み: 正規ユーザーの実問い合わせ(`rbmEE7MTCOlRxdaHhLd4`)の Slack 添付 JSON を、別 sim・別匿名ユーザー(`n0ve...`)および事前データ無しの fresh uid へ `--file` + `--target-uid` で復元し、3 グループ・3 アイテムの再現を確認。
- トレードオフ: `sessionId` / `fcmToken` 等の端末固有値もそのまま運ぶ(現状は除外していない)。復元したデータで実害が出る場合(他端末セッションの巻き込み等)は別途除外が必要。Riamo はこれらを除外しているため、必要になった時点で追従する。
- 文字列置換のため、万一 uid と同一文字列がデータ本文に含まれていればそれも置換される。uid の一意性・長さから現実的なリスクはないが、原理的な注意点として残る。
- `--target-uid` 未指定時は従来どおり元 uid のまま復元する(挙動の後方互換)。
