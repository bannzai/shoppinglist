import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/home/page.dart';
import 'package:shoppinglist/features/home_widget/home_widget_sync.dart';
import 'package:shoppinglist/features/resolver/app.dart';
import 'package:shoppinglist/features/resolver/app_entntiy_prepare.dart';
import 'package:shoppinglist/features/resolver/app_user_create.dart';
import 'package:shoppinglist/features/resolver/current_group_resolver.dart';
import 'package:shoppinglist/features/resolver/force_update.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/user_developer_token_sync.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/theme_color.dart';

@Dependencies([
  optionalAppUser,
  userDatabase,
  userDeveloperTokenSync,
  appUser,
  shoppingListAdd,
  shoppingLists,
  userGroups,
  firebaseUserChanges,
  sharedPreferences,
  BoolSharedPreferences,
  textShoppingListItems,
  defaultGroupUpdate,
  currentUserID,
  addShoppingListItem,
  remainingImageRecognitionCount,
  remainingURLRecognitionCount,
  StringSharedPreferences,
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
class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppResolvers(
      builder: (context, user) {
        return AppUserCreateResolver(
          firebaseUser: user,
          builder: (context) {
            return ForceUpdateResolver(
              builder: (context) {
                return AppEntityPrepareResolver(
                  builder: (context) {
                    // currentGroupID を確定 → ホームウィジェット同期(provider 内部 watch) →
                    // 表示。HomeWidgetSync を chain に置くことで、表示ツリーの深さに依存せず
                    // 現在グループ/リストの変更をウィジェットストレージへ同期する。
                    return CurrentGroupResolver(
                      builder: (context) {
                        return HomeWidgetSync(
                          builder: (context) {
                            return const HomePage();
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
