import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<Memo>> memos(MemosRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.memosReference().snapshots().map((event) => event.docs.map((doc) => doc.data()).toList());
}

class MemoAdd {
  final UserDatabase database;

  MemoAdd({required this.database});

  Future<Memo> call() async {
    final docRef = database.newMemoReference();
    final memo = Memo(
      id: docRef.id,
      name: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      status: MemoStatus.active,
    );
    await docRef.set(memo);
    return memo;
  }
}

@Riverpod(dependencies: [userDatabase])
MemoAdd memoAdd(MemoAddRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return MemoAdd(database: database);
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
