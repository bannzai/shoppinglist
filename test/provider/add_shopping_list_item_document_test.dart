import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

/// アプリが新しいアイテムを追加する時のパスと文書の形。iOS の Siri・ショートカットからの追加
/// (ios/RunnerTests/ShoppingListItemAdditionTests.swift) も同じファイルと照合する。
final Map<String, dynamic> _fixture =
    jsonDecode(
          File(
            'test/fixtures/new_shopping_list_item_document.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

/// set() に渡されたアイテムを記録する [GroupDatabase] のフェイク。
/// 本物は FirebaseFirestore.instance に触れて未初期化の test 環境で落ちるため差し替える。
class _CapturingGroupDatabase extends GroupDatabase {
  /// set() に渡されたアイテムの記録先。
  final List<GroupShoppingListItem> writtenItems = [];

  _CapturingGroupDatabase({required super.groupID});

  @override
  CollectionReference<GroupShoppingListItem> shoppingListItemsReference({
    required String shoppingListID,
  }) => _CapturingShoppingListItemsReference(writtenItems: writtenItems);
}

// ignore: subtype_of_sealed_class
/// doc() だけを実装した [CollectionReference] のフェイク。
class _CapturingShoppingListItemsReference extends Fake
    implements CollectionReference<GroupShoppingListItem> {
  /// set() に渡されたアイテムの記録先 ([_CapturingGroupDatabase] と共有)。
  final List<GroupShoppingListItem> writtenItems;

  _CapturingShoppingListItemsReference({required this.writtenItems});

  @override
  DocumentReference<GroupShoppingListItem> doc([String? path]) =>
      _CapturingShoppingListItemReference(writtenItems: writtenItems);
}

// ignore: subtype_of_sealed_class
/// id と set() だけを実装した [DocumentReference] のフェイク。
class _CapturingShoppingListItemReference extends Fake
    implements DocumentReference<GroupShoppingListItem> {
  /// set() に渡されたアイテムの記録先 ([_CapturingGroupDatabase] と共有)。
  final List<GroupShoppingListItem> writtenItems;

  _CapturingShoppingListItemReference({required this.writtenItems});

  @override
  String get id => (_fixture['document'] as Map<String, dynamic>)['id'];

  @override
  Future<void> set(GroupShoppingListItem data, [SetOptions? options]) async {
    writtenItems.add(data);
  }
}

/// Firestore に渡す値を、fixture の JSON で表せる形にして返す。
/// 時刻は実行のたびに変わるため、クライアントの時刻かサーバーの時刻かの区別だけを残す。
Object? _comparableFirestoreValue(Object? value) => switch (value) {
  Timestamp() => '<client timestamp>',
  FieldValue() => '<server timestamp>',
  _ => value,
};

void main() {
  final fixtureDocument = _fixture['document'] as Map<String, dynamic>;

  test('アプリが追加するアイテムの文書のフィールドが fixture と一致する', () async {
    final database = _CapturingGroupDatabase(
      groupID: fixtureDocument['groupID'],
    );

    await AddShoppingListItem(database: database).call(
      shoppingListID: fixtureDocument['shoppingListID'],
      userID: fixtureDocument['userID'],
      message: fixtureDocument['message'],
      order: fixtureDocument['order'],
      description: null,
      color: null,
    );

    expect(
      GroupShoppingListItem.toFirestore(
        database.writtenItems.single,
        null,
      ).map((key, value) => MapEntry(key, _comparableFirestoreValue(value))),
      fixtureDocument,
    );
  });

  test('アプリがアイテムを書き込むコレクションパスが fixture と一致する', () {
    expect(
      shoppingListItemsCollectionPath(
        groupID: fixtureDocument['groupID'],
        shoppingListID: fixtureDocument['shoppingListID'],
        // Dart 側は先頭に / を付けている。Firestore は先頭の / の有無を区別しないため外して比べる
      ).replaceFirst(RegExp('^/'), ''),
      _fixture['collectionPath'],
    );
  });

  test('末尾のアイテムの次の order は末尾の order + 1 で、アイテムが無ければ 0', () {
    final item = GroupShoppingListItem.fromJson({
      ...fixtureDocument,
      'createdDateTime': null,
      'serverCreatedDateTime': null,
      'serverUpdatedDateTime': null,
    });

    expect(<GroupShoppingListItem>[].nextOrder, 0);
    expect([item].nextOrder, (fixtureDocument['order'] as int) + 1);
    // アプリの一覧は order の昇順で、末尾が order の最大。iOS の intent は order が最大のアイテムの order + 1 を使う
    expect([item, item.copyWith(order: 7)].nextOrder, 8);
  });
}
