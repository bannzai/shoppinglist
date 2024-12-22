import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/config/environment.dart';
import 'package:shoppinglist/utils/development/debug.dart';
import 'package:shoppinglist/utils/remote_config/remote_config.dart';

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
    await (MobileAds.instance.initialize(), Firebase.initializeApp()).wait;

    if (kDebugMode) {
      overrideDebugPrint();
    }

    // ignore: prefer_typing_uninitialized_variables
    final (sharedPreferences, _) = await (
      SharedPreferences.getInstance(),
      setupRemoteConfig(),
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
