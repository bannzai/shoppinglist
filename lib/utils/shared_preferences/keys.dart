extension BoolKey on String {
  /// 「買い物リストの更新を通知する」設定。画面を離れた時にグループメンバーへ自動通知するか。
  static const String autoNotifyShoppingListUpdate =
      'autoNotifyShoppingListUpdate';

  /// オンボーディング画面を表示済みか。false のとき未認証ユーザーへ OnboardingPage を出す。
  static const String hasSeenOnboarding = 'hasSeenOnboarding';

  /// 位置情報リマインダーの有効/無効。
  static const String locationReminderEnabled = 'locationReminderEnabled';
}

extension StringKey on String {
  static const String lastSignInFirebaseAuthUserID =
      'lastSignInFirebaseAuthUserID';
}

extension ReleaseNoteKey on String {}

extension IntKey on String {}
