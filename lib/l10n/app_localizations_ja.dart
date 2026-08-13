// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '買い物リスト';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonDone => '完了';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => '削除';

  @override
  String get commonAdd => '追加';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonUndo => '元に戻す';

  @override
  String get commonUpgrade => 'アップグレード';

  @override
  String get commonSettings => '設定';

  @override
  String get commonCategory => 'カテゴリ';

  @override
  String get commonUncategorized => '未分類';

  @override
  String get commonGroup => 'グループ';

  @override
  String get commonCamera => 'カメラ';

  @override
  String get commonPhotoLibrary => 'フォトライブラリ';

  @override
  String get commonErrorOccurred => 'エラーが発生しました';

  @override
  String get errorUnknownTitle => '不明なエラーが発生しました';

  @override
  String get errorUnexpectedTitle => '予期せぬエラーが発生しました';

  @override
  String get errorFaqLink => 'FAQを見る';

  @override
  String get authGoogleSignIn => 'Google でサインイン';

  @override
  String get loadingPreparing => '準備中...';

  @override
  String get accountDeleteButton => 'アカウントを削除する';

  @override
  String get accountDeleteConfirmTitle => 'ユーザー情報を削除します';

  @override
  String get accountDeleteConfirmMessage => 'アカウントを削除すると、ユーザー情報がすべて削除されます。';

  @override
  String get accountDeleteConfirmButton => '削除する';

  @override
  String get accountDeleteReauthTitle => '再ログインしてください';

  @override
  String get accountDeleteReauthMessage => 'アカウントを削除するには、再ログインしてください。';

  @override
  String get accountDeleteReauthButton => '再ログインする';

  @override
  String get accountDeleteCompletedTitle => 'アカウントを削除しました';

  @override
  String get accountDeleteExitAppQuestion => 'アプリを終了しますか？';

  @override
  String get accountDeleteExitAppButton => '終了する';

  @override
  String get shoppingListDefaultName => '買い物リスト';

  @override
  String get shoppingListSettingTooltip => 'リスト設定';

  @override
  String get shoppingListEmptyTitle => '買い物リストがありません';

  @override
  String get shoppingListEmptyMessage => '新しい買い物リストを作成しましょう';

  @override
  String get shoppingListEmptyCreateButton => '買い物リストを作成';

  @override
  String get shoppingListLoadErrorTitle => 'リストを読み込めませんでした';

  @override
  String get shoppingListPickerTitle => 'リストを切り替える';

  @override
  String get shoppingListPickerAddList => '新しいリストを追加';

  @override
  String get shoppingListCreateListTooltip => 'リストを追加';

  @override
  String get shoppingListCreateTodayList => '今日の日付でリストを追加';

  @override
  String get shoppingListDuplicateCurrentList => '現在のリストを複製';

  @override
  String get shoppingListDuplicateUncheckedOnly => '未チェックのみ引き継いで複製';

  @override
  String get shoppingListDuplicated => 'リストを複製しました';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return '$nameから複製';
  }

  @override
  String get shoppingListDeletedListName => '削除済みリスト';

  @override
  String get shoppingListDuplicateSourceDeleted => '複製元の買い物リストは削除されています';

  @override
  String get shoppingListRetentionBannerMessage => '無料プランは作成から30日でリストが整理されます';

  @override
  String get shoppingListRetentionBannerDetail => '詳しく';

  @override
  String get shoppingListSpotlightTitle => '新しい買い物リストはここから追加できます';

  @override
  String get shoppingListSpotlightMessage => '日付ごとのリストを作ったり、今のリストを複製したりできます。';

  @override
  String get shoppingListSpotlightDismiss => 'タップして閉じる';

  @override
  String get shoppingListAiProcessingImage => '画像から候補を抽出中...';

  @override
  String get shoppingListAiProcessingUrl => 'URL から候補を抽出中...';

  @override
  String get shoppingListAiProcessingCategorize => 'カテゴリ分けを実行中...';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '。プレミアムにアップグレードすると月$limit回まで利用できます';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return '自動でカテゴリ分け（$count件）';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return '自動カテゴリ分けの月間利用回数（$limit回）に達しました';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return '$count件をカテゴリに登録しました';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => '自動カテゴリ分け';

  @override
  String get shoppingListAiCategorizeSheetSubtitle => 'カテゴリを確認・調整して登録してください';

  @override
  String get shoppingListAiCategorizeSheetEmpty => '分類できる候補がありませんでした';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return '$count 件を登録';
  }

  @override
  String get shoppingListCategorySelect => 'カテゴリを選択';

  @override
  String get shoppingListCategoryChange => 'カテゴリを変更';

  @override
  String get shoppingListNewCategoryHint => '新しいカテゴリ名';

  @override
  String get shoppingListAddCategoryLabel => 'カテゴリを追加';

  @override
  String get shoppingListAiReviewTitle => '読み取った候補';

  @override
  String get shoppingListAiReviewSubtitle => '追加するアイテムを選んでください';

  @override
  String get shoppingListAiReviewEmpty => '候補がありませんでした';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return '$count 件追加';
  }

  @override
  String get shoppingListFabAddFromPhoto => '写真から追加';

  @override
  String get shoppingListFabAddFromUrl => 'URL から追加';

  @override
  String get shoppingListFabPasteText => 'テキスト貼り付け';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return '画像読み取りの月間利用回数（$limit回）に達しました';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'URL読み取りの月間利用回数（$limit回）に達しました';
  }

  @override
  String get shoppingListUrlDialogTitle => 'URLから買い物リストを生成';

  @override
  String get shoppingListUrlDialogGenerate => '生成';

  @override
  String get shoppingListUrlRequired => 'URLを入力してください';

  @override
  String get shoppingListUrlInvalid => '有効なHTTPS URLを入力してください';

  @override
  String get shoppingListStarterRowLabel => 'タップで入力開始';

  @override
  String get shoppingListHintExample1 => '例: 牛乳 1L';

  @override
  String get shoppingListHintExample2 => '例: 卵 1パック';

  @override
  String get shoppingListHintExample3 => '例: パン';

  @override
  String get shoppingListHintExample4 => '例: 玉ねぎ 2個';

  @override
  String get shoppingListHintExample5 => '例: トマト';

  @override
  String get shoppingListHintCardTitle => 'こんな風に使えます';

  @override
  String get shoppingListHintTap => '・タップしてそのまま入力';

  @override
  String get shoppingListHintReturn => '・return で次の行へ';

  @override
  String get shoppingListHintDelete => '・空行で delete で行を消せます';

  @override
  String get shoppingListHintFabPrefix => '・右下の ';

  @override
  String get shoppingListHintFabSuffix => ' を長押しすると写真やURLから追加できます';

  @override
  String get shoppingListItemDetailTooltip => 'アイテム詳細';

  @override
  String get shoppingListItemDeleteTooltip => 'アイテムを削除';

  @override
  String get shoppingListItemDeleteConfirm => 'このアイテムを削除しますか？';

  @override
  String get shoppingListItemDeleted => 'アイテムを削除しました';

  @override
  String get shoppingListItemMemoHint => 'メモを書く...';

  @override
  String get shoppingListNotifyGroup => 'グループに通知';

  @override
  String get shoppingListNotifyGroupSent => 'グループに通知しました';

  @override
  String get shoppingListNotifyGroupGuideLabel => 'グループ通知の説明';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      'このボタンを押すと、買い物リストを更新したことをグループの他のメンバーにプッシュ通知でお知らせします。';

  @override
  String get shoppingListNotifyGroupSend => '通知を送る';

  @override
  String get commonCopy => 'コピー';

  @override
  String get commonShare => '共有';

  @override
  String get settingsProfileSection => 'プロフィール';

  @override
  String get settingsDisplayNameLabel => '自分の表示名';

  @override
  String get settingsDisplayNameHint => '表示名を入力';

  @override
  String get settingsDisplayNameUpdated => '表示名を更新しました';

  @override
  String get settingsGroupManagement => 'グループ管理';

  @override
  String get settingsJoinGroupWithInvitationCode => '招待コードでグループに参加';

  @override
  String get settingsAppearanceSection => '外観';

  @override
  String get settingsNotificationSection => '通知';

  @override
  String get settingsAboutSection => 'アプリについて';

  @override
  String get settingsTermsOfService => '利用規約';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsCommercialTransactionAct => '特定商法取引法に基づく表記';

  @override
  String get settingsInquiry => 'お問い合わせ';

  @override
  String get settingsOssLicense => 'OSSライセンス';

  @override
  String get settingsDebugSection => 'デバッグ';

  @override
  String get settingsDeveloperOptions => '開発者オプション';

  @override
  String get settingsPremiumCardTitlePremium => 'プレミアム会員';

  @override
  String get settingsPremiumCardTitleFree => 'プレミアムにアップグレード';

  @override
  String get settingsPremiumCardSubtitlePremium => 'すべての機能が利用できます';

  @override
  String get settingsPremiumCardSubtitleFree => '5 色テーマ・画像/URL読み取り回数アップなど';

  @override
  String get settingsPremiumCardStartButton => 'はじめる';

  @override
  String get settingsSignOut => 'サインアウト';

  @override
  String get settingsSignOutConfirmBarrierLabel => 'サインアウト確認';

  @override
  String get settingsSignOutConfirmTitle => 'サインアウトしますか?';

  @override
  String get settingsSignOutConfirmMessage =>
      '再度サインインするまで端末からはリストにアクセスできなくなります。';

  @override
  String get settingsSignOutConfirmMessageGuest =>
      'ゲスト利用中のため、サインアウトすると同じアカウントに再サインインできず、今のリストとグループには二度とアクセスできなくなります。';

  @override
  String get settingsSignOutCompletedTitle => 'サインアウトしました';

  @override
  String get settingsSignOutExitAppMessage => 'アプリを終了します';

  @override
  String get settingsThemeColorTitle => 'テーマカラー';

  @override
  String get settingsThemeColorDescription =>
      '和の伝統色 5 色から選んで、アプリ全体の差し色を切り替えます。';

  @override
  String get settingsThemeColorChanged => 'テーマカラーを変更しました';

  @override
  String settingsThemeColorSwatchLabel(String label) {
    return '$labelのテーマカラー';
  }

  @override
  String get settingsThemeColorPremiumOnly => 'テーマカラーの変更はプレミアム機能です';

  @override
  String get settingsLocationReminderTitle => '位置情報リマインダー';

  @override
  String get settingsLocationReminderSubtitle => '店舗の近くに来たら買い物リストを通知';

  @override
  String get settingsLocationReminderNotificationPermissionRequired =>
      '通知権限を許可すると利用できます';

  @override
  String get settingsLocationReminderAlwaysPermissionRequired =>
      'バックグラウンドの位置情報を「常に許可」にすると利用できます';

  @override
  String get settingsLocationReminderPremiumOnly => '位置情報リマインダーはプレミアム機能です';

  @override
  String get settingsAccountSection => 'アカウント';

  @override
  String get settingsAccountLinked => 'アカウントをリンクしました';

  @override
  String get settingsAccountGuestDescription =>
      'ゲストとして利用中です。アカウントをリンクすると、機種変更後や他の端末でも同じリストとグループを使えます。';

  @override
  String get settingsAccountLinkWithApple => 'Apple でアカウントをリンク';

  @override
  String get settingsAccountLinkWithGoogle => 'Google でアカウントをリンク';

  @override
  String settingsAccountSignedInWith(String providerName) {
    return '$providerName でサインイン済み';
  }

  @override
  String get settingsAccountReSignInBarrierLabel => 'サインインし直し確認';

  @override
  String get settingsAccountAlreadyInUseTitle => 'このアカウントは別のユーザーで使用されています';

  @override
  String get settingsAccountReSignInMessage =>
      'このアカウントでサインインし直しますか?\nサインインし直すと、今のゲストデータ（リスト・グループ）は引き継がれません。';

  @override
  String get settingsAccountReSignInButton => 'サインインし直す';

  @override
  String get listSettingTitle => '買い物リスト設定';

  @override
  String get listSettingNameSection => 'リスト名';

  @override
  String get listSettingShoppingLocationSection => '買い物する場所';

  @override
  String get listSettingLocationUnset => '未設定';

  @override
  String get listSettingLocationChangeDetail => '変更';

  @override
  String get listSettingCategorySubtitle => '自動分類のキーワード管理';

  @override
  String get listSettingStoragePeriodSection => '保存期間';

  @override
  String get listSettingStoragePeriodPremium => 'プレミアム: 無制限';

  @override
  String get listSettingStoragePeriodFree => '作成から30日間';

  @override
  String get listSettingStoragePeriodUpsell => 'プレミアムなら期限なしで残せます';

  @override
  String get listSettingShareSection => '共有';

  @override
  String get listSettingSendInvitationCode => 'グループに招待コードを送る';

  @override
  String get listSettingGroupSetting => 'グループ設定';

  @override
  String get listSettingGroupNameRequired => '招待する前にグループ名を設定してください';

  @override
  String get listSettingListActionsSection => 'リストの操作';

  @override
  String get listSettingDeleteList => 'このリストを削除';

  @override
  String get listSettingDeleteConfirmBarrierLabel => '買い物リスト削除確認';

  @override
  String get listSettingDeleteConfirmTitle => 'このリストを削除しますか?';

  @override
  String listSettingDeleteConfirmMessage(String name, int count) {
    return '「$name」とその中の $count件 のアイテムが削除されます。元に戻せません。';
  }

  @override
  String get listSettingInvitationCodeTitle => '招待コード';

  @override
  String get listSettingInvitationExpired => '有効期限切れ';

  @override
  String listSettingInvitationRemaining(int days, int hours) {
    return '有効期限: 7日間 ・ 残り $days日$hours時間';
  }

  @override
  String get listSettingInvitationCodeCopied => '招待コードをコピーしました';

  @override
  String listSettingInvitationShareText(String code) {
    return '買い物リストの招待コード: $code';
  }

  @override
  String get listSettingSelectShoppingLocationTitle => '買い物する場所を選ぶ';

  @override
  String get listSettingLocationNone => 'なし';

  @override
  String get listSettingLocationSelected => '選択中';

  @override
  String get commonDefault => 'デフォルト';

  @override
  String get commonUnnamed => '名前未設定';

  @override
  String get commonCreating => '作成中...';

  @override
  String get groupNameLabel => 'グループ名';

  @override
  String get groupNameHint => 'グループ名を入力';

  @override
  String get groupCategoryLocationOrderLabel => '買い物する場所の並び順';

  @override
  String get groupCategoryLocationOrderPremiumOnly =>
      '買い物場所ごとのカテゴリ並び替えはプレミアム機能です';

  @override
  String groupCategoryKeywordCount(int count) {
    return 'キーワード: $count件';
  }

  @override
  String groupCategoryDeleteConfirmTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get groupCategoryDeleteConfirmMessage => 'このカテゴリに設定されたキーワードも削除されます';

  @override
  String get groupCategoryEmptyTitle => '買ったものを自動でグループ分け';

  @override
  String get groupCategoryEmptyUseCaseAutoGroup =>
      '「野菜」に トマト・玉ねぎ を登録すると、リストで自動的に野菜セクションにまとまります';

  @override
  String get groupCategoryEmptyUseCaseLocationOrder =>
      '店ごとにカテゴリの並び順を変えられるので、売り場の動線どおりに回れます';

  @override
  String get groupCategoryEditTitle => 'カテゴリ編集';

  @override
  String get groupCategoryEditNotFound => 'カテゴリが見つかりません';

  @override
  String get groupCategoryEditNameLabel => 'カテゴリ名';

  @override
  String get groupCategoryEditNameHint => 'カテゴリ名を入力';

  @override
  String get groupCategoryEditColorLabel => 'カテゴリカラー';

  @override
  String get groupCategoryEditIconLabel => 'カテゴリアイコン';

  @override
  String get groupCategoryEditKeywordsLabel => 'キーワード';

  @override
  String get groupCategoryEditAddKeyword => 'キーワードを追加';

  @override
  String get groupCategoryEditKeywordsEmpty => 'キーワードがまだありません';

  @override
  String get groupCategoryEditKeywordHint => 'キーワードを入力';

  @override
  String get groupCategoryEditMatchingLabel => 'マッチング';

  @override
  String get groupCategoryEditMatchingExact => '完全一致';

  @override
  String get groupCategoryEditMatchingPartial => '部分一致';

  @override
  String get groupCategoryEditMatchingRegex => '正規表現';

  @override
  String get groupCreateTitle => 'グループ作成';

  @override
  String get groupCreateIconLabel => 'アイコン';

  @override
  String get groupCreateSubmit => '作成する';

  @override
  String get groupCreateIconHome => 'いえ';

  @override
  String get groupCreateIconCart => 'カート';

  @override
  String get groupCreateIconFork => 'たべる';

  @override
  String get groupCreateIconCookie => 'おかし';

  @override
  String get groupCreateIconPets => 'ペット';

  @override
  String get groupCreateIconBag => 'バッグ';

  @override
  String get groupCreateInvitationDialogTitle => 'メンバーを招待';

  @override
  String get groupCreateInvitationDialogMessage => '招待コードを家族と共有してください';

  @override
  String get groupInvitationTitle => '招待コードで参加';

  @override
  String get groupInvitationHeading => '招待コードを入力してください';

  @override
  String get groupInvitationDescription => 'グループのメンバーから共有された8桁のコードを入力してください';

  @override
  String get groupInvitationJoining => '参加中...';

  @override
  String get groupInvitationJoin => '参加する';

  @override
  String get groupInvitationVerifyingTitle => '招待コードを確認中';

  @override
  String get groupInvitationVerifyingMessage => 'サーバー側でグループへの参加を処理しています。';

  @override
  String get groupJoinHeading => 'はじめましょう';

  @override
  String get groupJoinDescription =>
      '家族やパートナーから招待コードを受け取っていますか？\nコードで参加すると同じ買い物リストを一緒に使えます。';

  @override
  String get groupJoinCreateSolo => '自分のリストを作る';

  @override
  String get groupListEmpty => '所属しているグループはありません';

  @override
  String groupListMemberCount(int count) {
    return 'メンバー $count人';
  }

  @override
  String get groupListFreeLimitBanner => '無料プランは追加 1 グループまで';

  @override
  String get groupListFreeLimitAction => '解除';

  @override
  String get groupSettingMembersSection => 'メンバー一覧';

  @override
  String get groupSettingMemberOwner => 'オーナー';

  @override
  String get groupSettingMemberSelf => '自分';

  @override
  String get groupSettingMemberFallbackName => 'メンバー';

  @override
  String get groupSettingShoppingLocationSubtitle => '店舗の登録・編集';

  @override
  String get groupSettingInvitationSection => 'グループ招待';

  @override
  String get groupSettingCreatingInvitation => '招待コードを発行中...';

  @override
  String get groupSettingCreateInvitation => '招待コードを発行';

  @override
  String groupSettingRemoveMemberConfirmTitle(String name) {
    return '$nameをグループから削除しますか？';
  }

  @override
  String get groupSettingRemoveMemberConfirmMessage =>
      '削除されたメンバーはこのグループにアクセスできなくなります';

  @override
  String groupSettingMemberRemoved(String name) {
    return '$nameを削除しました';
  }

  @override
  String get groupSettingInvitationCodeMessage => '以下のコードを共有してください';

  @override
  String get groupSettingInvitationExpiry => '有効期限: 7日間';

  @override
  String get commonSave => '保存';

  @override
  String get authHeroTitle => '家族の買い物を、\nひとつのリストへ';

  @override
  String get authHeroDescription =>
      'サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。';

  @override
  String get authStartWithoutSignIn => 'サインインせずにはじめる';

  @override
  String get authLinkAccountLaterNote => 'あとから設定画面でアカウントをリンクできます';

  @override
  String authAgreementNote(String terms, String privacy) {
    return '続けることで $terms と $privacy に同意したものとみなされます。';
  }

  @override
  String get inquiryDescription =>
      'いただいた内容は開発の参考にさせていただきます。返信が必要な場合はご連絡先のメールアドレスをご記入ください。';

  @override
  String get inquiryEmailLabel => 'メールアドレス';

  @override
  String get inquiryEmailRequired => 'メールアドレスを入力してください';

  @override
  String get inquiryEmailInvalid => 'メールアドレスの形式が正しくありません';

  @override
  String get inquiryCategoryLabel => 'お問い合わせの種類';

  @override
  String get inquiryCategoryRequired => 'お問い合わせの種類を選択してください';

  @override
  String get inquiryContentLabel => 'お問い合わせ内容';

  @override
  String get inquiryContentRequired => 'お問い合わせ内容を入力してください';

  @override
  String get inquiryContentHint => 'お困りの内容やご要望をご記入ください';

  @override
  String get inquirySubmitting => '送信中...';

  @override
  String get inquirySubmit => '送信する';

  @override
  String get inquirySubmitted => 'お問い合わせを送信しました';

  @override
  String get notificationPermissionBarrierLabel => 'プッシュ通知の許可';

  @override
  String get notificationPermissionTitle => 'プッシュ通知を受け取ろう';

  @override
  String get notificationPermissionMessage =>
      'グループのメンバーが買い物リストを更新して知らせたときに、プッシュ通知ですぐに気づけます。次に表示される確認で通知を許可してください。';

  @override
  String get notificationPermissionLater => 'あとで';

  @override
  String get notificationPermissionAllow => '通知を許可';

  @override
  String get onboardingSlide1Title => '家族と作る、\n買い物リスト';

  @override
  String get onboardingSlide1Body =>
      '家で思いついたものを誰かが追加して、店頭で別の誰かがチェック。「買ってきて」のやり取りを、ぜんぶこの一枚に。';

  @override
  String get onboardingSlide2Title => '同じリストを\n同時に編集';

  @override
  String get onboardingSlide2Body =>
      '家族・パートナー・同居人を招待コードで招くと、同じリストを編集できます。誰が追加したかではなく、何を買い忘れずに済むかを大切に。';

  @override
  String get onboardingSlide3Title => 'お店の近くで、\nそっと思い出す';

  @override
  String get onboardingSlide3Body =>
      '登録した店舗の近くに来ると、買い物リストをやさしくお知らせ。通知は必要な時だけ、押し付けがましくなく。';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingStart => 'はじめる';

  @override
  String get onboardingNext => '次へ';

  @override
  String get paywallHeroTitle => 'プレミアムにアップグレード';

  @override
  String get paywallHeroDescription => '全機能を解放して、家族みんなで気持ちよく使えます。';

  @override
  String get paywallFeatureLocationOrder => '店舗ごとの並び順';

  @override
  String get paywallFeaturePhotoExtraction => '写真からのアイテム抽出（月 50 回）';

  @override
  String get paywallFeatureUrlExtraction => 'URL からのアイテム抽出（月 50 回）';

  @override
  String get paywallFeatureThemeColors => '5 色のテーマカラー';

  @override
  String get paywallFeatureUnlimitedRetention => 'リスト保存期間が無制限';

  @override
  String get paywallFeatureReceipt => 'リストにレシートを保存';

  @override
  String get paywallSubscriptionNote => 'いつでもキャンセル可能・自動更新は購入後 24 時間前まで';

  @override
  String get paywallPrivacyLink => 'プライバシー';

  @override
  String get paywallRestore => '復元';

  @override
  String get paywallRestored => '購入を復元しました';

  @override
  String get paywallNoPlans => '現在ご利用いただけるプランがありません';

  @override
  String get paywallRecommendedBadge => 'おすすめ';

  @override
  String get paywallPurchaseCompleted => '購入ありがとうございました';

  @override
  String get paywallPurchaseButton => '購入';

  @override
  String get receiptAdd => 'レシートを追加';

  @override
  String get receiptEdit => 'レシートを編集';

  @override
  String get receiptSheetTitle => 'レシート';

  @override
  String get receiptTakePhoto => 'カメラで撮影';

  @override
  String get receiptChooseFromLibrary => 'フォトライブラリから選択';

  @override
  String get receiptAmountLabel => '金額';

  @override
  String get receiptMemoLabel => 'メモ';

  @override
  String get receiptMemoHint => '店名や購入品などのメモ';

  @override
  String get receiptCaptureOrSelect => 'レシートを撮影 / 選択';

  @override
  String get forceUpdateTitle => 'アプリをアップデートしてください';

  @override
  String forceUpdateMessage(String storeName) {
    return 'お使いのアプリのバージョンのアップデートをお願いしております。$storeNameから最新バージョンにアップデートしてください';
  }

  @override
  String get shoppingLocationTitle => '買い物する場所';

  @override
  String get shoppingLocationEmpty => '買い物する場所がまだありません';

  @override
  String get shoppingLocationGeoConfigured => '位置情報設定済み';

  @override
  String get shoppingLocationAddTitle => '場所を追加';

  @override
  String get shoppingLocationEditTitle => '場所を編集';

  @override
  String get shoppingLocationNameHint => '場所の名前';

  @override
  String get shoppingLocationNameHintWithExample => '場所の名前（例: スーパー）';

  @override
  String get shoppingLocationPositionSet => '位置設定済み';

  @override
  String get shoppingLocationSetOnMap => '地図で場所を設定';

  @override
  String shoppingLocationDeleteConfirmTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get shoppingLocationDeleteConfirmMessage =>
      'この場所を削除しても、この場所が設定されている買い物リストには影響しません';

  @override
  String get shoppingLocationPickerTitle => '場所を地図で選択';

  @override
  String get shoppingLocationPickerConfirm => 'この場所を設定';

  @override
  String get settingsThemeColorShu => '朱';

  @override
  String get settingsThemeColorMatcha => '抹茶';

  @override
  String get settingsThemeColorAi => '藍';

  @override
  String get settingsThemeColorSumi => '墨';

  @override
  String get settingsThemeColorKuchiba => '朽葉';

  @override
  String get inquiryCategoryBugReport => '不具合報告';

  @override
  String get inquiryCategoryHowToUse => '操作方法について';

  @override
  String get inquiryCategoryRequest => 'ご要望・改善要望';

  @override
  String get inquiryCategoryOther => 'その他';

  @override
  String shoppingListLimitExceeded(int limit) {
    return '無料プランでは1グループあたり$limit個までリストを作成できます。プレミアムにアップグレードすると無制限に作成できます';
  }
}
