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
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/config/environment.dart';
import 'package:shoppinglist/features/home_widget/home_widget_callback.dart';
import 'package:shoppinglist/features/home_widget/home_widget_data_sync.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shoppinglist/utils/development/debug.dart';
import 'package:shoppinglist/utils/local_notification/local_notification.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/remote_config/remote_config.dart';
import 'package:home_widget/home_widget.dart';

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
    await GoogleSignIn.instance.initialize();

    // Keychain sharing の設定 (iOS/macOSでのみ有効)
    await FirebaseAuth.instance.setSettings(
      userAccessGroup: 'TQPN82UBBY.com.bannzai.shoppinglist',
    );

    // ホーム画面ウィジェットの設定
    await HomeWidget.setAppGroupId(HomeWidgetDataSync.appGroupId);
    await HomeWidget.registerInteractivityCallback(
        homeWidgetBackgroundCallback);

    if (kDebugMode) {
      overrideDebugPrint();
    }

    // FCM通知権限リクエスト
    await FirebaseMessaging.instance.requestPermission();

    // ignore: prefer_typing_uninitialized_variables
    final (sharedPreferences, _, _, _) = await (
      SharedPreferences.getInstance(),
      setupRemoteConfig(),
      initializePurchase(),
      localNotificationsInitialize(),
    ).wait;

    // MEMO: FirebaseCrashlytics#recordFlutterError called dumpErrorToConsole in function.
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      ],
      child: const App(),
    ));
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}
