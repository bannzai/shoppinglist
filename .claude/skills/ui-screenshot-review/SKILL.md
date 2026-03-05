# UI Screenshot Review Skill

UIのスクリーンショットを撮影し、確認・改善を行うスキル。

## 使い方

1. シミュレータでプレビューアプリを起動
2. Maestroフローでスクリーンショットを撮影
3. スクリーンショットを確認し、UI改善を実施

## 実行手順

### Step 1: スクリーンショット撮影

```bash
run_maestro_screenshots.sh
```

### Step 2: スクリーンショット確認

`maestro/screenshots/` 内の画像をReadツールで確認する。

### Step 3: UI改善

問題点を分析し、該当するソースファイルを修正する。修正後、再度スクリーンショットを撮影して確認する。

## 画面 → ソースファイル対応表

| # | スクリーンショット | ソースファイル |
|---|---|---|
| 1 | `01_auth_page.png` | `lib/features/auth/page.dart` |
| 2 | `02_home_page.png` | `lib/features/home/page.dart` |
| 3 | `03_shopping_list_page.png` | `lib/features/shopping_list/page.dart` |
| 4 | `04_setting_page.png` | `lib/features/settings/page.dart` |
| 5 | `05_group_list_page.png` | `lib/features/group_list/page.dart` |
| 6 | `06_group_create_page.png` | `lib/features/group_create/page.dart` |
| 7 | `07_group_setting_page.png` | `lib/features/group_setting/page.dart` |
| 8 | `08_group_invitation_accept_page.png` | `lib/features/group_invitation/page.dart` |
| 9 | `09_shopping_location_page.png` | `lib/features/shopping_location/page.dart` |
| 10 | `10_group_shopping_list_item_category_page.png` | `lib/features/group_shopping_list_item_category/page.dart` |
| 11 | `11_group_shopping_list_item_category_edit_page.png` | `lib/features/group_shopping_list_item_category/category_edit_page.dart` |
| 12 | `12_shopping_list_item_filter_page.png` | `lib/features/shopping_list_item_filter/page.dart` |
| 13 | `13_shopping_list_setting_page.png` | `lib/features/shopping_list_setting/page.dart` |

## 関連コンポーネント

- **ShoppingListAppBar**: `lib/features/shopping_list/components/app_bar.dart`
- **ShoppingListItems**: `lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart`
- **GroupSwitcher**: `lib/features/shopping_list/components/group_switcher.dart`
- **スタイル定数**: `lib/style/color.dart`
- **テーマ**: `lib/app.dart` (ThemeData)
- **プレビューアプリテーマ**: `lib/features/previews/preview_app.dart`

## 注意事項

- プレビューではFirebaseが未初期化のため、`SettingPage`の一部機能（プロフィール保存など）は動作しない
- モックデータは `lib/features/previews/mock/mock_data.dart` で定義
- Maestroフローは `maestro/flows/capture_all_previews.yaml`
