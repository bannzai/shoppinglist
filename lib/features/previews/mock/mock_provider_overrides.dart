import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/entity/remote_config_parameter.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_group_id.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/remote_config_parameter.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/provider/user_groups.dart';

// --- No-Op操作クラス ---

class _NoOpShoppingListAdd extends ShoppingListAdd {
  _NoOpShoppingListAdd()
    : super(
        database: GroupDatabase(groupID: mockGroupID),
        isPremiumResolver: () => false,
        premiumEntitlementSyncer: () async {},
      );

  @override
  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required String? shoppingLocationID,
    required String? duplicatedFromGroupShoppingListID,
  }) async {
    return mockShoppingLists().first;
  }
}

class _NoOpShoppingListUpdate extends ShoppingListUpdate {
  _NoOpShoppingListUpdate()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String shoppingListID,
    required GroupShoppingList shoppingList,
  }) async {}
}

class _NoOpShoppingListDuplicate extends ShoppingListDuplicate {
  _NoOpShoppingListDuplicate()
    : super(
        shoppingListAdd: _NoOpShoppingListAdd(),
        addShoppingListItem: _NoOpAddShoppingListItem(),
      );

  @override
  Future<GroupShoppingList> call({
    required String createUserID,
    required String groupID,
    required GroupShoppingList sourceShoppingList,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    return mockShoppingLists().first;
  }
}

class _NoOpAddShoppingListItem extends AddShoppingListItem {
  _NoOpAddShoppingListItem()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    return mockShoppingListItems().first;
  }
}

class _NoOpShoppingListItemBatchUpdate extends ShoppingListItemBatchUpdate {
  _NoOpShoppingListItemBatchUpdate()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String shoppingListID,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {}
}

class _NoOpDefaultGroupUpdate extends DefaultGroupUpdate {
  _NoOpDefaultGroupUpdate()
    : super(userDatabase: UserDatabase(userID: mockUserID));

  @override
  Future<void> call({required String groupID}) async {}
}

class _NoOpCategoryAxisAdd extends GroupCategoryAxisAdd {
  _NoOpCategoryAxisAdd() : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<GroupCategoryAxis> call({
    required String groupID,
    required String userID,
    required String name,
    required int order,
  }) async {
    return mockCategoryAxis();
  }
}

class _NoOpCategoryAxisDelete extends GroupCategoryAxisDelete {
  _NoOpCategoryAxisDelete()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({required String categoryAxisID}) async {}
}

class _NoOpCategoryAdd extends GroupCategoryAdd {
  _NoOpCategoryAdd() : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<GroupCategory> call({
    required String groupID,
    required String userID,
    required String categoryAxisID,
    required String name,
    required int order,
  }) async {
    return mockCategories().first;
  }
}

class _NoOpCategoryUpdate extends GroupCategoryUpdate {
  _NoOpCategoryUpdate() : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
    required GroupCategory category,
  }) async {}
}

class _NoOpCategoryDelete extends GroupCategoryDelete {
  _NoOpCategoryDelete() : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
  }) async {}
}

class _NoOpCategoryBatchUpdate extends GroupCategoryBatchUpdate {
  _NoOpCategoryBatchUpdate()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String categoryAxisID,
    required List<GroupCategory> categories,
  }) async {}
}

class _NoOpGroupUserProfileUpdate extends GroupUserProfileUpdate {
  _NoOpGroupUserProfileUpdate()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String userID,
    required String? displayName,
  }) async {}
}

class _NoOpShoppingLocationAdd extends ShoppingLocationAdd {
  _NoOpShoppingLocationAdd()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<GroupShoppingLocation> call({
    required String name,
    required String address,
    required double? latitude,
    required double? longitude,
    required double? geofenceRadiusMeters,
  }) async {
    return mockShoppingLocation();
  }
}

class _NoOpShoppingLocationUpdate extends ShoppingLocationUpdate {
  _NoOpShoppingLocationUpdate()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String shoppingLocationID,
    required GroupShoppingLocation shoppingLocation,
  }) async {}
}

class _NoOpShoppingLocationDelete extends ShoppingLocationDelete {
  _NoOpShoppingLocationDelete()
    : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({required String shoppingLocationID}) async {}
}

/// Preview の選択状態 Notifier。build で mock の groupID を返す。
class _MockCurrentGroupID extends CurrentGroupID {
  @override
  String? build() => mockGroupID;
}

/// Preview の選択状態 Notifier。build で mock の shoppingListID を返す。
class _MockCurrentShoppingListID extends CurrentShoppingListID {
  @override
  String? build() => mockShoppingListID;
}

List<Override> previewProviderOverrides({
  required SharedPreferences sharedPreferences,
}) {
  return [
    // 基盤
    sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
    currentGroupIDProvider.overrideWith(() => _MockCurrentGroupID()),
    currentShoppingListIDProvider.overrideWith(
      () => _MockCurrentShoppingListID(),
    ),
    firebaseUserChangesProvider.overrideWith((ref) => Stream.value(null)),
    currentUserIDProvider.overrideWithValue(mockUserID),
    userDatabaseProvider.overrideWith(
      (ref) => UserDatabase(userID: mockUserID),
    ),
    remoteConfigParameterProvider.overrideWith(
      (ref) => RemoteConfigParameter(),
    ),
    // Preview では Purchases SDK 未初期化のため Stream.empty で逃がす。
    // asData が常に null → `?? false` で isPremium=false に解決される。
    customerInfoProvider.overrideWith(
      (ref) => const Stream<CustomerInfo>.empty(),
    ),
    // ユーザー・グループ (non-family)
    appUserProvider.overrideWith((ref) => Stream.value(mockAppUser())),
    userGroupsProvider.overrideWith((ref) => Stream.value([mockGroup()])),

    // Family providers: 具体的パラメータ付きでoverride
    groupProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => Stream.value(mockGroup())),
    groupDatabaseProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => GroupDatabase(groupID: mockGroupID)),

    // 買い物リスト
    shoppingListsProvider(
      groupID: mockGroupID,
      isPremium: false,
    ).overrideWith((ref) => Stream.value(mockShoppingLists())),
    textShoppingListItemsProvider(
      groupID: mockGroupID,
      shoppingListID: mockShoppingListID,
    ).overrideWith((ref) => Stream.value(mockShoppingListItems())),
    textShoppingListItemsProvider(
      groupID: mockGroupID,
      shoppingListID: mockShoppingListID2,
    ).overrideWith((ref) => Stream.value(mockShoppingListItems())),

    // カテゴリ
    groupCategoryAxesProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => Stream.value([mockCategoryAxis()])),
    groupCategoriesProvider(
      groupID: mockGroupID,
      categoryAxisID: mockCategoryAxisID,
    ).overrideWith((ref) => Stream.value(mockCategories())),

    // ユーザープロファイル
    groupUserProfilesProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => Stream.value(mockUserProfiles())),

    // 買い物場所
    shoppingLocationsProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => Stream.value([mockShoppingLocation()])),

    // 操作クラス (no-op) - Family providers
    shoppingListAddProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingListAdd()),
    shoppingListUpdateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingListUpdate()),
    shoppingListDuplicateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingListDuplicate()),
    addShoppingListItemProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpAddShoppingListItem()),
    shoppingListItemBatchUpdateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingListItemBatchUpdate()),

    // 操作クラス (no-op) - Non-family providers
    defaultGroupUpdateProvider.overrideWith((ref) => _NoOpDefaultGroupUpdate()),

    // カテゴリ操作 (no-op)
    groupCategoryAxisAddProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpCategoryAxisAdd()),
    groupCategoryAxisDeleteProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpCategoryAxisDelete()),
    groupCategoryAddProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpCategoryAdd()),
    groupCategoryUpdateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpCategoryUpdate()),
    groupCategoryDeleteProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpCategoryDelete()),
    groupCategoryBatchUpdateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpCategoryBatchUpdate()),

    // ユーザープロファイル操作
    groupUserProfileUpdateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpGroupUserProfileUpdate()),

    // 買い物場所操作
    shoppingLocationAddProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingLocationAdd()),
    shoppingLocationUpdateProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingLocationUpdate()),
    shoppingLocationDeleteProvider(
      groupID: mockGroupID,
    ).overrideWith((ref) => _NoOpShoppingLocationDelete()),
  ];
}
