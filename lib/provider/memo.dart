import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/app_user.dart';

part 'memo.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<Memo>> memos(MemosRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return database
      .memosReference()
      .orderBy(MemoFirestoreKeys.createdDateTime, descending: true)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class MemoAdd {
  final AppUser? appUser;
  final UserDatabase database;

  MemoAdd({required this.appUser, required this.database});

  Future<Memo> call() async {
    final userID = appUser?.id;
    if (userID == null) {
      throw Exception('User ID is null');
    }
    final docRef = database.newMemoReference();
    final count = await database.countOfMemos();
    final memo = Memo(
      id: docRef.id,
      userID: userID,
      name: count == 0 ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ($count)',
      status: MemoStatus.active,
    );
    await docRef.set(memo);
    return memo;
  }
}

@Riverpod(dependencies: [userDatabase])
MemoAdd memoAdd(MemoAddRef ref) {
  final database = ref.watch(userDatabaseProvider);
  final appUser = ref.watch(appUserProvider).valueOrNull;
  return MemoAdd(database: database, appUser: appUser);
}

class MemoDelete {
  final UserDatabase database;

  MemoDelete({required this.database});

  Future<void> call({required String memoID}) async {
    final docRef = database.memoReference(memoID: memoID);
    await docRef.delete();
  }
}

@Riverpod(dependencies: [userDatabase])
MemoDelete memoDelete(MemoDeleteRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return MemoDelete(database: database);
}

class MemoUpdate {
  final UserDatabase database;

  MemoUpdate({required this.database});

  Future<void> call({required String memoID, required Memo memo}) async {
    final docRef = database.memoReference(memoID: memoID);
    await docRef.set(memo);
  }
}

@Riverpod(dependencies: [userDatabase])
MemoUpdate memoUpdate(MemoUpdateRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return MemoUpdate(database: database);
}
