extension BoolKey on String {
  /// オンボーディング画面を表示済みか。false のとき未認証ユーザーへ OnboardingPage を出す。
  static const String hasSeenOnboarding = 'hasSeenOnboarding';

  /// 位置情報リマインダーの有効/無効。
  static const String locationReminderEnabled = 'locationReminderEnabled';

  /// グループ通知ボタンの初回説明ダイアログを表示済みか。
  /// 初回タップ時のみダイアログを出し、確定後に true を保存する(Issue #449)。
  static const String hasSeenManualNotifyGuide = 'hasSeenManualNotifyGuide';

  /// 通知許可の requestPermission を一度でも実行したか。
  /// Android は authorizationStatus が authorized / denied にしかマップされず、
  /// 未要求でも denied を返して notDetermined と区別できないため、
  /// 要求済みかどうかをアプリ側で追跡する必要がある(Issue #500)。
  static const String hasRequestedNotificationPermission =
      'hasRequestedNotificationPermission';

  /// OS 標準のストア評価依頼 (in_app_review の requestReview) を一度でも呼んだか。
  /// true なら以後は呼ばない (生涯 1 回のみ。Issue #651)。
  static const String hasRequestedStoreReview = 'hasRequestedStoreReview';
}

extension StringKey on String {
  static const String lastSignInFirebaseAuthUserID =
      'lastSignInFirebaseAuthUserID';

  /// リスト追加スポットライトを最後に表示した日時(ISO8601 文字列)。
  /// 非 null = 表示済みとして、以後の表示を抑止する判定に使う(Issue #494, #508: 生涯1回のみ)。
  static const String createListSpotlightLastShownDateTime =
      'createListSpotlightLastShownDateTime';
}

extension ReleaseNoteKey on String {}

extension IntKey on String {
  /// 買い物リストのアイテムを「買った」にチェックした累計回数 (チェック解除は数えない)。
  /// ストア評価依頼を出すタイミングの判定に使う (Issue #651)。
  static const String purchasedItemCheckCount = 'purchasedItemCheckCount';
}
