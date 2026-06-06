import 'package:flutter/material.dart';
import 'package:shoppinglist/features/previews/previews_page.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preview',
      debugShowCheckedModeBanner: false,
      // アプリはライトモード固定。darkTheme は提供しない。
      theme: buildAppTheme(accent: AccentPreset.shu),
      home: const PreviewsPage(),
    );
  }
}
