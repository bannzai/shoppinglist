/// App Store / Google Play へ提出するスクリーンショットのページ定義。
///
/// 各ページのアプリ画面は本番の Page / シートをそのまま使い、Firestore や
/// Functions への依存は `previewProviderOverrides` の mock で置き換える
/// (`lib/features/previews/` と同じ仕組み)。スクリーンショット専用の UI は書かない。
library;

import 'package:flutter/material.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/screens/ai_categorize_preview_sheet_preview.dart';
import 'package:shoppinglist/features/previews/screens/ai_review_sheet_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_setting_preview.dart';

/// 撮影する 1 ページ。`screenshotCopies` の同じ添字のキャッチコピーと組み合わせる。
class ScreenshotPage {
  /// 出力ファイル名に使う識別子。
  final String name;

  /// デバイスフレームの中に表示するアプリ画面を組み立てる。
  final Widget Function() appScreen;

  const ScreenshotPage({required this.name, required this.appScreen});
}

/// 提出順に並べたページ定義。
///
/// App Store は 1 枚目の訴求力が最も高いため、共有という中心価値を先頭に置き、
/// 整理 (カテゴリ) → 入力の手軽さ (AI) → 使い分け (店舗) の順で機能を見せる。
final screenshotPages = <ScreenshotPage>[
  ScreenshotPage(
    name: 'shopping_list',
    appScreen: () => const ShoppingListPreview(),
  ),
  ScreenshotPage(
    name: 'category',
    appScreen: () => const GroupCategoryPage(groupID: mockGroupID),
  ),
  ScreenshotPage(
    name: 'ai_review',
    appScreen: () => const AIReviewSheetPreview(),
  ),
  ScreenshotPage(
    name: 'ai_categorize',
    appScreen: () => const AICategorizePreviewSheetPreview(),
  ),
  ScreenshotPage(
    name: 'shopping_list_setting',
    appScreen: () => const ShoppingListSettingPreview(),
  ),
];
