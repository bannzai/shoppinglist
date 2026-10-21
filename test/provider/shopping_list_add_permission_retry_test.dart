import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list.dart';

const _testGroupID = 'group-1';

// ignore: subtype_of_sealed_class
/// set の結果を 1 回ずつ差し替えられる買い物リストの DocumentReference。
// ignore: must_be_immutable
class _FakeShoppingListReference
    implements DocumentReference<GroupShoppingList> {
  _FakeShoppingListReference({required this.setErrors});

  /// set の各呼び出しで投げる例外。null はその回の set を成功させる。
  final List<Object?> setErrors;

  /// set が呼ばれた回数。
  int setCallCount = 0;

  @override
  String get id => 'list-1';

  @override
  Future<void> set(GroupShoppingList data, [SetOptions? options]) async {
    final setError = setErrors[setCallCount];
    setCallCount += 1;
    if (setError != null) {
      throw setError;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// 上限判定と名前の採番に使う件数を固定で返す GroupDatabase。
class _FakeGroupDatabase implements GroupDatabase {
  _FakeGroupDatabase({required this.newShoppingListReference});

  /// newGroupShoppingListReference が返す参照。
  final _FakeShoppingListReference newShoppingListReference;

  @override
  DocumentReference<GroupShoppingList> newGroupShoppingListReference() =>
      newShoppingListReference;

  @override
  Future<int> countOfGroupShoppingListsCreatedOn({
    required DateTime date,
  }) async => 0;

  @override
  Future<int> countOfActiveGroupShoppingLists() async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

FirebaseException _permissionDenied() =>
    FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');

void main() {
  group('ShoppingListAdd の permission-denied からの再試行 (Issue #683)', () {
    test('プレミアムなら写しを同期してから 1 回だけ書き直す', () async {
      final shoppingListReference = _FakeShoppingListReference(
        setErrors: [_permissionDenied(), null],
      );
      var premiumEntitlementSyncCount = 0;
      final shoppingListAdd = ShoppingListAdd(
        database: _FakeGroupDatabase(
          newShoppingListReference: shoppingListReference,
        ),
        isPremiumResolver: () => true,
        premiumEntitlementSyncer: () async => premiumEntitlementSyncCount += 1,
      );

      await shoppingListAdd.call(
        createUserID: 'user-1',
        groupID: _testGroupID,
        shoppingLocationID: null,
        duplicatedFromGroupShoppingListID: null,
      );

      expect(premiumEntitlementSyncCount, 1);
      expect(shoppingListReference.setCallCount, 2);
    });

    test('無料ユーザーの permission-denied は同期せずそのまま投げる', () async {
      final shoppingListReference = _FakeShoppingListReference(
        setErrors: [_permissionDenied()],
      );
      var premiumEntitlementSyncCount = 0;
      final shoppingListAdd = ShoppingListAdd(
        database: _FakeGroupDatabase(
          newShoppingListReference: shoppingListReference,
        ),
        isPremiumResolver: () => false,
        premiumEntitlementSyncer: () async => premiumEntitlementSyncCount += 1,
      );

      await expectLater(
        shoppingListAdd.call(
          createUserID: 'user-1',
          groupID: _testGroupID,
          shoppingLocationID: null,
          duplicatedFromGroupShoppingListID: null,
        ),
        throwsA(
          isA<FirebaseException>().having(
            (error) => error.code,
            'code',
            'permission-denied',
          ),
        ),
      );
      expect(premiumEntitlementSyncCount, 0);
      expect(shoppingListReference.setCallCount, 1);
    });

    test('permission-denied 以外の失敗はプレミアムでも同期せずそのまま投げる', () async {
      final shoppingListReference = _FakeShoppingListReference(
        setErrors: [
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ],
      );
      var premiumEntitlementSyncCount = 0;
      final shoppingListAdd = ShoppingListAdd(
        database: _FakeGroupDatabase(
          newShoppingListReference: shoppingListReference,
        ),
        isPremiumResolver: () => true,
        premiumEntitlementSyncer: () async => premiumEntitlementSyncCount += 1,
      );

      await expectLater(
        shoppingListAdd.call(
          createUserID: 'user-1',
          groupID: _testGroupID,
          shoppingLocationID: null,
          duplicatedFromGroupShoppingListID: null,
        ),
        throwsA(isA<FirebaseException>()),
      );
      expect(premiumEntitlementSyncCount, 0);
    });
  });
}
