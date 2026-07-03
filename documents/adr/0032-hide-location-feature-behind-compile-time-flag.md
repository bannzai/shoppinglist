# 0032. 位置情報機能はコンパイル時 feature flag で隠し、バックグラウンド位置情報の権限宣言を除去する

## Status
Accepted

## Context
ファーストリリースでは需要が未検証の位置情報機能（位置情報リマインダー・買い物する場所・店舗ごとのカテゴリ並び順）を隠し、需要が出てから復活させたい（issue #465）。

また、機能が見えない状態で位置情報の宣言だけが残ると、ストア審査上のリスクがある:

- Android: `ACCESS_BACKGROUND_LOCATION` は Play Console の審査フォーム（利用目的の申告 + デモ動画）が必須で、該当機能が UI から確認できないと承認されない可能性が高い
- iOS: `UIBackgroundModes` の `location` は「バックグラウンド位置情報を使う機能がアプリ内で確認できること」を審査で問われる

## Decision
コード削除ではなく、コンパイル時 feature flag（`lib/utils/config/feature_flags.dart` の `const bool shoppingLocationFeatureEnabled = false`）で UI エントリーポイントとジオフェンス監視の起動を gate する。

権限宣言は以下の方針で除去する:

- iOS: `UIBackgroundModes` から `location` を削除。`NSLocation*UsageDescription`（purpose string）は残す。geolocator が CoreLocation をバイナリにリンクし続けるため、purpose string を消すとアップロード時の静的検査（ITMS-90683）で弾かれる可能性があるため
- Android: `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` / `ACCESS_BACKGROUND_LOCATION` / `FOREGROUND_SERVICE_LOCATION` の 4 件を削除

位置情報専用の Maestro E2E フローは `maestro/flows/disabled_shopping_location/` へ退避する（`maestro test maestro/flows/` はサブディレクトリを走査しないため実行対象から外れる）。

### 退けた代替案
- **コードごと削除して復活時に git revert**: 復活時点では周辺コードが進んでいて revert がコンフリクトしやすく、復活コストが高い。「一旦隠す・需要が出たら復活」という issue の意図に合わない
- **Firebase Remote Config 等のランタイム flag**: 権限宣言はコンパイル時にしか切り替えられないため、ランタイム flag では審査リスクを解消できない。切り替え頻度が想定されない機能に対して Remote Config の運用コストが見合わない

## Consequences
- 復活手順が「flag を true に戻す + 権限宣言の復元 + 退避フローを戻す」で完結する（手順は flag の doc コメントと `disabled_shopping_location/README.md` に記載）
- 機能コード（GeofenceService・Provider・各ページ）はデッドコードとしてビルドに含まれ続ける。const flag のため Release ビルドでは tree shaking の対象になるが、ソース上のメンテナンス対象としては残る
- 隠した機能のプレミアムゲーティング等のテストは「表示されないこと」の検証に縮退する。復活時に git 履歴から元のテストを復元する必要がある
- geolocator / google_maps_flutter / geocoding のパッケージ依存は残る（purpose string を残す判断と表裏一体）
