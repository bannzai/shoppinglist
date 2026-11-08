/// App Store / Google Play へ提出するスクリーンショットのページ定義。
///
/// 各ページのアプリ画面は本番の Page / シートをそのまま使い、Firestore や
/// Functions への依存は `previewProviderOverrides` の mock で置き換える
/// (`lib/features/previews/` と同じ仕組み)。スクリーンショット専用の UI は書かない。
library;

import 'package:flutter/material.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_setting_preview.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_preview_sheet.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_review_sheet.dart';
import 'package:shoppinglist/screenshot/screenshot_sheet_host.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/theme_color.dart';

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
@Dependencies([
  groupCategoryAxes,
  currentUserID,
  groupCategoryAxisAdd,
  groupCategoryAdd,
  userGroups,
  appUser,
  shoppingLists,
  groupCategories,
  shoppingLocations,
  shoppingListUpdate,
  textShoppingListItems,
  group,
  shoppingListAdd,
  shareableGroupCategoryAxes,
  groupUserProfiles,
  groupCategoryImportFromMember,
  groupCategoryBatchUpdate,
  moveItemCategoryKeyword,
  groupCategoryDelete,
  shoppingListDuplicate,
  defaultGroupUpdate,
  addShoppingListItem,
  remainingImageRecognitionCount,
  remainingURLRecognitionCount,
  StringSharedPreferences,
  groupCategoryUpdate,
  BoolSharedPreferences,
  groupUserProfileUpdate,
  sourceImages,
  receipts,
  shoppingLocationAdd,
  shoppingLocationUpdate,
  shoppingLocationDelete,
  firebaseUserChanges,
  shoppingListItemBatchUpdate,
  sharedPreferences,
  userDatabase,
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
])
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
    appScreen:
        () => ScreenshotSheetHost(
          background: const ShoppingListPreview(),
          openSheet:
              ({required context}) => showAIReviewSheet(
                context: context,
                rawNames: const ['牛乳', 'パン', '卵', 'にんじん', '玉ねぎ'],
                source: 'screenshot',
              ),
        ),
  ),
  ScreenshotPage(
    name: 'ai_categorize',
    appScreen:
        () => ScreenshotSheetHost(
          background: const ShoppingListPreview(),
          openSheet:
              ({required context}) => showAICategorizePreviewSheet(
                context: context,
                categorized: const [
                  (name: 'にんじん', categoryName: '野菜'),
                  (name: '玉ねぎ', categoryName: '野菜'),
                  (name: '鶏もも肉', categoryName: '肉'),
                  (name: '牛乳', categoryName: '乳製品'),
                ],
                existingCategoryNames: const ['野菜', '肉', '乳製品'],
              ),
        ),
  ),
  ScreenshotPage(
    name: 'shopping_list_setting',
    appScreen: () => const ShoppingListSettingPreview(),
  ),
];
