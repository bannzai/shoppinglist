import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/theme_color.dart';

/// アプリのホーム画面。
///
/// 表示中グループ/リストの状態は currentGroupIDProvider / currentShoppingListIDProvider に、
/// グループ確定は CurrentGroupResolver に、画面本体は ShoppingListPage に分解済み。
/// そのため HomePage はルーティング上の入口名を保つだけの薄いラッパに留める。
@Dependencies([
  userGroups,
  appUser,
  shoppingLists,
  shoppingListAdd,
  textShoppingListItems,
  defaultGroupUpdate,
  currentUserID,
  addShoppingListItem,
  remainingImageRecognitionCount,
  remainingURLRecognitionCount,
  StringSharedPreferences,
  shoppingListDuplicate,
  groupUserProfiles,
  BoolSharedPreferences,
  shoppingListUpdate,
  group,
  groupUserProfileUpdate,
  sourceImages,
  receipts,
  groupCategoryAxes,
  shoppingLocations,
  groupCategoryAxisAdd,
  groupCategoryAdd,
  firebaseUserChanges,
  shoppingListItemBatchUpdate,
  groupCategories,
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
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const ShoppingListPage();
}
