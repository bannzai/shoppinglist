// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

abstract class _CollectionPath {
  static const String users = '/users';
  static String memos({required String userID}) => '/users/$userID/memos';
  static String memoRows({required String userID, required String memoID}) => '/users/$userID/memos/$memoID/memoRows';
  static String shoppingListMemo({required String userID}) => '/users/$userID/memos/shoppingList';
}

@Riverpod(keepAlive: true, dependencies: [])
UserDatabase userDatabase(UserDatabaseRef ref) {
  throw UnimplementedError('userDatabase is not implemented');
}

class UserDatabase {
  final String userID;
  UserDatabase({required this.userID});

  final FromFirestore<AppUser> _userFromFirestore = (snapshot, options) => AppUser.fromJson(snapshot.data()!..['id'] = snapshot.id);
  final ToFirestore<AppUser> _userToFirestore = (user, options) => user.toJson();
  DocumentReference<AppUser> userReference() => FirebaseFirestore.instance.collection(_CollectionPath.users).doc(userID).withConverter(
        fromFirestore: _userFromFirestore,
        toFirestore: _userToFirestore,
      );

  final FromFirestore<Memo> _memoFromFirestore = (snapshot, options) => Memo.fromJson(snapshot.data()!..['id'] = snapshot.id);
  final ToFirestore<Memo> _memoToFirestore = (memo, options) => memo.toJson();
  CollectionReference<Memo> memosReference() => FirebaseFirestore.instance.collection(_CollectionPath.memos(userID: userID)).withConverter(
        fromFirestore: _memoFromFirestore,
        toFirestore: _memoToFirestore,
      );
  DocumentReference<Memo> memoReference({
    required String memoID,
  }) =>
      FirebaseFirestore.instance.collection(_CollectionPath.memos(userID: userID)).doc(memoID).withConverter(
            fromFirestore: _memoFromFirestore,
            toFirestore: _memoToFirestore,
          );
  DocumentReference<Memo> shoppingMemoReference() =>
      FirebaseFirestore.instance.collection(_CollectionPath.memos(userID: userID)).doc('shoppingList').withConverter(
            fromFirestore: _memoFromFirestore,
            toFirestore: _memoToFirestore,
          );

  final FromFirestore<MemoRow> _memoRowFromFirestore = (snapshot, options) => MemoRow.fromJson(snapshot.data()!..['id'] = snapshot.id);
  final ToFirestore<MemoRow> _memoRowToFirestore = (memoRow, options) => memoRow.toJson();
  CollectionReference<MemoRow> memoRowsReference({required String memoID}) => FirebaseFirestore.instance
      .collection(
        _CollectionPath.memoRows(
          userID: userID,
          memoID: memoID,
        ),
      )
      .withConverter(
        fromFirestore: _memoRowFromFirestore,
        toFirestore: _memoRowToFirestore,
      );
  DocumentReference<MemoRow> memoRowReference({
    required String memoID,
    required String memoRowID,
  }) =>
      FirebaseFirestore.instance.collection(_CollectionPath.memoRows(userID: userID, memoID: memoID)).doc(memoRowID).withConverter(
            fromFirestore: _memoRowFromFirestore,
            toFirestore: _memoRowToFirestore,
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
        overrides: [userDatabaseProvider.overrideWith((ref) => UserDatabase(userID: user.uid))],
        child: Consumer(
          builder: ((context, ref, child) => builder(context)),
        ),
      );
    } else {
      return const Loading();
    }
  }
}
