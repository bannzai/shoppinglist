/// 位置情報機能（買い物する場所・位置情報リマインダー・店舗ごとのカテゴリ並び順）の
/// UI 露出とジオフェンス監視を有効にするかどうか。
///
/// ファーストリリースでは需要が確認できるまで位置情報機能を隠す
/// (https://github.com/bannzai/shoppinglist/issues/465)。
/// 復活させる場合はこの値を true に戻した上で、以下の宣言も復元する:
/// - ios/Runner/Info.plist: UIBackgroundModes への `location`
/// - android/app/src/main/AndroidManifest.xml: 位置情報系 uses-permission 4 件
///   (ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION /
///    ACCESS_BACKGROUND_LOCATION / FOREGROUND_SERVICE_LOCATION)
const bool shoppingLocationFeatureEnabled = false;
