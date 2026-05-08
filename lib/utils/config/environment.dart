// ignore_for_file: constant_identifier_names

enum Flavor {
  DEVELOP,
  PRODUCTION,
  LOCAL, // Local is special flavor for development with firebase:emulators
}

abstract class Environment {
  static bool get isProduction => flavor == Flavor.PRODUCTION;
  static bool get isDevelopment =>
      flavor == Flavor.DEVELOP || flavor == Flavor.LOCAL;
  static bool get isLocal => flavor == Flavor.LOCAL;
  static bool isTest = false;
  static Flavor? flavor;
  // Avoid too, too much CPU usage.
  // Ref: https://github.com/flutter/flutter/issues/13203#issuecomment-430134157
  static bool get disableWidgetAnimation =>
      const bool.fromEnvironment('DISABLE_WIDGET_ANIMATION') && isDevelopment;

  static const siwaServiceIdentifier =
      String.fromEnvironment('SIWA_SERVICE_IDENTIFIIER');
  static const androidSiwaRedirectURL =
      String.fromEnvironment('ANDROID_SIWA_REDIRECT_URL');

  /// ローカル開発用の開発者識別トークン。
  /// dart-define `SHOPPINGLIST_DEVELOPER_TOKEN` から注入される。値が設定されている場合のみ
  /// users/{userID}.developerToken に upsert され、Cloud Functions
  /// (grantPromotionalPremium 等の dev only 関数) でユーザー単位の認可に使われる。
  /// 空文字の場合は本番ユーザービルド扱いで何もしない。
  static const developerToken =
      String.fromEnvironment('SHOPPINGLIST_DEVELOPER_TOKEN');

  static Function()? deleteUser;
  static Function()? signOutUser;
}
