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

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonShare => 'Share';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsDisplayNameLabel => 'Your display name';

  @override
  String get settingsDisplayNameHint => 'Enter a display name';

  @override
  String get settingsDisplayNameUpdated => 'Updated your display name';

  @override
  String get settingsGroupManagement => 'Manage groups';

  @override
  String get settingsJoinGroupWithInvitationCode =>
      'Join a group with an invitation code';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsNotificationSection => 'Notifications';

  @override
  String get settingsAboutSection => 'About this app';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsCommercialTransactionAct =>
      'Notation based on the Specified Commercial Transaction Act';

  @override
  String get settingsInquiry => 'Contact us';

  @override
  String get settingsOssLicense => 'Open source licenses';

  @override
  String get settingsDebugSection => 'Debug';

  @override
  String get settingsDeveloperOptions => 'Developer options';

  @override
  String get settingsPremiumCardTitlePremium => 'Premium member';

  @override
  String get settingsPremiumCardTitleFree => 'Upgrade to Premium';

  @override
  String get settingsPremiumCardSubtitlePremium => 'You can use all features';

  @override
  String get settingsPremiumCardSubtitleFree =>
      'Five color themes, more photo/URL scans, and more';

  @override
  String get settingsPremiumCardStartButton => 'Get started';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirmBarrierLabel => 'Sign-out confirmation';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out?';

  @override
  String get settingsSignOutConfirmMessage =>
      'You will not be able to access your lists from this device until you sign in again.';

  @override
  String get settingsSignOutConfirmMessageGuest =>
      'You are using the app as a guest, so if you sign out you cannot sign in to the same account again and you will permanently lose access to your current lists and groups.';

  @override
  String get settingsSignOutCompletedTitle => 'Signed out';

  @override
  String get settingsSignOutExitAppMessage => 'The app will now quit';

  @override
  String get settingsThemeColorTitle => 'Theme color';

  @override
  String get settingsThemeColorDescription =>
      'Choose from five traditional Japanese colors to change the accent color used across the app.';

  @override
  String get settingsThemeColorChanged => 'Changed the theme color';

  @override
  String settingsThemeColorSwatchLabel(String label) {
    return '$label theme color';
  }

  @override
  String get settingsThemeColorPremiumOnly =>
      'Changing the theme color is a Premium feature';

  @override
  String get settingsLocationReminderTitle => 'Location reminder';

  @override
  String get settingsLocationReminderSubtitle =>
      'Notify me of my shopping list when I am near a store';

  @override
  String get settingsLocationReminderNotificationPermissionRequired =>
      'Allow notifications to use this feature';

  @override
  String get settingsLocationReminderAlwaysPermissionRequired =>
      'Set background location access to \"Always\" to use this feature';

  @override
  String get settingsLocationReminderPremiumOnly =>
      'The location reminder is a Premium feature';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsAccountLinked => 'Linked your account';

  @override
  String get settingsAccountGuestDescription =>
      'You are using the app as a guest. If you link an account, you can use the same lists and groups after changing devices or on another device.';

  @override
  String get settingsAccountLinkWithApple => 'Link your account with Apple';

  @override
  String get settingsAccountLinkWithGoogle => 'Link your account with Google';

  @override
  String settingsAccountSignedInWith(String providerName) {
    return 'Signed in with $providerName';
  }

  @override
  String get settingsAccountReSignInBarrierLabel => 'Re-sign-in confirmation';

  @override
  String get settingsAccountAlreadyInUseTitle =>
      'This account is already used by another user';

  @override
  String get settingsAccountReSignInMessage =>
      'Do you want to sign in again with this account?\nIf you sign in again, your current guest data (lists and groups) will not be carried over.';

  @override
  String get settingsAccountReSignInButton => 'Sign in again';

  @override
  String get listSettingTitle => 'Shopping list settings';

  @override
  String get listSettingNameSection => 'List name';

  @override
  String get listSettingShoppingLocationSection => 'Shopping location';

  @override
  String get listSettingLocationUnset => 'Not set';

  @override
  String get listSettingLocationChangeDetail => 'Change';

  @override
  String get listSettingCategorySubtitle =>
      'Manage keywords for auto-categorization';

  @override
  String get listSettingStoragePeriodSection => 'Retention period';

  @override
  String get listSettingStoragePeriodPremium => 'Premium: unlimited';

  @override
  String get listSettingStoragePeriodFree => '30 days from creation';

  @override
  String get listSettingStoragePeriodUpsell =>
      'With Premium you can keep lists with no time limit';

  @override
  String get listSettingShareSection => 'Sharing';

  @override
  String get listSettingSendInvitationCode =>
      'Send an invitation code to your group';

  @override
  String get listSettingGroupSetting => 'Group settings';

  @override
  String get listSettingGroupNameRequired =>
      'Set a group name before inviting someone';

  @override
  String get listSettingListActionsSection => 'List actions';

  @override
  String get listSettingDeleteList => 'Delete this list';

  @override
  String get listSettingDeleteConfirmBarrierLabel =>
      'Shopping list deletion confirmation';

  @override
  String get listSettingDeleteConfirmTitle => 'Delete this list?';

  @override
  String listSettingDeleteConfirmMessage(String name, int count) {
    return '\"$name\" and the $count items in it will be deleted. This cannot be undone.';
  }

  @override
  String get listSettingInvitationCodeTitle => 'Invitation code';

  @override
  String get listSettingInvitationExpired => 'Expired';

  @override
  String listSettingInvitationRemaining(int days, int hours) {
    return 'Valid for 7 days ・ ${days}d ${hours}h left';
  }

  @override
  String get listSettingInvitationCodeCopied => 'Copied the invitation code';

  @override
  String listSettingInvitationShareText(String code) {
    return 'Shopping list invitation code: $code';
  }

  @override
  String get listSettingSelectShoppingLocationTitle =>
      'Choose a shopping location';

  @override
  String get listSettingLocationNone => 'None';

  @override
  String get listSettingLocationSelected => 'Selected';

  @override
  String get commonDefault => 'Default';

  @override
  String get commonUnnamed => 'Unnamed';

  @override
  String get commonCreating => 'Creating...';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'Enter a group name';

  @override
  String get groupCategoryLocationOrderLabel => 'Order by shopping location';

  @override
  String get groupCategoryLocationOrderPremiumOnly =>
      'Reordering categories per shopping location is a Premium feature';

  @override
  String groupCategoryKeywordCount(int count) {
    return 'Keywords: $count';
  }

  @override
  String groupCategoryDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get groupCategoryDeleteConfirmMessage =>
      'The keywords set for this category will also be deleted';

  @override
  String get groupCategoryEmptyTitle => 'Group what you buy automatically';

  @override
  String get groupCategoryEmptyUseCaseAutoGroup =>
      'Register tomatoes and onions under \"Vegetables\" and they are automatically grouped into the Vegetables section of your list';

  @override
  String get groupCategoryEmptyUseCaseLocationOrder =>
      'You can change the category order for each store, so you can shop along the aisles in order';

  @override
  String get groupCategoryEditTitle => 'Edit category';

  @override
  String get groupCategoryEditNotFound => 'Category not found';

  @override
  String get groupCategoryEditNameLabel => 'Category name';

  @override
  String get groupCategoryEditNameHint => 'Enter a category name';

  @override
  String get groupCategoryEditColorLabel => 'Category color';

  @override
  String get groupCategoryEditIconLabel => 'Category icon';

  @override
  String get groupCategoryEditKeywordsLabel => 'Keywords';

  @override
  String get groupCategoryEditAddKeyword => 'Add keyword';

  @override
  String get groupCategoryEditKeywordsEmpty => 'No keywords yet';

  @override
  String get groupCategoryEditKeywordHint => 'Enter a keyword';

  @override
  String get groupCategoryEditMatchingLabel => 'Matching';

  @override
  String get groupCategoryEditMatchingExact => 'Exact match';

  @override
  String get groupCategoryEditMatchingPartial => 'Partial match';

  @override
  String get groupCategoryEditMatchingRegex => 'Regular expression';

  @override
  String get groupCreateTitle => 'Create a group';

  @override
  String get groupCreateIconLabel => 'Icon';

  @override
  String get groupCreateSubmit => 'Create';

  @override
  String get groupCreateIconHome => 'Home';

  @override
  String get groupCreateIconCart => 'Cart';

  @override
  String get groupCreateIconFork => 'Food';

  @override
  String get groupCreateIconCookie => 'Snacks';

  @override
  String get groupCreateIconPets => 'Pets';

  @override
  String get groupCreateIconBag => 'Bag';

  @override
  String get groupCreateInvitationDialogTitle => 'Invite members';

  @override
  String get groupCreateInvitationDialogMessage =>
      'Share the invitation code with your family';

  @override
  String get groupInvitationTitle => 'Join with an invitation code';

  @override
  String get groupInvitationHeading => 'Enter your invitation code';

  @override
  String get groupInvitationDescription =>
      'Enter the 8-character code shared with you by a member of the group';

  @override
  String get groupInvitationJoining => 'Joining...';

  @override
  String get groupInvitationJoin => 'Join';

  @override
  String get groupInvitationVerifyingTitle => 'Checking the invitation code';

  @override
  String get groupInvitationVerifyingMessage =>
      'The server is processing your request to join the group.';

  @override
  String get groupJoinHeading => 'Let\'s get started';

  @override
  String get groupJoinDescription =>
      'Did you get an invitation code from your family or partner?\nJoining with a code lets you use the same shopping list together.';

  @override
  String get groupJoinCreateSolo => 'Create my own list';

  @override
  String get groupListEmpty => 'You do not belong to any group';

  @override
  String groupListMemberCount(int count) {
    return '$count members';
  }

  @override
  String get groupListFreeLimitBanner =>
      'The free plan allows one additional group';

  @override
  String get groupListFreeLimitAction => 'Unlock';

  @override
  String get groupSettingMembersSection => 'Members';

  @override
  String get groupSettingMemberOwner => 'Owner';

  @override
  String get groupSettingMemberSelf => 'You';

  @override
  String get groupSettingMemberFallbackName => 'Member';

  @override
  String get groupSettingShoppingLocationSubtitle => 'Register and edit stores';

  @override
  String get groupSettingInvitationSection => 'Group invitation';

  @override
  String get groupSettingCreatingInvitation => 'Issuing an invitation code...';

  @override
  String get groupSettingCreateInvitation => 'Issue an invitation code';

  @override
  String groupSettingRemoveMemberConfirmTitle(String name) {
    return 'Remove $name from the group?';
  }

  @override
  String get groupSettingRemoveMemberConfirmMessage =>
      'A removed member will no longer be able to access this group';

  @override
  String groupSettingMemberRemoved(String name) {
    return 'Removed $name';
  }

  @override
  String get groupSettingInvitationCodeMessage => 'Share the code below';

  @override
  String get groupSettingInvitationExpiry => 'Valid for 7 days';
}
