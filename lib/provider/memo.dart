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
