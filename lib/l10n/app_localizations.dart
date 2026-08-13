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

  /// グループ名が未設定のときのフォールバック表示
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
