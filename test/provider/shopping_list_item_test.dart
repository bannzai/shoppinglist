import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

/// 検証用アイテム。id / message / status / description 以外は固定。
GroupShoppingListItem _item({
  required String id,
  required String message,
  GroupShoppingListItemStatus status = GroupShoppingListItemStatus.unchecked,
  String? description,
}) {
  return GroupShoppingListItem(
    id: id,
    groupID: mockGroupID,
    shoppingListID: mockShoppingListID,
    userID: mockUserID,
    message: message,
    order: 0,
    status: status,
    checkedByUserID: null,
    description: description,
    color: null,
    imageURL: null,
    lastEditedByUserID: null,
  );
}

/// `.update({...})` に渡された map を記録する [GroupDatabase] のフェイク。
/// 本物は FirebaseFirestore.instance に触れて未初期化の test 環境で落ちるため差し替える。
class _CapturingGroupDatabase extends GroupDatabase {
  /// update() に渡された map の記録先。
  final List<Map<Object, Object?>> updates = [];

  _CapturingGroupDatabase() : super(groupID: mockGroupID);

  @override
  CollectionReference<GroupShoppingListItem> shoppingListItemsReference({
    required String shoppingListID,
  }) => _CapturingShoppingListItemsReference(updates: updates);
}

// ignore: subtype_of_sealed_class
/// doc() だけを実装した [CollectionReference] のフェイク。
class _CapturingShoppingListItemsReference extends Fake
    implements CollectionReference<GroupShoppingListItem> {
  /// update() に渡された map の記録先 ([_CapturingGroupDatabase] と共有)。
  final List<Map<Object, Object?>> updates;

  _CapturingShoppingListItemsReference({required this.updates});

  @override
  DocumentReference<GroupShoppingListItem> doc([String? path]) =>
      _CapturingShoppingListItemReference(updates: updates);
}

// ignore: subtype_of_sealed_class
/// update() だけを実装した [DocumentReference] のフェイク。
class _CapturingShoppingListItemReference extends Fake
    implements DocumentReference<GroupShoppingListItem> {
  /// update() に渡された map の記録先 ([_CapturingGroupDatabase] と共有)。
  final List<Map<Object, Object?>> updates;

  _CapturingShoppingListItemReference({required this.updates});

  @override
  Future<void> update(Map<Object, Object?> data) async => updates.add(data);
}

void main() {
  group('ToggleShoppingListItemCheck の部分更新（並行編集の巻き戻し防止）', () {
    test(
      'チェック時: status / checkedByUserID / lastCheckedDateTime とサーバータイムスタンプのみ更新し、message や説明は書かない',
      () async {
        final database = _CapturingGroupDatabase();
        await ToggleShoppingListItemCheck(database: database).call(
          shoppingListID: mockShoppingListID,
          item: _item(
            id: 'item-1',
            message: '牛乳',
            description: '低脂肪 1L',
            status: GroupShoppingListItemStatus.unchecked,
          ),
          userID: mockUserID,
        );
        final data = database.updates.single;
        // チェック状態と付随フィールドだけが書かれる。
        expect(
          data[GroupShoppingListItemFirestoreKeys.status],
          GroupShoppingListItemStatus.checked.name,
        );
        expect(
          data[GroupShoppingListItemFirestoreKeys.checkedByUserID],
          mockUserID,
        );
        expect(
          data[GroupShoppingListItemFirestoreKeys.lastCheckedDateTime],
          isA<Timestamp>(),
        );
        // firestore-timestamp-rules に従いサーバータイムスタンプを付与する。
        expect(
          data[GroupShoppingListItemFirestoreKeys.updatedDateTime],
          isA<FieldValue>(),
        );
        expect(
          data[GroupShoppingListItemFirestoreKeys.serverUpdatedDateTime],
          isA<FieldValue>(),
        );
        // 巻き戻し防止: build 時点の古い message / description / order / imageURL は書かない。
        expect(data.containsKey('message'), isFalse);
        expect(data.containsKey('description'), isFalse);
        expect(
          data.containsKey(GroupShoppingListItemFirestoreKeys.order),
          isFalse,
        );
        expect(
          data.containsKey(GroupShoppingListItemFirestoreKeys.imageURL),
          isFalse,
        );
      },
    );

    test(
      'チェック解除時: status とサーバータイムスタンプのみ更新し、lastCheckedDateTime / checkedByUserID はクリアしない',
      () async {
        final database = _CapturingGroupDatabase();
        await ToggleShoppingListItemCheck(database: database).call(
          shoppingListID: mockShoppingListID,
          item: _item(
            id: 'item-1',
            message: '牛乳',
            description: '低脂肪 1L',
            status: GroupShoppingListItemStatus.checked,
          ),
          userID: mockUserID,
        );
        final data = database.updates.single;
        expect(
          data[GroupShoppingListItemFirestoreKeys.status],
          GroupShoppingListItemStatus.unchecked.name,
        );
        // lastCheckedDateTime / checkedByUserID はキー自体を書かない(クリアしない)。
        expect(
          data.containsKey(
            GroupShoppingListItemFirestoreKeys.lastCheckedDateTime,
          ),
          isFalse,
        );
        expect(
          data.containsKey(GroupShoppingListItemFirestoreKeys.checkedByUserID),
          isFalse,
        );
        // message / description も書かない。
        expect(data.containsKey('message'), isFalse);
        expect(data.containsKey('description'), isFalse);
        // サーバータイムスタンプは付与する。
        expect(
          data[GroupShoppingListItemFirestoreKeys.updatedDateTime],
          isA<FieldValue>(),
        );
        expect(
          data[GroupShoppingListItemFirestoreKeys.serverUpdatedDateTime],
          isA<FieldValue>(),
        );
      },
    );
  });
}
