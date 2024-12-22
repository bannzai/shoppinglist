import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memos.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<Memo>> memos(MemosRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.memosReference().snapshots().map((event) => event.docs.map((doc) => doc.data()).toList());
}
