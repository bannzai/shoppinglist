import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/app.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/config/app_identity.dart' as app_identity;
import 'package:shoppinglist/utils/config/environment.dart';
import 'package:shoppinglist/features/home_widget/home_widget_callback.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shoppinglist/utils/development/debug.dart';
import 'package:shoppinglist/utils/firebase_app_check/firebase_app_check.dart';
import 'package:shoppinglist/utils/firebase_emulator/firebase_emulator.dart';
import 'package:shoppinglist/utils/local_notification/local_notification.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/remote_config/remote_config.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/user_developer_token_sync.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/theme_color.dart';

@Dependencies([
  geofenceMonitoringPlan,
  geofenceService,
  appUser,
  optionalAppUser,
  userDatabase,
  userDeveloperTokenSync,
  shoppingListAdd,
  shoppingLists,
  userGroups,
  currentUserID,
  addShoppingListItem,
  textShoppingListItems,
  StringSharedPreferences,
  firebaseUserChanges,
  sharedPreferences,
  BoolSharedPreferences,
  defaultGroupUpdate,
  remainingImageRecognitionCount,
  remainingURLRecognitionCount,
  shoppingListDuplicate,
  groupUserProfiles,
  shoppingListUpdate,
  group,
  groupUserProfileUpdate,
  sourceImages,
  receipts,
  groupCategoryAxes,
  shoppingLocations,
  groupCategoryAxisAdd,
  groupCategoryAdd,
  shoppingListItemBatchUpdate,
  groupCategories,
  themeColorUpdate,
  groupDatabase,
  addReceipt,
  updateReceipt,
  updateShoppingListItem,
  toggleShoppingListItemCheck,
  restoreShoppingListItem,
  deleteShoppingListItem,
  remainingCategorizeCount,
  aiCategorizeApply,
  groupCategoryBatchUpdate,
  moveItemCategoryKeyword,
  shareableGroupCategoryAxes,
  groupCategoryImportFromMember,
  groupCategoryDelete,
  shoppingLocationAdd,
  shoppingLocationUpdate,
  shoppingLocationDelete,
  groupCategoryUpdate,
])
void main() async {
  if (kDebugMode) {
    Environment.flavor = Flavor.DEVELOP;
  } else {
    if (kReleaseMode) {
      Environment.flavor = Flavor.PRODUCTION;
    }
  }

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await activateAppCheck();

    await connectFirebaseEmulatorIfEnabled();

    await GoogleSignIn.instance.initialize();

    // Keychain sharing の設定 (iOS/macOSでのみ有効)
    await FirebaseAuth.instance.setSettings(
      userAccessGroup: app_identity.keychainAccessGroup,
    );

    // ホーム画面ウィジェットの設定
    await HomeWidget.setAppGroupId(HomeWidgetDataSync.appGroupId);
    await HomeWidget.registerInteractivityCallback(
      homeWidgetBackgroundCallback,
    );

    overrideDebugPrint();

    // ignore: prefer_typing_uninitialized_variables
    final (sharedPreferences, _, _, _) =
        await (
          SharedPreferences.getInstance(),
          setupRemoteConfig(),
          initializePurchase(),
          localNotificationsInitialize(),
        ).wait;

    // MEMO: FirebaseCrashlytics#recordFlutterError called dumpErrorToConsole in function.
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    appProviderContainer = ProviderContainer(
      // Riverpod 3 は失敗した provider を既定で自動再試行するが、このアプリは Riverpod 2 の時から
      // 失敗をそのまま画面のエラー表示・再試行ボタンで扱っている (permission-denied 等を
      // 自動で叩き直さない)。移行で挙動を変えないよう自動再試行を止める
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      ],
    );
    runApp(
      UncontrolledProviderScope(
        container: appProviderContainer,
        child: const App(),
      ),
    );
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}
