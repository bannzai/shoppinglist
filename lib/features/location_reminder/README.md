# Location Reminder

プレミアムユーザー向けに、店舗に近づいた際のローカル通知を提供する機能。

> **注意**: ファーストリリースでは位置情報機能は UI から隠しており、この機能は動作しない
> (https://github.com/bannzai/shoppinglist/issues/465)。
> 復活手順は `lib/utils/config/feature_flags.dart` の `shoppingLocationFeatureEnabled` を参照。

## 構成
- `geofence_service.dart`: 位置更新を監視し、対象店舗に入ったら通知
- `provider/geofence.dart`: 有効/無効設定と監視開始条件の管理

## 注意点
- 緯度経度が未設定の店舗は監視対象外
- 通知再送は離脱（半径の2倍以上）後に再入域した場合のみ
