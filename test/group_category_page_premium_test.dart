import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'helpers/localized_test_app.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testUserID = 'test-user-001';
const _testLocationID = 'test-location-001';

List<GroupCategory> _testCategories() => [
  const GroupCategory(
    id: 'cat-001',
    groupID: _testGroupID,
    userID: _testUserID,
    groupCategoryAxisID: _testCategoryAxisID,
    name: '食品',
    order: 0,
    locationOrders: {},
    keywords: [],
    color: null,
    iconName: null,
  ),
  const GroupCategory(
    id: 'cat-002',
    groupID: _testGroupID,
    userID: _testUserID,
    groupCategoryAxisID: _testCategoryAxisID,
    name: '日用品',
    order: 1,
    locationOrders: {},
    keywords: [],
    color: null,
    iconName: null,
  ),
];

/// 非プレミアムユーザー用のprovider overrides
List<Override> _nonPremiumOverrides() {
  return [
    // customerInfoProviderを空StreamでオーバーライドするとAsyncLoading状態になり、
    // .asData が null → isPremium ?? false = false（非プレミアム）
    customerInfoProvider.overrideWith(
      (ref) => const Stream<CustomerInfo>.empty(),
    ),
    currentUserIDProvider.overrideWithValue(_testUserID),
    groupCategoryAxesProvider(groupID: _testGroupID).overrideWith(
      (ref) => Stream.value([
        const GroupCategoryAxis(
          id: _testCategoryAxisID,
          groupID: _testGroupID,
          userID: _testUserID,
          name: '売り場',
          order: 0,
        ),
      ]),
    ),
    groupCategoriesProvider(
      groupID: _testGroupID,
      categoryAxisID: _testCategoryAxisID,
    ).overrideWith((ref) => Stream.value(_testCategories())),
    shoppingLocationsProvider(groupID: _testGroupID).overrideWith(
      (ref) => Stream.value([
        const GroupShoppingLocation(
          id: _testLocationID,
          groupID: _testGroupID,
          name: 'テストスーパー',
          latitude: null,
          longitude: null,
          geofenceRadiusMeters: null,
        ),
      ]),
    ),
    groupCategoryAddProvider(
      groupID: _testGroupID,
    ).overrideWith((ref) => _NoOpCategoryAdd()),
    groupCategoryDeleteProvider(
      groupID: _testGroupID,
    ).overrideWith((ref) => _NoOpCategoryDelete()),
    groupCategoryBatchUpdateProvider(
      groupID: _testGroupID,
    ).overrideWith((ref) => _NoOpCategoryBatchUpdate()),
    groupCategoryAxisAddProvider(
      groupID: _testGroupID,
    ).overrideWith((ref) => _NoOpCategoryAxisAdd()),
  ];
}

/// テスト用のNo-Op操作クラス
class _NoOpCategoryAdd extends GroupCategoryAdd {
  _NoOpCategoryAdd() : super(database: GroupDatabase(groupID: _testGroupID));

  @override
  Future<GroupCategory> call({
    required String groupID,
    required String userID,
    required String categoryAxisID,
    required String name,
    required int order,
  }) async {
    return _testCategories().first;
  }
}

class _NoOpCategoryDelete extends GroupCategoryDelete {
  _NoOpCategoryDelete() : super(database: GroupDatabase(groupID: _testGroupID));

  @override
  Future<void> call({
    required String categoryAxisID,
    required String categoryID,
  }) async {}
}

class _NoOpCategoryBatchUpdate extends GroupCategoryBatchUpdate {
  bool called = false;

  _NoOpCategoryBatchUpdate()
    : super(database: GroupDatabase(groupID: _testGroupID));

  @override
  Future<void> call({
    required String categoryAxisID,
    required List<GroupCategory> categories,
  }) async {
    called = true;
  }
}

class _NoOpCategoryAxisAdd extends GroupCategoryAxisAdd {
  _NoOpCategoryAxisAdd()
    : super(database: GroupDatabase(groupID: _testGroupID));

  @override
  Future<GroupCategoryAxis> call({
    required String groupID,
    required String userID,
    required String name,
    required int order,
  }) async {
    return const GroupCategoryAxis(
      id: _testCategoryAxisID,
      groupID: _testGroupID,
      userID: _testUserID,
      name: '売り場',
      order: 0,
    );
  }
}

void main() {
  group('GroupCategoryPage 買い物する場所の並び順', () {
    // 位置情報機能はファーストリリースでは非表示 (issue #465)。
    // shoppingLocationFeatureEnabled を true に戻す際は、ロックアイコン表示・
    // 非プレミアム選択時の SnackBar 表示のプレミアムゲーティングテストを復活させること
    // (git 履歴のこのテストファイルを参照)。
    testWidgets('店舗が存在してもドロップダウンは表示されない (issue #465)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _nonPremiumOverrides(),
          child: localizedTestApp(
            theme: buildAppTheme(accent: AccentPreset.shu),
            home: const GroupCategoryPage(groupID: _testGroupID),
          ),
        ),
      );

      // StreamProviderのデータ読み込みを待つ
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });

  group('GroupCategoryPage カテゴリ追加の遷移', () {
    testWidgets('FABタップでダイアログを出さず編集画面へ直接遷移する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _nonPremiumOverrides(),
          child: localizedTestApp(
            theme: buildAppTheme(accent: AccentPreset.shu),
            home: const GroupCategoryPage(groupID: _testGroupID),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // カテゴリ追加FABをタップ
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 旧仕様の追加ダイアログ（AlertDialog）は表示されない
      expect(find.byType(AlertDialog), findsNothing);
      // 編集画面（AppBarタイトル「カテゴリ編集」）へ遷移している
      expect(find.text('カテゴリ編集'), findsOneWidget);
    });
  });
}
