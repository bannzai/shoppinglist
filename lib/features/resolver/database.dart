// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/shopping_list.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

abstract class _CollectionPath {
  static const String users = '/users';
  static String shoppingLists({required String groupID}) =>
      '/groups/$groupID/shoppingLists';
  static String shoppingListItems(
          {required String groupID, required String shoppingListID}) =>
      '/groups/$groupID/shoppingLists/$shoppingListID/items';
}

@Riverpod(keepAlive: true, dependencies: [])
UserDatabase userDatabase(UserDatabaseRef ref) {
  throw UnimplementedError('userDatabase is not implemented');
}

class UserDatabase {
  final String userID;
  UserDatabase({required this.userID});

  final FromFirestore<AppUser> _userFromFirestore = (snapshot, options) =>
      AppUser.fromJson(snapshot.data()!..['id'] = snapshot.id);
  final ToFirestore<AppUser> _userToFirestore =
      (user, options) => user.toJson();
  DocumentReference<AppUser> userReference() => FirebaseFirestore.instance
      .collection(_CollectionPath.users)
      .doc(userID)
      .withConverter(
        fromFirestore: _userFromFirestore,
        toFirestore: _userToFirestore,
      );
}

@Riverpod(keepAlive: true, dependencies: [])
GroupDatabase groupDatabase(GroupDatabaseRef ref) {
  throw UnimplementedError('groupDatabase is not implemented');
}

class GroupDatabase {
  final String groupID;
  GroupDatabase({required this.groupID});

  final FromFirestore<ShoppingList> _shoppingListFromFirestore =
      (snapshot, options) =>
          ShoppingList.fromJson(snapshot.data()!..['id'] = snapshot.id);
  final ToFirestore<ShoppingList> _shoppingListToFirestore =
      (shoppingList, options) => shoppingList.toJson();
  CollectionReference<ShoppingList> shoppingListsReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLists(groupID: groupID))
          .withConverter(
            fromFirestore: _shoppingListFromFirestore,
            toFirestore: _shoppingListToFirestore,
          );
  Future<int> countOfShoppingLists() async {
    final aggregated = await FirebaseFirestore.instance
        .collection(_CollectionPath.shoppingLists(groupID: groupID))
        .count()
        .get();
    return aggregated.count ?? 0;
  }

  DocumentReference<ShoppingList> shoppingListReference({
    required String shoppingListID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLists(groupID: groupID))
          .doc(shoppingListID)
          .withConverter(
            fromFirestore: _shoppingListFromFirestore,
            toFirestore: _shoppingListToFirestore,
          );
  DocumentReference<ShoppingList> newShoppingListReference() =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingLists(groupID: groupID))
          .doc()
          .withConverter(
            fromFirestore: _shoppingListFromFirestore,
            toFirestore: _shoppingListToFirestore,
          );

  final FromFirestore<ShoppingListItem> _shoppingListItemFromFirestore =
      (snapshot, options) =>
          ShoppingListItem.fromJson(snapshot.data()!..['id'] = snapshot.id);
  final ToFirestore<ShoppingListItem> _shoppingListItemToFirestore =
      (item, options) => item.toJson();
  CollectionReference<ShoppingListItem> shoppingListItemsReference(
          {required String shoppingListID}) =>
      FirebaseFirestore.instance
          .collection(
            _CollectionPath.shoppingListItems(
              groupID: groupID,
              shoppingListID: shoppingListID,
            ),
          )
          .withConverter(
            fromFirestore: _shoppingListItemFromFirestore,
            toFirestore: _shoppingListItemToFirestore,
          );

  DocumentReference<ShoppingListItem> shoppingListItemReference({
    required String shoppingListID,
    required String itemID,
  }) =>
      FirebaseFirestore.instance
          .collection(_CollectionPath.shoppingListItems(
              groupID: groupID, shoppingListID: shoppingListID))
          .doc(itemID)
          .withConverter(
            fromFirestore: _shoppingListItemFromFirestore,
            toFirestore: _shoppingListItemToFirestore,
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

class GroupDatabaseResolver extends HookConsumerWidget {
  final String groupID;
  final Widget Function(BuildContext) builder;

  const GroupDatabaseResolver(
      {super.key, required this.groupID, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        groupDatabaseProvider
            .overrideWith((ref) => GroupDatabase(groupID: groupID))
      ],
      child: Consumer(
        builder: ((context, ref, child) => builder(context)),
      ),
    );
  }
}
