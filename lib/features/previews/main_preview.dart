import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/previews/preview_app.dart';
import 'package:shoppinglist/utils/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase初期化なし
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  Environment.flavor = Flavor.DEVELOP;

  runApp(ProviderScope(
    overrides: previewProviderOverrides(sharedPreferences: sharedPreferences),
    child: const PreviewApp(),
  ));
}
