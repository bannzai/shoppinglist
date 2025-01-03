import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/memo_row.dart';

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
  final UserDatabase database;

  MemoAdd({required this.database});

  Future<Memo> call({required String userID}) async {
    final docRef = database.newMemoReference();
    final count = await database.countOfMemos();
    final memo = Memo(
      id: docRef.id,
      userID: userID,
      name: count == 0 ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ($count)',
      status: MemoStatus.active,
      ttlExpiresDateTime: DateTime.now().add(const Duration(days: 30)),
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

class MemoDuplicate {
  final MemoAdd memoAdd;
  final AddTextMemoRow addTextMemoRow;
  final UserDatabase database;

  MemoDuplicate({required this.memoAdd, required this.addTextMemoRow, required this.database});

  Future<Memo> call({required String userID, required List<MemoRow> memoRows}) async {
    final memo = await memoAdd(userID: userID);
    for (var memoRow in memoRows) {
      if (memoRow is TextMemoRow) {
        await addTextMemoRow(
          memoID: memo.id,
          message: memoRow.message,
          order: memoRow.order,
        );
      }
    }

    return memo;
  }
}

@Riverpod(dependencies: [memoAdd, addTextMemoRow, userDatabase])
MemoDuplicate memoDuplicate(MemoDuplicateRef ref) {
  final memoAdd = ref.watch(memoAddProvider);
  final addTextMemoRow = ref.watch(addTextMemoRowProvider);
  final database = ref.watch(userDatabaseProvider);
  return MemoDuplicate(memoAdd: memoAdd, addTextMemoRow: addTextMemoRow, database: database);
}
