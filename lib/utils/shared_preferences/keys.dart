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

  /// リスト追加スポットライトを最後に表示した日時(ISO8601 文字列)。
  /// 「その日」「そのチェック機会」に対して表示済みかの重複判定に使う(Issue #494)。
  static const String createListSpotlightLastShownDateTime =
      'createListSpotlightLastShownDateTime';
}

extension ReleaseNoteKey on String {}

extension IntKey on String {}
