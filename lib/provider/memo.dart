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

  Future<void> call() async {
    final docRef = database.newMemoReference();
    await docRef.set(Memo(
      id: docRef.id,
      name: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      status: MemoStatus.active,
    ));
  }
}

@Riverpod(dependencies: [userDatabase])
MemoAdd memoAdd(MemoAddRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return MemoAdd(database: database);
}
