---
scope: repository
recorded: 2026-11-10
---
# Maestro でプレミアムを付与する flow は、`SHOPPINGLIST_DEVELOPER_TOKEN` を渡したビルドでないと「開発者のみ」のエラーで失敗する

2026-08-01 の E2E の検証 (Issue #523) で実測した。flutter-maestro skill の `build-and-install.sh` が dart-define に渡すのは `REVENUECAT_TEST_STORE_API_KEY` だけで、そのビルドで `maestro/flows/shared/grant_premium_via_debug.yaml` (開発者オプションの「プレミアム付与（1日）」) を実行すると、「この機能は開発者のみ使用できます」のエラーになった。

**なぜ:** Functions の側の開発者の判定 (`firebase/functions/src/core/developer.ts` の `isDeveloper`) が、ユーザーに保存された開発者トークンと Secret の一致を確かめる。トークンを渡していないビルドは一致しない。

**どう使う:**

- プレミアムの付与・デバッグユーザーの作成を含む flow を流す時は、次のビルドを `xcrun simctl install` してから Maestro を実行する (環境変数が空でないことを先に確かめる)

  ```sh
  flutter build ios --simulator \
    --dart-define=SHOPPINGLIST_DEVELOPER_TOKEN="$SHOPPINGLIST_DEVELOPER_TOKEN" \
    --dart-define=REVENUECAT_TEST_STORE_API_KEY="$REVENUECAT_TEST_STORE_API_KEY"
  ```

- flutter-maestro skill の `collect-results.sh` は、flow が FAILED でも「全テスト通過」と出したことがあった。成否は Maestro のログの FAILED の有無と、各手順の COMPLETED で決める
