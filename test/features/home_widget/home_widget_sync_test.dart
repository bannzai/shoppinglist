import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/home_widget/home_widget_sync.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/current_group_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/user_groups.dart';

const _testGroupID = 'group-1';
const _testShoppingListID = 'list-1';
const _testUserID = 'user-1';

/// currentGroupIDProvider をテスト用に固定値へ差し替えるための Notifier。
/// CurrentGroupResolver が defaultGroupID から初期化する処理を Widget test では
/// 再現しないため、直接 build() で固定値を返す。
class _FixedCurrentGroupID extends CurrentGroupID {
  _FixedCurrentGroupID(this._value);
  final String _value;

  @override
  String? build() => _value;
}

/// AppEntityPrepareResolver を模した host。HomeWidgetSync がマウントされるより先に
/// 同じ shoppingListsProvider を ref.watch することで、Issue #475 の再現条件
/// (Provider が既に AsyncData に解決済みの状態で HomeWidgetSync が初めて build される)を作る。
class _PreResolvedHost extends ConsumerWidget {
  final bool mountChild;
  const _PreResolvedHost({required this.mountChild});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(shoppingListsProvider(groupID: _testGroupID, isPremium: false));
    if (!mountChild) {
      return const SizedBox.shrink();
    }
    return HomeWidgetSync(builder: (context) => const SizedBox.shrink());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('買い物リスト一覧が既に解決済みの状態でマウントされても初回同期される(Issue #475)', (tester) async {
    final controller = StreamController<List<GroupShoppingList>>.broadcast();
    addTearDown(controller.close);

    final overrides = [
      currentGroupIDProvider.overrideWith(
        () => _FixedCurrentGroupID(_testGroupID),
      ),
      firestoreIsPremiumProvider.overrideWith((ref) async => false),
      appUserProvider.overrideWith(
        (ref) => Stream.value(
          const AppUser(
            id: _testUserID,
            defaultGroupID: _testGroupID,
            themeColorHex: '#C2410C',
          ),
        ),
      ),
      userGroupsProvider.overrideWith(
        (ref) => Stream.value(const [
          Group(
            id: _testGroupID,
            memberUserIDs: [_testUserID],
            name: 'テストグループ',
          ),
        ]),
      ),
      shoppingListsProvider(
        groupID: _testGroupID,
        isPremium: false,
      ).overrideWith((ref) => controller.stream),
      textShoppingListItemsProvider(
        groupID: _testGroupID,
        shoppingListID: _testShoppingListID,
      ).overrideWith((ref) => Stream.value(const [])),
    ];

    Widget buildTree({required bool mountChild}) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: _PreResolvedHost(mountChild: mountChild)),
    );

    // HomeWidgetSync をまだマウントせず、祖先相当の watch だけで
    // shoppingListsProvider を AsyncData まで解決させる。
    await tester.pumpWidget(buildTree(mountChild: false));
    controller.add([
      const GroupShoppingList(
        id: _testShoppingListID,
        createUserID: _testUserID,
        groupID: _testGroupID,
        name: '買い物リスト',
        shoppingLocationID: null,
        duplicatedFromGroupShoppingListID: null,
        ttlExpiresDateTime: null,
      ),
    ]);
    await tester.pump();
    await tester.pump();

    // 解決済みの Provider の下で HomeWidgetSync を初めてマウントする。
    await tester.pumpWidget(buildTree(mountChild: true));
    await tester.pump();

    expect(
      calls.any(
        (c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_shopping_lists',
      ),
      isTrue,
      reason: '初回マウント時点で買い物リスト一覧が同期されているべき',
    );
    expect(
      calls.any(
        (c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'widget_current_group_id' &&
            c.arguments['data'] == _testGroupID,
      ),
      isTrue,
      reason: '初回マウント時点で widget_current_group_id が同期されているべき',
    );
  });
}
