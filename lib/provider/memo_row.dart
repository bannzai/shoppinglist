import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_row.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> textMemoRows(TextMemoRowsRef ref,
    {required String memoID, required bool showChecked}) {
  final database = ref.watch(userDatabaseProvider);
  var query = database
      .memoRowsReference(memoID: memoID)
      .where(MemoRowFirestoreKeys.type, isEqualTo: 'text');
  if (!showChecked) {
    query = query.where(MemoRowFirestoreKeys.status,
        isEqualTo: MemoRowStatus.unchecked.name);
  }
  return query
      .orderBy(MemoRowFirestoreKeys.order, descending: false)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

@Riverpod(dependencies: [userDatabase])
Stream<List<MemoRow>> linkMemoRows(LinkMemoRowsRef ref,
    {required String memoID}) {
  final database = ref.watch(userDatabaseProvider);
  return database
      .memoRowsReference(memoID: memoID)
      .where(MemoRowFirestoreKeys.type, isEqualTo: 'link')
      .orderBy(MemoRowFirestoreKeys.order, descending: false)
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}

class AddTextMemoRow {
  final UserDatabase database;

  AddTextMemoRow({required this.database});

  Future<TextMemoRow> call(
      {required String memoID,
      required String message,
      required int order}) async {
    final docRef = database.memoRowsReference(memoID: memoID).doc();
    final textMemoRow = TextMemoRow(
        id: docRef.id, memoID: memoID, message: message, order: order);
    await database.memoRowsReference(memoID: memoID).add(textMemoRow);
    return textMemoRow;
  }
}

@Riverpod(dependencies: [userDatabase])
AddTextMemoRow addTextMemoRow(AddTextMemoRowRef ref) {
  return AddTextMemoRow(database: ref.watch(userDatabaseProvider));
}

class AddLinkMemoRow {
  final UserDatabase database;

  AddLinkMemoRow({required this.database});

  Future<LinkMemoRow> call({
    required String memoID,
    required String url,
    required String? metadataTitle,
    required String? metadataDescription,
    required String? metadataImageURL,
    required int order,
  }) async {
    final docRef = database.memoRowsReference(memoID: memoID).doc();
    final linkMemoRow = LinkMemoRow(
      id: docRef.id,
      memoID: memoID,
      url: url,
      metadataTitle: metadataTitle,
      metadataDescription: metadataDescription,
      metadataImageURL: metadataImageURL,
      order: order,
    );
    await database.memoRowsReference(memoID: memoID).add(linkMemoRow);
    return linkMemoRow;
  }
}

@Riverpod(dependencies: [userDatabase])
AddLinkMemoRow addLinkMemoRow(AddLinkMemoRowRef ref) {
  return AddLinkMemoRow(database: ref.watch(userDatabaseProvider));
}

class MemoRowBatchUpdate {
  final UserDatabase database;

  MemoRowBatchUpdate({required this.database});

  Future<void> call({
    required String memoID,
    required List<MemoRow> memoRows,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final memoRow in memoRows) {
      final docRef = database.memoRowsReference(memoID: memoID).doc(memoRow.id);
      batch.set(docRef, memoRow, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

@Riverpod(dependencies: [userDatabase])
MemoRowBatchUpdate memoRowBatchUpdate(MemoRowBatchUpdateRef ref) {
  return MemoRowBatchUpdate(database: ref.watch(userDatabaseProvider));
}
