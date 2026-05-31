import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';

const mockUserID = 'preview-user-001';
const mockUserID2 = 'preview-user-002';
const mockGroupID = 'preview-group-001';
const mockShoppingListID = 'preview-shopping-list-001';
const mockShoppingListID2 = 'preview-shopping-list-002';
const mockCategoryAxisID = 'preview-category-axis-001';
const mockCategoryID = 'preview-category-001';
const mockCategoryID2 = 'preview-category-002';
const mockShoppingLocationID = 'preview-location-001';

AppUser mockAppUser() => const AppUser(
      id: mockUserID,
      defaultGroupID: mockGroupID,
    );

Group mockGroup() => const Group(
      id: mockGroupID,
      memberUserIDs: [mockUserID, mockUserID2],
      name: 'プレビュー用グループ',
      ownerUserID: mockUserID,
    );

List<GroupShoppingList> mockShoppingLists() => [
      GroupShoppingList(
          id: mockShoppingListID,
          createUserID: mockUserID,
          groupID: mockGroupID,
          name: '今日の買い物',
          status: GroupShoppingListStatus.active,
          ttlExpiresDateTime: null,
          duplicatedFromGroupShoppingListID: null,
          shoppingLocationID: null),
      GroupShoppingList(
          id: mockShoppingListID2,
          createUserID: mockUserID,
          groupID: mockGroupID,
          name: '週末の買い物',
          status: GroupShoppingListStatus.active,
          ttlExpiresDateTime: null,
          duplicatedFromGroupShoppingListID: null,
          shoppingLocationID: null),
    ];

List<GroupShoppingListItem> mockShoppingListItems() => [
      const GroupShoppingListItem(
          id: 'preview-item-001',
          groupID: mockGroupID,
          shoppingListID: mockShoppingListID,
          userID: mockUserID,
          message: '牛乳',
          order: 0,
          status: GroupShoppingListItemStatus.unchecked,
          checkedByUserID: null,
          color: null,
          description: null,
          imageURL: null,
          lastEditedByUserID: null),
      const GroupShoppingListItem(
          id: 'preview-item-002',
          groupID: mockGroupID,
          shoppingListID: mockShoppingListID,
          userID: mockUserID,
          message: '卵',
          order: 1,
          status: GroupShoppingListItemStatus.checked,
          checkedByUserID: null,
          color: null,
          description: null,
          imageURL: null,
          lastEditedByUserID: null),
      const GroupShoppingListItem(
          id: 'preview-item-003',
          groupID: mockGroupID,
          shoppingListID: mockShoppingListID,
          userID: mockUserID,
          message: '食パン',
          order: 2,
          status: GroupShoppingListItemStatus.unchecked,
          checkedByUserID: null,
          color: null,
          description: null,
          imageURL: null,
          lastEditedByUserID: null),
      const GroupShoppingListItem(
          id: 'preview-item-004',
          groupID: mockGroupID,
          shoppingListID: mockShoppingListID,
          userID: mockUserID,
          message: 'バナナ',
          order: 3,
          status: GroupShoppingListItemStatus.unchecked,
          description: '3本入り',
          checkedByUserID: null,
          color: null,
          imageURL: null,
          lastEditedByUserID: null),
      const GroupShoppingListItem(
          id: 'preview-item-005',
          groupID: mockGroupID,
          shoppingListID: mockShoppingListID,
          userID: mockUserID,
          message: 'トイレットペーパー',
          order: 4,
          status: GroupShoppingListItemStatus.checked,
          checkedByUserID: null,
          color: null,
          description: null,
          imageURL: null,
          lastEditedByUserID: null),
    ];

GroupCategoryAxis mockCategoryAxis() => const GroupCategoryAxis(
      id: mockCategoryAxisID,
      groupID: mockGroupID,
      userID: mockUserID,
      name: '売り場',
      order: 0,
    );

List<GroupCategory> mockCategories() => [
      const GroupCategory(
          id: mockCategoryID,
          groupID: mockGroupID,
          userID: mockUserID,
          groupCategoryAxisID: mockCategoryAxisID,
          name: '食品',
          order: 0,
          locationOrders: {},
          keywords: [],
          color: null,
          iconName: null),
      const GroupCategory(
          id: mockCategoryID2,
          groupID: mockGroupID,
          userID: mockUserID,
          groupCategoryAxisID: mockCategoryAxisID,
          name: '日用品',
          order: 1,
          locationOrders: {},
          keywords: [],
          color: null,
          iconName: null),
    ];

GroupShoppingLocation mockShoppingLocation() => const GroupShoppingLocation(
      id: mockShoppingLocationID,
      groupID: mockGroupID,
      name: '近所のスーパー',
      latitude: null,
      longitude: null,
      geofenceRadiusMeters: null,
    );

List<GroupUserProfile> mockUserProfiles() => [
      GroupUserProfile(
        id: GroupUserProfile.documentID(
            groupID: mockGroupID, userID: mockUserID),
        groupID: mockGroupID,
        userID: mockUserID,
        displayName: 'プレビューユーザー',
      ),
      GroupUserProfile(
        id: GroupUserProfile.documentID(
            groupID: mockGroupID, userID: mockUserID2),
        groupID: mockGroupID,
        userID: mockUserID2,
        displayName: 'ゲストユーザー',
      ),
    ];
