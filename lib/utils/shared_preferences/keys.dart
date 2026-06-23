extension BoolKey on String {
  /// オンボーディング画面を表示済みか。false のとき未認証ユーザーへ OnboardingPage を出す。
  static const String hasSeenOnboarding = 'hasSeenOnboarding';

  /// 位置情報リマインダーの有効/無効。
  static const String locationReminderEnabled = 'locationReminderEnabled';

  /// グループ通知ボタンの初回説明ダイアログを表示済みか。
  /// 初回タップ時のみダイアログを出し、確定後に true を保存する(Issue #449)。
  static const String hasSeenManualNotifyGuide = 'hasSeenManualNotifyGuide';
}

extension StringKey on String {
  static const String lastSignInFirebaseAuthUserID =
      'lastSignInFirebaseAuthUserID';
}

extension ReleaseNoteKey on String {}

extension IntKey on String {}
