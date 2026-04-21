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

  /// RC Test Store を使うかどうか。
  /// `--dart-define=USE_RC_TEST_STORE=true` で build した場合に true を返す。
  /// Release build では常に false を返す（本番キー誤差し替え防止のガード）。
  static bool get useRCTestStore {
    if (isProduction) return false;
    return const bool.fromEnvironment('USE_RC_TEST_STORE');
  }

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

  static Function()? deleteUser;
  static Function()? signOutUser;
}
