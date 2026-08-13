import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// アプリ名。MaterialApp の title (タスクスイッチャー等 OS 表示用)
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// プレミアムへのアップグレードを促す SnackBar のアクションラベル
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get commonUpgrade;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get commonCategory;

  /// カテゴリが未設定のアイテムをまとめるセクション名
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get commonUncategorized;

  /// グループ名が未設定のときのフォールバック表示と、設定画面の「グループ」セクション見出し
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get commonGroup;

  /// No description provided for @commonCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get commonCamera;

  /// No description provided for @commonPhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get commonPhotoLibrary;

  /// No description provided for @commonErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get commonErrorOccurred;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnexpectedTitle.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnexpectedTitle;

  /// エラーダイアログから FAQ ページを開くボタン
  ///
  /// In en, this message translates to:
  /// **'View FAQ'**
  String get errorFaqLink;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authGoogleSignIn;

  /// 全画面ローディング中に出す文言
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get loadingPreparing;

  /// No description provided for @accountDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteButton;

  /// No description provided for @accountDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account information'**
  String get accountDeleteConfirmTitle;

  /// No description provided for @accountDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will remove all of your user information.'**
  String get accountDeleteConfirmMessage;

  /// アカウント削除確認ダイアログの実行ボタン (日本語では「削除する」で汎用の「削除」と区別している)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDeleteConfirmButton;

  /// No description provided for @accountDeleteReauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get accountDeleteReauthTitle;

  /// No description provided for @accountDeleteReauthMessage.
  ///
  /// In en, this message translates to:
  /// **'To delete your account, please sign in again.'**
  String get accountDeleteReauthMessage;

  /// No description provided for @accountDeleteReauthButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get accountDeleteReauthButton;

  /// No description provided for @accountDeleteCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get accountDeleteCompletedTitle;

  /// No description provided for @accountDeleteExitAppQuestion.
  ///
  /// In en, this message translates to:
  /// **'Quit the app?'**
  String get accountDeleteExitAppQuestion;

  /// No description provided for @accountDeleteExitAppButton.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get accountDeleteExitAppButton;

  /// リスト名が未設定のときに上部バーへ出すフォールバック表示
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListDefaultName;

  /// No description provided for @shoppingListSettingTooltip.
  ///
  /// In en, this message translates to:
  /// **'List settings'**
  String get shoppingListSettingTooltip;

  /// No description provided for @shoppingListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shopping lists yet'**
  String get shoppingListEmptyTitle;

  /// No description provided for @shoppingListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a new shopping list'**
  String get shoppingListEmptyMessage;

  /// No description provided for @shoppingListEmptyCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create shopping list'**
  String get shoppingListEmptyCreateButton;

  /// No description provided for @shoppingListLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the list'**
  String get shoppingListLoadErrorTitle;

  /// No description provided for @shoppingListPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch list'**
  String get shoppingListPickerTitle;

  /// No description provided for @shoppingListPickerAddList.
  ///
  /// In en, this message translates to:
  /// **'Add a new list'**
  String get shoppingListPickerAddList;

  /// No description provided for @shoppingListCreateListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add list'**
  String get shoppingListCreateListTooltip;

  /// No description provided for @shoppingListCreateTodayList.
  ///
  /// In en, this message translates to:
  /// **'Add a list with the current date'**
  String get shoppingListCreateTodayList;

  /// No description provided for @shoppingListDuplicateCurrentList.
  ///
  /// In en, this message translates to:
  /// **'Duplicate the current list'**
  String get shoppingListDuplicateCurrentList;

  /// No description provided for @shoppingListDuplicateUncheckedOnly.
  ///
  /// In en, this message translates to:
  /// **'Duplicate with unchecked items only'**
  String get shoppingListDuplicateUncheckedOnly;

  /// No description provided for @shoppingListDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Duplicated the list'**
  String get shoppingListDuplicated;

  /// 複製で作られたリストの上部に出す、複製元リストへの導線ラベル
  ///
  /// In en, this message translates to:
  /// **'Duplicated from {name}'**
  String shoppingListDuplicatedFrom(String name);

  /// 複製元リストが既に削除済みのときの表示名
  ///
  /// In en, this message translates to:
  /// **'Deleted list'**
  String get shoppingListDeletedListName;

  /// No description provided for @shoppingListDuplicateSourceDeleted.
  ///
  /// In en, this message translates to:
  /// **'The original shopping list has been deleted'**
  String get shoppingListDuplicateSourceDeleted;

  /// No description provided for @shoppingListRetentionBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'On the free plan, lists are cleaned up 30 days after they are created'**
  String get shoppingListRetentionBannerMessage;

  /// No description provided for @shoppingListRetentionBannerDetail.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get shoppingListRetentionBannerDetail;

  /// No description provided for @shoppingListSpotlightTitle.
  ///
  /// In en, this message translates to:
  /// **'You can add a new shopping list here'**
  String get shoppingListSpotlightTitle;

  /// No description provided for @shoppingListSpotlightMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a list for each date, or duplicate the list you are using now.'**
  String get shoppingListSpotlightMessage;

  /// No description provided for @shoppingListSpotlightDismiss.
  ///
  /// In en, this message translates to:
  /// **'Tap to close'**
  String get shoppingListSpotlightDismiss;

  /// No description provided for @shoppingListAiProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Extracting suggestions from the photo...'**
  String get shoppingListAiProcessingImage;

  /// No description provided for @shoppingListAiProcessingUrl.
  ///
  /// In en, this message translates to:
  /// **'Extracting suggestions from the URL...'**
  String get shoppingListAiProcessingUrl;

  /// No description provided for @shoppingListAiProcessingCategorize.
  ///
  /// In en, this message translates to:
  /// **'Sorting into categories...'**
  String get shoppingListAiProcessingCategorize;

  /// AI 機能の月間上限に達した SnackBar で、無料プランのときだけ上限メッセージの末尾へ連結する文
  ///
  /// In en, this message translates to:
  /// **'. Upgrade to Premium and you can use it up to {limit} times a month'**
  String shoppingListAiLimitUpsell(int limit);

  /// 未分類アイテムを AI でカテゴリ分けするボタン。件数は未分類アイテム数
  ///
  /// In en, this message translates to:
  /// **'Auto-categorize ({count} items)'**
  String shoppingListAiCategorizeButton(int count);

  /// No description provided for @shoppingListAiCategorizeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'The monthly limit for auto-categorization ({limit} times) has been reached'**
  String shoppingListAiCategorizeLimitReached(int limit);

  /// No description provided for @shoppingListAiCategorizeRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered {count} items into categories'**
  String shoppingListAiCategorizeRegistered(int count);

  /// No description provided for @shoppingListAiCategorizeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-categorize'**
  String get shoppingListAiCategorizeSheetTitle;

  /// No description provided for @shoppingListAiCategorizeSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and adjust the categories before registering them'**
  String get shoppingListAiCategorizeSheetSubtitle;

  /// No description provided for @shoppingListAiCategorizeSheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items could be categorized'**
  String get shoppingListAiCategorizeSheetEmpty;

  /// No description provided for @shoppingListAiCategorizeSheetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Register {count} items'**
  String shoppingListAiCategorizeSheetConfirm(int count);

  /// No description provided for @shoppingListCategorySelect.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get shoppingListCategorySelect;

  /// No description provided for @shoppingListCategoryChange.
  ///
  /// In en, this message translates to:
  /// **'Change category'**
  String get shoppingListCategoryChange;

  /// No description provided for @shoppingListNewCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get shoppingListNewCategoryHint;

  /// 未分類アイテムの行に出す「カテゴリ +」ボタンの読み上げラベル
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get shoppingListAddCategoryLabel;

  /// No description provided for @shoppingListAiReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Extracted suggestions'**
  String get shoppingListAiReviewTitle;

  /// No description provided for @shoppingListAiReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the items you want to add'**
  String get shoppingListAiReviewSubtitle;

  /// No description provided for @shoppingListAiReviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suggestions were found'**
  String get shoppingListAiReviewEmpty;

  /// No description provided for @shoppingListAiReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add {count} items'**
  String shoppingListAiReviewConfirm(int count);

  /// No description provided for @shoppingListFabAddFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add from photo'**
  String get shoppingListFabAddFromPhoto;

  /// No description provided for @shoppingListFabAddFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Add from URL'**
  String get shoppingListFabAddFromUrl;

  /// No description provided for @shoppingListFabPasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get shoppingListFabPasteText;

  /// No description provided for @shoppingListImageRecognitionLimitReached.
  ///
  /// In en, this message translates to:
  /// **'The monthly limit for photo recognition ({limit} times) has been reached'**
  String shoppingListImageRecognitionLimitReached(int limit);

  /// No description provided for @shoppingListUrlRecognitionLimitReached.
  ///
  /// In en, this message translates to:
  /// **'The monthly limit for URL recognition ({limit} times) has been reached'**
  String shoppingListUrlRecognitionLimitReached(int limit);

  /// No description provided for @shoppingListUrlDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a shopping list from a URL'**
  String get shoppingListUrlDialogTitle;

  /// No description provided for @shoppingListUrlDialogGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get shoppingListUrlDialogGenerate;

  /// No description provided for @shoppingListUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a URL'**
  String get shoppingListUrlRequired;

  /// No description provided for @shoppingListUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid HTTPS URL'**
  String get shoppingListUrlInvalid;

  /// No description provided for @shoppingListStarterRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to start typing'**
  String get shoppingListStarterRowLabel;

  /// No description provided for @shoppingListHintExample1.
  ///
  /// In en, this message translates to:
  /// **'e.g. Milk 1L'**
  String get shoppingListHintExample1;

  /// No description provided for @shoppingListHintExample2.
  ///
  /// In en, this message translates to:
  /// **'e.g. Eggs, 1 pack'**
  String get shoppingListHintExample2;

  /// No description provided for @shoppingListHintExample3.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bread'**
  String get shoppingListHintExample3;

  /// No description provided for @shoppingListHintExample4.
  ///
  /// In en, this message translates to:
  /// **'e.g. Onions x2'**
  String get shoppingListHintExample4;

  /// No description provided for @shoppingListHintExample5.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tomatoes'**
  String get shoppingListHintExample5;

  /// No description provided for @shoppingListHintCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Here is how to use it'**
  String get shoppingListHintCardTitle;

  /// No description provided for @shoppingListHintTap.
  ///
  /// In en, this message translates to:
  /// **'・Tap a row and type right away'**
  String get shoppingListHintTap;

  /// No description provided for @shoppingListHintReturn.
  ///
  /// In en, this message translates to:
  /// **'・Press return to move to the next line'**
  String get shoppingListHintReturn;

  /// No description provided for @shoppingListHintDelete.
  ///
  /// In en, this message translates to:
  /// **'・Press delete on an empty line to remove it'**
  String get shoppingListHintDelete;

  /// ヒント文「・右下の [アイコン] を長押しすると…」のアイコンより前の部分。末尾の空白はアイコンとの間隔
  ///
  /// In en, this message translates to:
  /// **'・Long-press the '**
  String get shoppingListHintFabPrefix;

  /// ヒント文「・右下の [アイコン] を長押しすると…」のアイコンより後の部分。先頭の空白はアイコンとの間隔
  ///
  /// In en, this message translates to:
  /// **' at the bottom right to add from a photo or a URL'**
  String get shoppingListHintFabSuffix;

  /// No description provided for @shoppingListItemDetailTooltip.
  ///
  /// In en, this message translates to:
  /// **'Item details'**
  String get shoppingListItemDetailTooltip;

  /// No description provided for @shoppingListItemDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get shoppingListItemDeleteTooltip;

  /// No description provided for @shoppingListItemDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get shoppingListItemDeleteConfirm;

  /// No description provided for @shoppingListItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted the item'**
  String get shoppingListItemDeleted;

  /// No description provided for @shoppingListItemMemoHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note...'**
  String get shoppingListItemMemoHint;

  /// グループ通知ボタンの tooltip と、初回タップ時の説明ダイアログのタイトル
  ///
  /// In en, this message translates to:
  /// **'Notify group'**
  String get shoppingListNotifyGroup;

  /// No description provided for @shoppingListNotifyGroupSent.
  ///
  /// In en, this message translates to:
  /// **'Notified the group'**
  String get shoppingListNotifyGroupSent;

  /// No description provided for @shoppingListNotifyGroupGuideLabel.
  ///
  /// In en, this message translates to:
  /// **'About group notifications'**
  String get shoppingListNotifyGroupGuideLabel;

  /// No description provided for @shoppingListNotifyGroupGuideMessage.
  ///
  /// In en, this message translates to:
  /// **'Tapping this button sends a push notification to the other members of your group to let them know you updated the shopping list.'**
  String get shoppingListNotifyGroupGuideMessage;

  /// No description provided for @shoppingListNotifyGroupSend.
  ///
  /// In en, this message translates to:
  /// **'Send notification'**
  String get shoppingListNotifyGroupSend;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// 共有アクションのボタンラベル (動詞)。セクション見出しの「共有」は listSettingShareSection
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your display name'**
  String get settingsDisplayNameLabel;

  /// No description provided for @settingsDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get settingsDisplayNameHint;

  /// No description provided for @settingsDisplayNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated your display name'**
  String get settingsDisplayNameUpdated;

  /// No description provided for @settingsGroupManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get settingsGroupManagement;

  /// No description provided for @settingsJoinGroupWithInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Join a group with an invitation code'**
  String get settingsJoinGroupWithInvitationCode;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsNotificationSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationSection;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get settingsAboutSection;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// 特定商取引法に基づく表記ページへの導線。日本語の現行文言は「特定商法取引法」という表記のまま (既存 UI を変えないため)
  ///
  /// In en, this message translates to:
  /// **'Notation based on the Specified Commercial Transaction Act'**
  String get settingsCommercialTransactionAct;

  /// No description provided for @settingsInquiry.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsInquiry;

  /// No description provided for @settingsOssLicense.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get settingsOssLicense;

  /// debug ビルドでのみ表示する設定セクション
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsDebugSection;

  /// No description provided for @settingsDeveloperOptions.
  ///
  /// In en, this message translates to:
  /// **'Developer options'**
  String get settingsDeveloperOptions;

  /// No description provided for @settingsPremiumCardTitlePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium member'**
  String get settingsPremiumCardTitlePremium;

  /// No description provided for @settingsPremiumCardTitleFree.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get settingsPremiumCardTitleFree;

  /// No description provided for @settingsPremiumCardSubtitlePremium.
  ///
  /// In en, this message translates to:
  /// **'You can use all features'**
  String get settingsPremiumCardSubtitlePremium;

  /// No description provided for @settingsPremiumCardSubtitleFree.
  ///
  /// In en, this message translates to:
  /// **'Five color themes, more photo/URL scans, and more'**
  String get settingsPremiumCardSubtitleFree;

  /// No description provided for @settingsPremiumCardStartButton.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get settingsPremiumCardStartButton;

  /// サインアウトボタンのラベルと、確認ダイアログの実行ボタン
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// サインアウト確認ダイアログの barrierLabel (画面読み上げ用。画面には表示されない)
  ///
  /// In en, this message translates to:
  /// **'Sign-out confirmation'**
  String get settingsSignOutConfirmBarrierLabel;

  /// No description provided for @settingsSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutConfirmTitle;

  /// No description provided for @settingsSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to access your lists from this device until you sign in again.'**
  String get settingsSignOutConfirmMessage;

  /// No description provided for @settingsSignOutConfirmMessageGuest.
  ///
  /// In en, this message translates to:
  /// **'You are using the app as a guest, so if you sign out you cannot sign in to the same account again and you will permanently lose access to your current lists and groups.'**
  String get settingsSignOutConfirmMessageGuest;

  /// No description provided for @settingsSignOutCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get settingsSignOutCompletedTitle;

  /// No description provided for @settingsSignOutExitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'The app will now quit'**
  String get settingsSignOutExitAppMessage;

  /// No description provided for @settingsThemeColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get settingsThemeColorTitle;

  /// No description provided for @settingsThemeColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose from five traditional Japanese colors to change the accent color used across the app.'**
  String get settingsThemeColorDescription;

  /// No description provided for @settingsThemeColorChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed the theme color'**
  String get settingsThemeColorChanged;

  /// テーマカラーの色見本の読み上げラベル。label はプリセットの色名 (lib/style/tokens.dart の AccentPreset.label)
  ///
  /// In en, this message translates to:
  /// **'{label} theme color'**
  String settingsThemeColorSwatchLabel(String label);

  /// No description provided for @settingsThemeColorPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Changing the theme color is a Premium feature'**
  String get settingsThemeColorPremiumOnly;

  /// No description provided for @settingsLocationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Location reminder'**
  String get settingsLocationReminderTitle;

  /// No description provided for @settingsLocationReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify me of my shopping list when I am near a store'**
  String get settingsLocationReminderSubtitle;

  /// No description provided for @settingsLocationReminderNotificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to use this feature'**
  String get settingsLocationReminderNotificationPermissionRequired;

  /// No description provided for @settingsLocationReminderAlwaysPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Set background location access to \"Always\" to use this feature'**
  String get settingsLocationReminderAlwaysPermissionRequired;

  /// No description provided for @settingsLocationReminderPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'The location reminder is a Premium feature'**
  String get settingsLocationReminderPremiumOnly;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsAccountLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked your account'**
  String get settingsAccountLinked;

  /// No description provided for @settingsAccountGuestDescription.
  ///
  /// In en, this message translates to:
  /// **'You are using the app as a guest. If you link an account, you can use the same lists and groups after changing devices or on another device.'**
  String get settingsAccountGuestDescription;

  /// No description provided for @settingsAccountLinkWithApple.
  ///
  /// In en, this message translates to:
  /// **'Link your account with Apple'**
  String get settingsAccountLinkWithApple;

  /// No description provided for @settingsAccountLinkWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Link your account with Google'**
  String get settingsAccountLinkWithGoogle;

  /// リンク済みの認証プロバイダを表示する行。providerName は 'Apple' / 'Google'
  ///
  /// In en, this message translates to:
  /// **'Signed in with {providerName}'**
  String settingsAccountSignedInWith(String providerName);

  /// サインインし直し確認ダイアログの barrierLabel (画面読み上げ用。画面には表示されない)
  ///
  /// In en, this message translates to:
  /// **'Re-sign-in confirmation'**
  String get settingsAccountReSignInBarrierLabel;

  /// No description provided for @settingsAccountAlreadyInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'This account is already used by another user'**
  String get settingsAccountAlreadyInUseTitle;

  /// No description provided for @settingsAccountReSignInMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign in again with this account?\nIf you sign in again, your current guest data (lists and groups) will not be carried over.'**
  String get settingsAccountReSignInMessage;

  /// No description provided for @settingsAccountReSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get settingsAccountReSignInButton;

  /// No description provided for @listSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list settings'**
  String get listSettingTitle;

  /// No description provided for @listSettingNameSection.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listSettingNameSection;

  /// No description provided for @listSettingShoppingLocationSection.
  ///
  /// In en, this message translates to:
  /// **'Shopping location'**
  String get listSettingShoppingLocationSection;

  /// No description provided for @listSettingLocationUnset.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get listSettingLocationUnset;

  /// No description provided for @listSettingLocationChangeDetail.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get listSettingLocationChangeDetail;

  /// No description provided for @listSettingCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage keywords for auto-categorization'**
  String get listSettingCategorySubtitle;

  /// No description provided for @listSettingStoragePeriodSection.
  ///
  /// In en, this message translates to:
  /// **'Retention period'**
  String get listSettingStoragePeriodSection;

  /// No description provided for @listSettingStoragePeriodPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium: unlimited'**
  String get listSettingStoragePeriodPremium;

  /// No description provided for @listSettingStoragePeriodFree.
  ///
  /// In en, this message translates to:
  /// **'30 days from creation'**
  String get listSettingStoragePeriodFree;

  /// No description provided for @listSettingStoragePeriodUpsell.
  ///
  /// In en, this message translates to:
  /// **'With Premium you can keep lists with no time limit'**
  String get listSettingStoragePeriodUpsell;

  /// 共有関連の設定をまとめるセクション見出し (名詞)。共有ボタンのラベルは commonShare
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get listSettingShareSection;

  /// No description provided for @listSettingSendInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Send an invitation code to your group'**
  String get listSettingSendInvitationCode;

  /// No description provided for @listSettingGroupSetting.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get listSettingGroupSetting;

  /// No description provided for @listSettingGroupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Set a group name before inviting someone'**
  String get listSettingGroupNameRequired;

  /// No description provided for @listSettingListActionsSection.
  ///
  /// In en, this message translates to:
  /// **'List actions'**
  String get listSettingListActionsSection;

  /// No description provided for @listSettingDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete this list'**
  String get listSettingDeleteList;

  /// リスト削除確認ダイアログの barrierLabel (画面読み上げ用。画面には表示されない)
  ///
  /// In en, this message translates to:
  /// **'Shopping list deletion confirmation'**
  String get listSettingDeleteConfirmBarrierLabel;

  /// No description provided for @listSettingDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get listSettingDeleteConfirmTitle;

  /// No description provided for @listSettingDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and the {count} items in it will be deleted. This cannot be undone.'**
  String listSettingDeleteConfirmMessage(String name, int count);

  /// 招待コードダイアログのタイトルと、そのダイアログの barrierLabel
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get listSettingInvitationCodeTitle;

  /// No description provided for @listSettingInvitationExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get listSettingInvitationExpired;

  /// 招待コードの残り有効時間。days は残り日数、hours は日数を除いた残り時間
  ///
  /// In en, this message translates to:
  /// **'Valid for 7 days ・ {days}d {hours}h left'**
  String listSettingInvitationRemaining(int days, int hours);

  /// No description provided for @listSettingInvitationCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied the invitation code'**
  String get listSettingInvitationCodeCopied;

  /// 招待コードを他アプリへ共有するときの本文
  ///
  /// In en, this message translates to:
  /// **'Shopping list invitation code: {code}'**
  String listSettingInvitationShareText(String code);

  /// No description provided for @listSettingSelectShoppingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a shopping location'**
  String get listSettingSelectShoppingLocationTitle;

  /// No description provided for @listSettingLocationNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get listSettingLocationNone;

  /// No description provided for @listSettingLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get listSettingLocationSelected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
