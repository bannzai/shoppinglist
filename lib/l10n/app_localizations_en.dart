// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shopping List';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDone => 'Done';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonUpgrade => 'Upgrade';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonUncategorized => 'Uncategorized';

  @override
  String get commonGroup => 'Group';

  @override
  String get commonCamera => 'Camera';

  @override
  String get commonPhotoLibrary => 'Photo Library';

  @override
  String get commonErrorOccurred => 'An error occurred';

  @override
  String get errorUnknownTitle => 'An unknown error occurred';

  @override
  String get errorUnexpectedTitle => 'An unexpected error occurred';

  @override
  String get errorFaqLink => 'View FAQ';

  @override
  String get authGoogleSignIn => 'Sign in with Google';

  @override
  String get loadingPreparing => 'Preparing...';

  @override
  String get accountDeleteButton => 'Delete account';

  @override
  String get accountDeleteConfirmTitle => 'Delete your account information';

  @override
  String get accountDeleteConfirmMessage =>
      'Deleting your account will remove all of your user information.';

  @override
  String get accountDeleteConfirmButton => 'Delete';

  @override
  String get accountDeleteReauthTitle => 'Please sign in again';

  @override
  String get accountDeleteReauthMessage =>
      'To delete your account, please sign in again.';

  @override
  String get accountDeleteReauthButton => 'Sign in again';

  @override
  String get accountDeleteCompletedTitle => 'Your account has been deleted';

  @override
  String get accountDeleteExitAppQuestion => 'Quit the app?';

  @override
  String get accountDeleteExitAppButton => 'Quit';

  @override
  String get shoppingListDefaultName => 'Shopping List';

  @override
  String get shoppingListSettingTooltip => 'List settings';

  @override
  String get shoppingListEmptyTitle => 'No shopping lists yet';

  @override
  String get shoppingListEmptyMessage => 'Create a new shopping list';

  @override
  String get shoppingListEmptyCreateButton => 'Create shopping list';

  @override
  String get shoppingListLoadErrorTitle => 'Failed to load the list';

  @override
  String get shoppingListPickerTitle => 'Switch list';

  @override
  String get shoppingListPickerAddList => 'Add a new list';

  @override
  String get shoppingListCreateListTooltip => 'Add list';

  @override
  String get shoppingListCreateTodayList => 'Add a list with the current date';

  @override
  String get shoppingListDuplicateCurrentList => 'Duplicate the current list';

  @override
  String get shoppingListDuplicateUncheckedOnly =>
      'Duplicate with unchecked items only';

  @override
  String get shoppingListDuplicated => 'Duplicated the list';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return 'Duplicated from $name';
  }

  @override
  String get shoppingListDeletedListName => 'Deleted list';

  @override
  String get shoppingListDuplicateSourceDeleted =>
      'The original shopping list has been deleted';

  @override
  String get shoppingListRetentionBannerMessage =>
      'On the free plan, lists are cleaned up 30 days after they are created';

  @override
  String get shoppingListRetentionBannerDetail => 'Details';

  @override
  String get shoppingListSpotlightTitle =>
      'You can add a new shopping list here';

  @override
  String get shoppingListSpotlightMessage =>
      'Create a list for each date, or duplicate the list you are using now.';

  @override
  String get shoppingListSpotlightDismiss => 'Tap to close';

  @override
  String get shoppingListAiProcessingImage =>
      'Extracting suggestions from the photo...';

  @override
  String get shoppingListAiProcessingUrl =>
      'Extracting suggestions from the URL...';

  @override
  String get shoppingListAiProcessingCategorize => 'Sorting into categories...';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '. Upgrade to Premium and you can use it up to $limit times a month';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return 'Auto-categorize ($count items)';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return 'The monthly limit for auto-categorization ($limit times) has been reached';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return 'Registered $count items into categories';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => 'Auto-categorize';

  @override
  String get shoppingListAiCategorizeSheetSubtitle =>
      'Review and adjust the categories before registering them';

  @override
  String get shoppingListAiCategorizeSheetEmpty =>
      'No items could be categorized';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return 'Register $count items';
  }

  @override
  String get shoppingListCategorySelect => 'Select category';

  @override
  String get shoppingListCategoryChange => 'Change category';

  @override
  String get shoppingListNewCategoryHint => 'New category name';

  @override
  String get shoppingListAddCategoryLabel => 'Add category';

  @override
  String get shoppingListAiReviewTitle => 'Extracted suggestions';

  @override
  String get shoppingListAiReviewSubtitle => 'Choose the items you want to add';

  @override
  String get shoppingListAiReviewEmpty => 'No suggestions were found';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return 'Add $count items';
  }

  @override
  String get shoppingListFabAddFromPhoto => 'Add from photo';

  @override
  String get shoppingListFabAddFromUrl => 'Add from URL';

  @override
  String get shoppingListFabPasteText => 'Paste text';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return 'The monthly limit for photo recognition ($limit times) has been reached';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'The monthly limit for URL recognition ($limit times) has been reached';
  }

  @override
  String get shoppingListUrlDialogTitle =>
      'Generate a shopping list from a URL';

  @override
  String get shoppingListUrlDialogGenerate => 'Generate';

  @override
  String get shoppingListUrlRequired => 'Please enter a URL';

  @override
  String get shoppingListUrlInvalid => 'Please enter a valid HTTPS URL';

  @override
  String get shoppingListStarterRowLabel => 'Tap to start typing';

  @override
  String get shoppingListHintExample1 => 'e.g. Milk 1L';

  @override
  String get shoppingListHintExample2 => 'e.g. Eggs, 1 pack';

  @override
  String get shoppingListHintExample3 => 'e.g. Bread';

  @override
  String get shoppingListHintExample4 => 'e.g. Onions x2';

  @override
  String get shoppingListHintExample5 => 'e.g. Tomatoes';

  @override
  String get shoppingListHintCardTitle => 'Here is how to use it';

  @override
  String get shoppingListHintTap => '・Tap a row and type right away';

  @override
  String get shoppingListHintReturn => '・Press return to move to the next line';

  @override
  String get shoppingListHintDelete =>
      '・Press delete on an empty line to remove it';

  @override
  String get shoppingListHintFabPrefix => '・Long-press the ';

  @override
  String get shoppingListHintFabSuffix =>
      ' at the bottom right to add from a photo or a URL';

  @override
  String get shoppingListItemDetailTooltip => 'Item details';

  @override
  String get shoppingListItemDeleteTooltip => 'Delete item';

  @override
  String get shoppingListItemDeleteConfirm => 'Delete this item?';

  @override
  String get shoppingListItemDeleted => 'Deleted the item';

  @override
  String get shoppingListItemMemoHint => 'Write a note...';

  @override
  String get shoppingListNotifyGroup => 'Notify group';

  @override
  String get shoppingListNotifyGroupSent => 'Notified the group';

  @override
  String get shoppingListNotifyGroupGuideLabel => 'About group notifications';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      'Tapping this button sends a push notification to the other members of your group to let them know you updated the shopping list.';

  @override
  String get shoppingListNotifyGroupSend => 'Send notification';
}
