import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/resolver/database.dart';

import 'package:shoppinglist/utils/config/environment.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';
import 'package:url_launcher/url_launcher.dart';

void inquiry() {
  PackageInfo.fromPlatform().then((value) => debugInfo(', ')).then((info) {
    launchUrl(
      Uri.parse(
        Uri.encodeFull(
          'https://docs.google.com/forms/d/e/1FAIpQLSdokN_G4rRbtBvpYw8r8emBcXWLac1iNq2u3g1Z6iM05NgBAQ/viewform?usp=pp_url&entry.1233153512=$info',
        ),
      ),
      mode: LaunchMode.externalApplication,
    );
  });
}

Future<String> debugInfo(String separator) async {
  final userID = FirebaseAuth.instance.currentUser?.uid;
  if (userID == null) {
    final sharedPreferences = await SharedPreferences.getInstance();
    return Future.value(
      'DEBUG INFO user is not found. lastest last login id ${sharedPreferences.getString(StringKey.lastSignInFirebaseAuthUserID)}',
    );
  }

  UserDatabase databaseConnection = UserDatabase(userID: userID);

  AppUser? user;
  try {
    user = (await databaseConnection.userReference().get()).data();
  } catch (_) {}

  PackageInfo? package;
  try {
    package = await PackageInfo.fromPlatform();
  } catch (_) {}
  final appName = package?.appName;
  final buildNumber = package?.buildNumber;
  final packageName = package?.packageName;
  final version = package?.version;
  final platform = Platform.isIOS ? 'iOS' : 'Android';

  final contents = [
    'DEBUG INFO',
    "$platform:$appName:$version:$packageName:$buildNumber:${Environment.isProduction ? "prod" : "dev"}",
    'userID: $userID',
    'createdDateTime: ${user?.createdDateTime}',
    // TODO: [CustomerInfo]
    // 'isPremium: ${user?.isPremium}',
    // 'isTrial: ${user?.isTrial}',
  ];
  return contents.join(separator);
}

class InquiryButton extends ConsumerWidget {
  const InquiryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      icon: const Icon(Icons.mail, size: 20),
      label: Text(
        'お問い合わせ',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w300,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onPressed: () {
        analytics.logEvent(
          name: 'problem_unresolved_button_pressed',
          parameters: null,
        );
        inquiry();
      },
    );
  }
}
