# disabled_shopping_location

位置情報機能（位置情報リマインダー・買い物する場所・店舗ごとのカテゴリ並び順）の E2E フロー置き場。

ファーストリリースでは位置情報機能を UI から隠しているため
(https://github.com/bannzai/shoppinglist/issues/465 、
`lib/utils/config/feature_flags.dart` の `shoppingLocationFeatureEnabled`)、
これらのフローは実行対象の `maestro/flows/` 直下から外している
（`maestro test maestro/flows/` はサブディレクトリを走査しない）。

機能を復活させる際は、フラグを true に戻した上で本ディレクトリのフローを
`maestro/flows/` 直下へ戻すこと。`runFlow: ../shared/...` の相対パスも
`shared/...` へ戻す必要がある。

## フロー一覧
- `location_reminder_non_premium.yaml`: 非プレミアム時に位置情報リマインダーが SnackBar で遮断される
- `premium_location_reminder.yaml`: プレミアム時に位置情報リマインダーを有効化できる
- `category_location_order.yaml`: 店舗作成〜カテゴリ並び順の基本動線
- `category_location_order_non_premium.yaml`: 非プレミアム時の店舗ごと並び順の遮断
- `premium_category_location_order.yaml`: プレミアム時の店舗ごと並び順の適用
