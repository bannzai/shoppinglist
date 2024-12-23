import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<Memo>> memos(MemosRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.memosReference().snapshots().map((event) => event.docs.map((doc) => doc.data()).toList());
}

@Riverpod(dependencies: [userDatabase])
Stream<Memo?> shoppingListMemo(ShoppingListMemoRef ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.shoppingMemoReference().snapshots().map((doc) => doc.data());
}
