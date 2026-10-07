# Custom Product Page (CPP) 設計 plan

`cpp/config.json` の設計根拠を記録する。config.json が SSOT で、本ドキュメントは「なぜその設計にしたか」だけを持つ。

- App: 買い物リスト - 家族と共有 (com.bannzai.shoppinglist) / App ID: 6739724511
- 作成: 2026-10 (castle issue https://github.com/bannzai/castle/issues/1503 「各リポジトリの対応」)
- 適用は `appstore-custom-product-page` skill の `cpp_apply_config.sh --config cpp/config.json`

## 共通方針

- 目的はオーガニック検索流入の拡大。CPP に検索キーワードを割り当て、キーワードごとに検索結果の Creative Asset (search results) と製品ページの header を出し分ける
- 既定の製品ページの訴求 (家族と、ひとつの買い物リスト) は `appstore/creative-assets/default/` (和紙の地にクリップボードのチェックリストとトートバッグ) で表す。配色は `lib/style/tokens.dart` の和紙・墨・朱
- スクリーンショットは新規に作らず、公開中のバージョン (1.0) を雛形 (`cpp_create.sh --template-version`) に複製する。CPP 固有の差分は promotionalText・keywords・Creative Asset
- キーワードは公開中バージョンの Keywords の語句だけ割り当てられる。新バージョン承認で割り当てがリセットされるため、承認後に `cpp_apply_config.sh` を再実行して復元する
- 対象 locale は ja と en-US (公開中バージョンのローカライズはこの 2 つ)

## CPP 一覧

### 1. grocery-202610 (食材・スーパーの買い物軸)

- 対象オーディエンス: 家族共有が目的ではなく、スーパーでの買い忘れをなくしたい・食材を管理したい個人
- 流入元: 「食材管理」「スーパー」「買い忘れ」「お買い物」「チェックリスト」「カテゴリ」の検索 (ja)、"grocery" "supermarket" "checklist" "organize" (en-US)
- 仮説: 既定ページはアプリ名のとおり「家族と共有」が主語で、ひとりで使いたい人には過剰に見える。自動仕分け・売り場順・レシート読み取りという個人でも効く機能を前に出し、Creative Asset は野菜を添えて食材の文脈にする
- Creative Asset: `appstore/creative-assets/grocery/`
- スクリーンショット: 既定ページの複製

## 次工程

1. `cpp_create.sh grocery-202610 --locale ja --template-version d1798b0a-d8f7-4a62-b31c-51d262e7744e` で作成 (2026-10-07 時点では Apple 側の一時障害 `ENTITY_ERROR.RELATIONSHIP.REQUIRED` で作成できず、再試行中)
2. `cpp_apply_config.sh --config cpp/config.json` で promotionalText と keywords を適用
3. `asset_library_set_placement.sh --target cpp` で header / search results を配置し、ユーザー確認後に `cpp_submit.sh <CPP_ID>` で提出
4. 承認後、App Analytics で CPP ごとの impressions / CVR を計測
