import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_row.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> textMemoRows(TextMemoRowsRef ref, {required String memoID, required bool showChecked, required bool showDeleted}) {
  final database = ref.watch(userDatabaseProvider);
  var query = database
      .memoRowsReference(memoID: memoID)
      .where(MemoRowFirestoreKeys.type, isEqualTo: 'text')
      .where(MemoRowFirestoreKeys.status, isEqualTo: showChecked ? MemoRowStatus.checked : MemoRowStatus.unchecked);
  if (showDeleted) {
    query = query.where(MemoRowFirestoreKeys.deletedDateTime, isNotEqualTo: null);
  } else {
    query = query.where(MemoRowFirestoreKeys.deletedDateTime, isEqualTo: null);
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

  Future<void> call(
      {required String memoID,
      required String url,
      required String? metadataTitle,
      required String? metadataDescription,
      required String? metadataImageURL}) async {
    await database.memoRowsReference(memoID: memoID).add(LinkMemoRow(
          memoID: memoID,
          url: url,
          metadataTitle: metadataTitle,
          metadataDescription: metadataDescription,
          metadataImageURL: metadataImageURL,
        ));
  }
}

@Riverpod(dependencies: [userDatabase])
AddLinkMemoRow addLinkMemoRow(AddLinkMemoRowRef ref) {
  return AddLinkMemoRow(database: ref.watch(userDatabaseProvider));
}
