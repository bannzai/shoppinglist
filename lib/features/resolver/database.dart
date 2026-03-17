import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/app_user_private.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

abstract class _CollectionPath {
  static const String users = '/users';
  static const String groups = '/groups';
  static String shoppingLists({required String groupID}) =>
      '/groups/$groupID/shoppingLists';
  static String shoppingListItems(
          {required String groupID, required String shoppingListID}) =>
      '/groups/$groupID/shoppingLists/$shoppingListID/items';
  static String shoppingLocations({required String groupID}) =>
      '/groups/$groupID/shoppingLocations';
  static String userCategoryAxes({required String groupID}) =>
      '/groups/$groupID/userCategoryAxes';
  static String categories(
          {required String groupID, required String categoryAxisID}) =>
      '/groups/$groupID/userCategoryAxes/$categoryAxisID/categories';
  static String privates({required String userID}) => '/users/$userID/privates';
  static String userProfiles({required String groupID}) =>
      '/groups/$groupID/userProfiles';
}

@Riverpod(keepAlive: true, dependencies: [firebaseUserChanges])
UserDatabase userDatabase(Ref ref) {
  final firebaseUserChanges = ref.watch(firebaseUserChangesProvider);
  // 初回起動の時には.userChanges()のstreamは流れてこないので、currentUserのidを使う
  final uid = firebaseUserChanges.asData?.value?.uid ??
      FirebaseAuth.instance.currentUser?.uid;
  debugPrint('[DEBUG] database uid is $uid');
  if (uid == null) {
    throw Exception('userID is null');
  }
  return UserDatabase(userID: uid);
}

class UserDatabase {
  final String userID;
  UserDatabase({required this.userID});

  DocumentReference<AppUser> userReference() => FirebaseFirestore.instance
      .collection(_CollectionPath.users)
      .doc(userID)
      .withConverter(
        fromFirestore: AppUser.fromFirestore,
        toFirestore: AppUser.toFirestore,
      );

  DocumentReference<AppUserPrivate> privateReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.privates(userID: userID))
          .doc(AppUserPrivate.documentID(userID: userID))
          .withConverter(
            fromFirestore: AppUserPrivate.fromFirestore,
            toFirestore: AppUserPrivate.toFirestore,
          );
}

@Riverpod(keepAlive: true, dependencies: [])
GroupDatabase groupDatabase(Ref ref, {required String groupID}) {
  return GroupDatabase(groupID: groupID);
}

class GroupDatabase {
  final String groupID;
  GroupDatabase({required this.groupID});

  DocumentReference<Group> groupReference() => FirebaseFirestore.instance
      .collection(_CollectionPath.groups)
      .doc(groupID)
      .withConverter(
        fromFirestore: Group.fromFirestore,
        toFirestore: Group.toFirestore,
      );

  CollectionReference<GroupShoppingList> shoppingListsReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLists(groupID: groupID))
          .withConverter(
            fromFirestore: GroupShoppingList.fromFirestore,
            toFirestore: GroupShoppingList.toFirestore,
          );
  Future<int> countOfGroupShoppingLists() async {
    final aggregated = await FirebaseFirestore.instance
        .collection(_CollectionPath.shoppingLists(groupID: groupID))
        .count()
        .get();
    return aggregated.count ?? 0;
  }

  DocumentReference<GroupShoppingList> shoppingListReference({
    required String shoppingListID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLists(groupID: groupID))
          .doc(shoppingListID)
          .withConverter(
            fromFirestore: GroupShoppingList.fromFirestore,
            toFirestore: GroupShoppingList.toFirestore,
          );
  DocumentReference<GroupShoppingList> newGroupShoppingListReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLists(groupID: groupID))
          .doc()
          .withConverter(
            fromFirestore: GroupShoppingList.fromFirestore,
            toFirestore: GroupShoppingList.toFirestore,
          );

  CollectionReference<GroupShoppingListItem> shoppingListItemsReference(
          {required String shoppingListID}) =>
      FirebaseFirestore.instance
          .collection(
            _CollectionPath.shoppingListItems(
              groupID: groupID,
              shoppingListID: shoppingListID,
            ),
          )
          .withConverter(
            fromFirestore: GroupShoppingListItem.fromFirestore,
            toFirestore: GroupShoppingListItem.toFirestore,
          );

  DocumentReference<GroupShoppingListItem> shoppingListItemReference({
    required String shoppingListID,
    required String itemID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingListItems(
              groupID: groupID, shoppingListID: shoppingListID))
          .doc(itemID)
          .withConverter(
            fromFirestore: GroupShoppingListItem.fromFirestore,
            toFirestore: GroupShoppingListItem.toFirestore,
          );

  CollectionReference<GroupShoppingLocation> shoppingLocationsReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLocations(groupID: groupID))
          .withConverter(
            fromFirestore: GroupShoppingLocation.fromFirestore,
            toFirestore: GroupShoppingLocation.toFirestore,
          );

  DocumentReference<GroupShoppingLocation> shoppingLocationReference({
    required String shoppingLocationID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLocations(groupID: groupID))
          .doc(shoppingLocationID)
          .withConverter(
            fromFirestore: GroupShoppingLocation.fromFirestore,
            toFirestore: GroupShoppingLocation.toFirestore,
          );

  DocumentReference<GroupShoppingLocation> newShoppingLocationReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLocations(groupID: groupID))
          .doc()
          .withConverter(
            fromFirestore: GroupShoppingLocation.fromFirestore,
            toFirestore: GroupShoppingLocation.toFirestore,
          );

  CollectionReference<GroupCategoryAxis> categoryAxesReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.userCategoryAxes(groupID: groupID))
          .withConverter(
            fromFirestore: GroupCategoryAxis.fromFirestore,
            toFirestore: GroupCategoryAxis.toFirestore,
          );

  DocumentReference<GroupCategoryAxis> categoryAxisReference({
    required String categoryAxisID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.userCategoryAxes(groupID: groupID))
          .doc(categoryAxisID)
          .withConverter(
            fromFirestore: GroupCategoryAxis.fromFirestore,
            toFirestore: GroupCategoryAxis.toFirestore,
          );

  DocumentReference<GroupCategoryAxis> newCategoryAxisReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.userCategoryAxes(groupID: groupID))
          .doc()
          .withConverter(
            fromFirestore: GroupCategoryAxis.fromFirestore,
            toFirestore: GroupCategoryAxis.toFirestore,
          );

  CollectionReference<GroupCategory> categoriesReference({
    required String categoryAxisID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.categories(
              groupID: groupID, categoryAxisID: categoryAxisID))
          .withConverter(
            fromFirestore: GroupCategory.fromFirestore,
            toFirestore: GroupCategory.toFirestore,
          );

  DocumentReference<GroupCategory> categoryReference({
    required String categoryAxisID,
    required String categoryID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.categories(
              groupID: groupID, categoryAxisID: categoryAxisID))
          .doc(categoryID)
          .withConverter(
            fromFirestore: GroupCategory.fromFirestore,
            toFirestore: GroupCategory.toFirestore,
          );

  DocumentReference<GroupCategory> newCategoryReference({
    required String categoryAxisID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.categories(
              groupID: groupID, categoryAxisID: categoryAxisID))
          .doc()
          .withConverter(
            fromFirestore: GroupCategory.fromFirestore,
            toFirestore: GroupCategory.toFirestore,
          );

  CollectionReference<GroupUserProfile> userProfilesReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.userProfiles(groupID: groupID))
          .withConverter(
            fromFirestore: GroupUserProfile.fromFirestore,
            toFirestore: GroupUserProfile.toFirestore,
          );

  DocumentReference<GroupUserProfile> userProfileReference({
    required String userID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.userProfiles(groupID: groupID))
          .doc(GroupUserProfile.documentID(groupID: groupID, userID: userID))
          .withConverter(
            fromFirestore: GroupUserProfile.fromFirestore,
            toFirestore: GroupUserProfile.toFirestore,
          );
}

class UserDatabaseResolver extends HookConsumerWidget {
  final Widget Function(BuildContext) builder;

  const UserDatabaseResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseUserChangesProvider).asData?.value;

    useEffect(() {
      if (user == null) {
        ref.invalidate(userDatabaseProvider);
      }
      return null;
    }, [user]);

    if (user != null) {
      return ProviderScope(
        overrides: [
          userDatabaseProvider
              .overrideWith((ref) => UserDatabase(userID: user.uid))
        ],
        child: Consumer(
          builder: ((context, ref, child) => builder(context)),
        ),
      );
    } else {
      return const Loading();
    }
  }
}
