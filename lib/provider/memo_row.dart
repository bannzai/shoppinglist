import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_row.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> textMemoRows(TextMemoRowsRef ref, {required String memoID}) {
  final database = ref.watch(userDatabaseProvider);
  return database
      .memoRowsReference(memoID: memoID)
      .where(MemoRowFirestoreKeys.type, isEqualTo: 'text')
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> linkMemoRows(LinkMemoRowsRef ref, {required String memoID}) {
  final database = ref.watch(userDatabaseProvider);
  return database
      .memoRowsReference(memoID: memoID)
      .where(MemoRowFirestoreKeys.type, isEqualTo: 'link')
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

@Riverpod(dependencies: [userDatabase])
Future<void> addLinkMemoRow(AddLinkMemoRowRef ref, {required String memoID, required String url}) async {
  final database = ref.watch(userDatabaseProvider);
  await database.memoRowsReference(memoID: memoID).add(LinkMemoRow(memoID: memoID, url: url));
}
