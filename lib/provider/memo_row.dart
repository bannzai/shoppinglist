import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_row.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> textMemoRows(TextMemoRowsRef ref, {required String memoID, required bool showChecked}) {
  final database = ref.watch(userDatabaseProvider);
  var query = database.memoRowsReference(memoID: memoID).where(MemoRowFirestoreKeys.type, isEqualTo: 'text');
  if (!showChecked) {
    query = query.where(MemoRowFirestoreKeys.status, isEqualTo: MemoRowStatus.unchecked.name);
  }
  return query.snapshots().map((event) => event.docs.map((doc) => doc.data()).toList());
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

class AddLinkMemoRow {
  final UserDatabase database;

  AddLinkMemoRow({required this.database});

  Future<void> call({
    required String memoID,
    required String url,
    required String? metadataTitle,
    required String? metadataDescription,
    required String? metadataImageURL,
    required int order,
  }) async {
    await database.memoRowsReference(memoID: memoID).add(LinkMemoRow(
          memoID: memoID,
          url: url,
          metadataTitle: metadataTitle,
          metadataDescription: metadataDescription,
          metadataImageURL: metadataImageURL,
          order: order,
        ));
  }
}

@Riverpod(dependencies: [userDatabase])
AddLinkMemoRow addLinkMemoRow(AddLinkMemoRowRef ref) {
  return AddLinkMemoRow(database: ref.watch(userDatabaseProvider));
}
