# 0034. iOS ウィジェット再描画は reloadAllTimelines 併用・プレミアム同期は RC customerInfo を SSOT とする

## Status

Accepted

## Context

#475「ホームウィジェットがアプリ側の変更(リスト切替・アイテム変更・テーマカラー)に追従して再描画されない」の残課題（Root Cause 2 以降）への対応で、2 つの意思決定が必要になった。

**再描画方式について**: `home_widget` パッケージの `updateWidget()` は iOS で `WidgetCenter.shared.reloadTimelines(ofKind:)` のみを呼ぶ実装で、0.9.0〜0.9.3 の全バージョンで不変（pub-cache のプラグインソースと GitHub の CHANGELOG / PR 差分で確認済み）。`reloadTimelines(ofKind:)` は正しい kind を渡しても再描画が発火しないことがある WidgetKit 側の既知の信頼性問題があり（Apple Developer Forums / StackOverflow で複数報告）、本プロジェクトでも kind・App Group ID が完全一致しているにもかかわらずアプリ本体からの reload が一切効かなかった。一方、ウィジェット拡張内の `ToggleItemIntent` が呼ぶ `WidgetCenter.shared.reloadAllTimelines()` は確実に反映される実績があった。

**プレミアム判定ソースについて**: ウィジェットはテーマカラーを `isPremium ? 同期色 : デフォルト色`（`ShoppingListWidget.swift`）でゲートしているが、同期元だった `firestoreIsPremiumProvider` は Firebase Auth Custom Claims の `isPremium` を読む。Custom Claims は「購入時に設定する経路が存在せず常に false」（#385、`firebase/functions/src/functions/utils/premium.ts`）であるため、実際のプレミアム会員でもウィジェットの `widget_is_premium` は永遠に false になり、再描画が直ってもテーマカラーは反映されない構造だった。

## Decision

1. **アプリ本体からのウィジェット再描画は、`HomeWidget.updateWidget()` に加えて AppDelegate に登録した自前 MethodChannel（`com.bannzai.shoppinglist/home_widget_reload`）経由で `WidgetCenter.shared.reloadAllTimelines()` を併用する。** 本プロジェクトのウィジェット kind は `ShoppingListWidget` 単一のため、`reloadAllTimelines()` と `reloadTimelines(ofKind:)` は実質等価であり副作用はない。

   検討した代替案:
   - **home_widget を 0.9.3 へ更新**: `updateWidget` の iOS 実装が 0.9.0 から不変のため効果がなく不採用（pubspec.lock の差分ノイズも避ける）
   - **home_widget のフォーク / Swift 実装への差分パッチ**: 保守コスト（上流追従・パッチ管理）が自前チャンネル 1 本より高く不採用

2. **ウィジェットへ同期するプレミアム状態（`widget_is_premium`）は RC の `customerInfoProvider.isPremium` を SSOT とする。** これは既存規約「UI 表示用途には customerInfoProvider を使用すること」（`lib/provider/auth_claim.dart`）に沿った変更で、ウィジェットのテーマカラー表示は UI 用途にあたる。`shoppingListsProvider` への `isPremium` 引数（Firestore クエリフィルタ用途）は従来どおり claims ベース（`firestoreIsPremiumProvider`）を維持する。

## Consequences

- アプリ内の変更（アイテム追加・チェック・リスト切替・テーマカラー・プレミアム状態）がウィジェットへ即時反映される（iOS Simulator で E2E 検証済み）
- プレミアム会員のテーマカラーがウィジェットにも反映されるようになる（RC のプロモーション付与・剥奪は `customerInfoProvider` の CustomerInfo 更新として流れてくるため追従する）
- iOS では 1 回の同期で reload リクエストが 2 回（ofKind + all）発行されるが、WidgetKit 側で coalesce されるため実害はない
- `homeWidgetBackgroundCallback`（バックグラウンド isolate）等、AppDelegate のチャンネル登録が無いエンジンから `updateWidget()` が呼ばれた場合は `MissingPluginException` を握って `HomeWidget.updateWidget()` のみで続行する（フォールバックのフォールバック）
- ウィジェット kind を将来複数に増やす場合も `reloadAllTimelines()` は全 kind を更新するため動作するが、特定 kind のみ更新したい要件が出た時はチャンネルの引数設計を見直す必要がある
- Custom Claims ベースの `firestoreIsPremiumProvider` は Firestore クエリフィルタ用途に限定される。claims に isPremium を設定する経路を将来追加する場合は、本 ADR の判定ソース分離を再評価すること
