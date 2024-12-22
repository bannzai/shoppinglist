import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_rows.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> memoRows(MemoRowsRef ref, {required String memoID}) {
  final database = ref.watch(userDatabaseProvider);
  return database.memoRowsReference(memoID: memoID).snapshots().map((event) => event.docs.map((doc) => doc.data()).toList());
}
