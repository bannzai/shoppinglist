import 'dart:io';

import 'package:shoppinglist/l10n/l10n.dart';

String get storeName {
  return Platform.isIOS ? 'App Store' : 'Google Play';
}

/// 購入エラー文言に埋め込む端末アカウントの名称。
/// iOS の 'Apple ID' は固有名詞のためロケールによらず固定。
String accountName(AppLocalizations l10n) {
  return Platform.isIOS ? 'Apple ID' : l10n.platformGoogleAccountName;
}

String get forceUpdateStoreURL {
  return Platform.isIOS
      ? 'https://apps.apple.com/app/apple-store/id6739724511?pt=97327896&ct=force_update&mt=8'
      : '';
}
