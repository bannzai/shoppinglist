import 'package:flutter/material.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shopping_location.dart';

@Dependencies([
  shoppingListUpdate,
  textShoppingListItems,
  group,
  shoppingLocations,
  groupCategoryAxes,
  currentUserID,
  groupCategoryAxisAdd,
  groupCategoryAdd,
  groupUserProfiles,
  shoppingListDuplicate,
  groupCategories,
  shareableGroupCategoryAxes,
  groupCategoryImportFromMember,
  groupCategoryBatchUpdate,
  moveItemCategoryKeyword,
  groupCategoryDelete,
  shoppingLocationAdd,
  shoppingLocationUpdate,
  shoppingLocationDelete,
  groupCategoryUpdate,
])
class ShoppingListSettingPreview extends StatelessWidget {
  const ShoppingListSettingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ShoppingListSettingPage(
      groupID: mockGroupID,
      shoppingListID: mockShoppingListID,
      shoppingList: mockShoppingLists().first,
      onDelete: () => Navigator.pop(context),
    );
  }
}
