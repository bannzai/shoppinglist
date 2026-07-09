import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/features/group_category/category_empty_state.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testUserID = 'test-user-001';

Widget _wrap(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
    home: const GroupCategoryPage(groupID: _testGroupID),
  ),
);

void main() {
  group('GroupCategoryPage 空状態', () {
    testWidgets('軸が0件のとき CategoryEmptyState（追加ボタン付き）を表示する', (tester) async {
      await tester.pumpWidget(
        _wrap([
          currentUserIDProvider.overrideWithValue(_testUserID),
          groupCategoryAxesProvider(
            groupID: _testGroupID,
          ).overrideWith((ref) => Stream.value(const [])),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryEmptyState), findsOneWidget);
      // 初回空状態はカード内に追加ボタンを持つ
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('軸はあるがカテゴリ0件のとき CategoryEmptyState（追加ボタンなし）を表示する', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap([
          customerInfoProvider.overrideWith(
            (ref) => const Stream<CustomerInfo>.empty(),
          ),
          currentUserIDProvider.overrideWithValue(_testUserID),
          groupCategoryAxesProvider(groupID: _testGroupID).overrideWith(
            (ref) => Stream.value(const [
              GroupCategoryAxis(
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
          ).overrideWith((ref) => Stream.value(const [])),
          shoppingLocationsProvider(
            groupID: _testGroupID,
          ).overrideWith((ref) => Stream.value(const [])),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryEmptyState), findsOneWidget);
      // カード内ボタンは出さず、追加導線は FloatingActionButton が担う
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
