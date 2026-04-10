# PR #177 プレミアム機能 動作確認プラン

## Context

PR #177（プレミアム機能11件一括実装、12877行追加）の動作確認リストを、PR #118で構築したQAテスト基盤と同じ形式で作成し、Claudeが自動で動作確認を実行できるようにする。

**前提**: PR #177のブランチ `implement-issue-20260403_190728` にチェックアウトした上で作業する。

## 成果物

`RELEASE_TEST_PLAN.md` をプロジェクトルートに作成する（PR #118のPLAN.mdと同じ形式）。

## Codexレビューで発見された重要事項

### Custom Claims キー名の不整合（要確認）
- `uploadShoppingListItemImage` は `customClaims?.["isPremium"]` で判定
- `generateShoppingListItemsFromImage` / `generateShoppingListItemsFromURL` は `customClaims?.["premium"]` で判定
- PR #206のレビューコメント対応で修正済みの可能性があるが、テスト実行時に確認する

## セクション構成（13セクション）

| No | セクション名 | 検証方法 |
|----|-------------|---------|
| 1 | 自動テスト一括実行 | CLI |
| 2 | テーマカラー変更 | Maestro + mobile-mcp + unit test |
| 3 | AI画像認識の回数制限 | CLI + Maestro + mobile-mcp |
| 4 | URLから買い物リスト生成 | CLI + Maestro + mobile-mcp |
| 5 | 買い物リスト表示期間制限 | CLI + Maestro + mobile-mcp |
| 6 | リスト作成数の上限緩和 | CLI + Maestro + mobile-mcp |
| 7 | グループ作成数の上限緩和 | CLI + Maestro + mobile-mcp |
| 8 | リストのエクスポート | CLI + Maestro + mobile-mcp |
| 9 | カテゴリ並び替え（場所別） | CLI + Maestro + mobile-mcp |
| 10 | アイテムへの写真添付 | CLI + Maestro + mobile-mcp |
| 11 | 位置情報リマインダー | Maestro + mobile-mcp |
| 12 | ホームウィジェット拡張 | mobile-mcp (write-test-mobile-mcp-home-widget) |
| 13 | ビルド確認 | CLI |

## 実行フロー（4フェーズ）

### Phase A: CLI自動テスト（セクション1, 13）

全自動テストを一括実行し、全PASSを確認してからUI検証に進む。

```bash
# セクション1
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
cd firebase/functions && npm test
cd firebase/functions && npm run lint

# セクション13
flutter build ios --no-codesign
cd firebase/functions && npm run build
```

### Phase B: Maestro E2Eテスト一括実行

既存のプレミアム関連Maestroフローを実行（セクション3-11に対応）:

```bash
maestro test maestro/flows/theme_color_setting_non_premium.yaml
maestro test maestro/flows/ai_image_recognition_limit.yaml
maestro test maestro/flows/ai_url_recognition_limit.yaml
maestro test maestro/flows/shopping_list_display_period_non_premium.yaml
maestro test maestro/flows/shopping_list_limit_non_premium.yaml
maestro test maestro/flows/shopping_list_limit_duplicate_non_premium.yaml
maestro test maestro/flows/group_creation_limit_non_premium.yaml
maestro test maestro/flows/export_shopping_list_non_premium.yaml
maestro test maestro/flows/premium_category_location_order.yaml
maestro test maestro/flows/category_location_order.yaml
maestro test maestro/flows/item_photo_attachment_non_premium.yaml
maestro test maestro/flows/location_reminder_non_premium.yaml
```

**注意**: Phase A のビルド確認（セクション13）が成功した後にPhase Bを開始すること（MaestroはiOS Simulatorで動作するため）。

### Phase C: mobile-mcp UI確認（セクション2-12）

匿名サインイン後、以下の順序で確認:

**Part 1: 非プレミアムゲーティング確認**
1. 設定タブ→テーマカラー（セクション2）→SnackBar確認
2. 設定タブ→位置情報リマインダートグル（セクション11）→SnackBar確認
3. 設定タブ→グループ管理→グループ作成上限（セクション7）
4. ホーム画面→30日メッセージ（セクション5）
5. メニュー→「画像から追加」残回数（セクション3）
6. メニュー→「URLから追加」（セクション4）
7. メニュー→「リストをエクスポート」（セクション8）→SnackBar確認
8. 買い物リスト複数作成→上限（セクション6）
9. アイテム追加→詳細→写真添付（セクション10）→SnackBar確認
10. カテゴリ管理→ロケーション別並べ替え（セクション9）→SnackBar確認

**Part 2: 開発者オプションでプレミアム付与→プレミアム機能確認**
11. 開発者オプション→プレミアム付与ボタンタップ
12. テーマカラー選択画面遷移・カラー変更（セクション2）
13. リストのエクスポート→共有シート（セクション8）
14. カテゴリ並び替え→ロケーション別ドラッグ（セクション9）
15. アイテム詳細→写真添付→画像ソース選択（セクション10）
16. 位置情報リマインダートグルON（セクション11）
17. ホームウィジェット確認（セクション12）

### Phase D: エビデンス記録

各確認項目のスクリーンショットを撮影→ `gh-r2-image` でR2にアップロード→RELEASE_TEST_PLAN.mdに `<img src="URL" width="320">` で記載。チェック項目を `- [x]` に更新。

**エビデンス記録ルール**:
- スクリーンショットは撮影直後に `gh-r2-image` でアップロード（まとめて後からは禁止）
- ローカルパスをRELEASE_TEST_PLAN.mdに記載禁止（必ずR2 URL）
- 各セクション完了時にコミット（`git add RELEASE_TEST_PLAN.md && git commit`）
- スキップ項目は「スキップ理由」のみ記載（コードレビューのスクショは不要）

## 各セクションのチェック項目

### セクション 1. 自動テスト一括実行

- [ ] **dart run build_runner build**: freezed/json_serializable/riverpod_generatorの生成ファイルが最新
- [ ] **flutter test**: 全テストPASS（ai_usage, export, group_category_premium, group_creation_limit, shopping_list_display_period, shopping_list_limit, theme_color, sort_categories等）
- [ ] **flutter analyze**: エラーなし
- [ ] **npm test**: 全Firebase Functionsテスト PASS（createGroup, createShoppingList, generateShoppingListItemsFromImage, generateShoppingListItemsFromURL, uploadShoppingListItemImage, deleteShoppingListItemImage等）
- [ ] **npm run lint**: ESLint/Prettierエラーなし

### セクション 2. テーマカラー変更

- [ ] **設定画面にテーマカラーメニュー表示**: 設定タブ→「テーマカラー」ListTile存在
- [ ] **非プレミアムでSnackBar表示**: テーマカラーをタップ→「テーマカラーの変更はプレミアム機能です」SnackBar
- [ ] **Maestro E2E**: theme_color_setting_non_premium.yaml PASS
- [ ] **[Premium] テーマカラー選択画面表示**: 開発者オプションでプレミアム付与後→テーマカラータップ→ThemeColorSelectionPage遷移
- [ ] **[Premium] テーマカラー変更反映**: カラー選択→AppBar等のUI全体に反映

### セクション 3. AI画像認識の回数制限

- [ ] **UserAIUsage定数値**: freeMonthlyImageRecognitionLimit=5, premiumMonthlyImageRecognitionLimit=50
- [ ] **yearMonth UTC変換**: ai_usage_test PASS
- [ ] **残回数の表示**: PopupMenuButton→「画像から追加」で残回数表示
- [ ] **Maestro E2E**: ai_image_recognition_limit.yaml PASS
- [ ] **Firebase Functions テスト**: generateShoppingListItemsFromImage テストPASS

### セクション 4. URLから買い物リスト生成

- [ ] **URL認識定数値**: freeMonthlyURLRecognitionLimit=5, premiumMonthlyURLRecognitionLimit=50
- [ ] **Firebase Function テスト**: generateShoppingListItemsFromURL.test.ts PASS（SSRF対策・OOM対策含む）
- [ ] **Maestro E2E**: ai_url_recognition_limit.yaml PASS
- [ ] **メニュー表示**: PopupMenuButton→「URLから追加」が存在

### セクション 5. 買い物リスト表示期間制限

- [ ] **30日ルールunit test**: shopping_list_display_period_test.dart PASS
- [ ] **無料ユーザーにメッセージ表示**: 「無料プランでは過去30日以内のリストのみ表示されます」
- [ ] **Maestro E2E**: shopping_list_display_period_non_premium.yaml PASS

### セクション 6. リスト作成数の上限緩和

- [ ] **Firebase Function テスト**: createShoppingList.test.ts PASS
- [ ] **unit test**: shopping_list_limit_test.dart PASS
- [ ] **Maestro E2E**: shopping_list_limit_non_premium.yaml PASS
- [ ] **Maestro E2E**: shopping_list_limit_duplicate_non_premium.yaml PASS
- [ ] **mobile-mcp**: 匿名ユーザーで複数リスト作成→上限時のエラー表示

### セクション 7. グループ作成数の上限緩和

- [ ] **Firebase Function テスト**: createGroup.test.ts PASS
- [ ] **unit test**: group_creation_limit_test.dart PASS
- [ ] **Maestro E2E**: group_creation_limit_non_premium.yaml PASS
- [ ] **mobile-mcp**: グループ管理→グループ作成→上限SnackBar

### セクション 8. リストのエクスポート

- [ ] **export_text_formatter unit test**: export_shopping_list_test.dart PASS
- [ ] **非プレミアムでSnackBar**: メニュー→「リストをエクスポート」→SnackBar
- [ ] **Maestro E2E**: export_shopping_list_non_premium.yaml PASS
- [ ] **[Premium] エクスポート実行**: プレミアム付与後→メニュー→「リストをエクスポート」→共有シート表示

### セクション 9. カテゴリ並び替え（場所別）

- [ ] **sortCategoriesByLocation unit test**: sort_categories_by_location_test.dart PASS
- [ ] **Widget test**: group_category_page_premium_test.dart PASS
- [ ] **非プレミアムSnackBar**: ロケーション別並べ替え操作→SnackBar
- [ ] **Maestro E2E**: premium_category_location_order.yaml PASS
- [ ] **[Premium] ロケーション別並び替え実行**: プレミアム付与後→カテゴリ管理→ロケーション選択→ドラッグ並び替え可能

### セクション 10. アイテムへの写真添付

- [ ] **Firebase Function テスト**: uploadShoppingListItemImage.test.ts, deleteShoppingListItemImage.test.ts PASS
- [ ] **非プレミアムSnackBar**: 詳細→「写真を追加」→「商品写真の添付はプレミアム機能です」
- [ ] **Maestro E2E**: item_photo_attachment_non_premium.yaml PASS
- [ ] **[Premium] 写真添付UI表示**: プレミアム付与後→アイテム詳細→「写真を追加」→画像ソース選択ダイアログ表示

### セクション 11. 位置情報リマインダー

- [ ] **設定画面にトグル表示**: 設定→「位置情報リマインダー」トグルが存在
- [ ] **非プレミアムSnackBar**: トグルON→SnackBar表示
- [ ] **Maestro E2E**: location_reminder_non_premium.yaml PASS
- [ ] **[Premium] トグルON可能**: プレミアム付与後→トグルON→位置情報権限ダイアログ表示
- [ ] **ジオフェンス実動作**: スキップ（Simulator位置ストリーム制約。コードレビューで確認）

### セクション 12. ホームウィジェット拡張

- [ ] **テーマカラー連動の同期コード**: HomeWidgetSync が themeColorHex 変更検知→syncThemeColor呼出
- [ ] **プレミアム状態同期**: firestoreIsPremiumProvider 変更検知→syncPremiumStatus呼出
- [ ] **ウィジェット操作テスト**: write-test-mobile-mcp-home-widget skill で検証

### セクション 13. ビルド確認

- [ ] **flutter build ios --no-codesign**: iOSビルド成功
- [ ] **npm run build**: Firebase Functions TypeScriptコンパイル成功

## Claudeで確認困難な項目と対応

| 項目 | 理由 | 対応 |
|------|------|------|
| RevenueCat実課金 | Simulatorで課金不可 | 非プレミアムSnackBarの確認 + unit testでプレミアム時ロジックカバー |
| Custom Claims (isPremium=true) | クライアントから設定不可 | 後述の代替手段を検討 |
| ジオフェンス実動作 | Simulator位置ストリーム制約 | Maestroで非プレミアムSnackBar確認 + コードレビュー |
| 地図ピッカーUI | プレミアムゲート + Maps API制約 | 非プレミアムSnackBar確認のみ |
| Apple/Googleサインイン | OAuth認証フロー | 匿名サインインで代替 |

### プレミアムユーザー動作確認の方法

以下の仕組みを実装し、非プレミアム・プレミアム両方の動作確認を行う:

1. **GenKit Function `grantPromotionalPremium` を追加**: RevenueCat Promotions APIを使い、指定ユーザーにプレミアムEntitlementを付与する。Firebase Functions側のCustom Claims設定も同時に行う
2. **開発者オプションにプレミアム擬似トグル追加**: `lib/features/developer_options/page.dart` に「プレミアム付与」ボタンを追加。タップすると上記Functionを呼び出し、RC Promo経由でプレミアム状態にする
3. **テストフロー**: 匿名サインイン→非プレミアム確認→開発者オプションでプレミアム付与→プレミアム機能確認

**実装が必要なファイル**:
- `firebase/functions/src/functions/grantPromotionalPremium/function.ts` - RC Promo API呼び出し + Custom Claims設定
- `firebase/functions/src/functions/grantPromotionalPremium/function.test.ts` - テスト
- `lib/features/developer_options/page.dart` - プレミアム付与ボタン追加
- `firebase/functions/src/index.ts` - Function登録

## 実装手順

### Step 1: プレミアム付与の仕組みを実装
1. `firebase/functions/src/functions/grantPromotionalPremium/function.ts` を作成
   - RC Promotions API でプレミアムEntitlement付与
   - Firebase Auth Custom Claims に `isPremium: true` を設定
2. `firebase/functions/src/index.ts` にFunction登録
3. `lib/features/developer_options/page.dart` にプレミアム付与ボタン追加
   - タップ→grantPromotionalPremium Function呼び出し→`customerInfoProvider.invalidate()`
4. テスト作成・実行

### Step 2: RELEASE_TEST_PLAN.md を作成
1. PR #177のブランチにチェックアウト
2. RELEASE_TEST_PLAN.md を上記チェック項目の形式で作成

### Step 3: 動作確認を実行
1. Phase A: CLI自動テスト一括実行
2. Phase B: Maestro E2Eテスト一括実行
3. Phase C: mobile-mcp UI確認（Part 1: 非プレミアム → Part 2: プレミアム）
4. Phase D: エビデンス記録・コミット

## 検証方法

プラン実行後、以下で完了を確認:
- RELEASE_TEST_PLAN.md の全チェック項目が `- [x]` になっている
- 各セクションの `#### 動作確認` に `<img>` タグでエビデンス画像が埋め込まれている
- スキップ項目にはスキップ理由が明記されている
