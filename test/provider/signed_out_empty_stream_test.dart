import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import '../helpers/read_provider_future.dart';

// Issue #453: ログアウト・ユーザー切替直後のティアダウン中に古い uid で
// Firestore をクエリしないよう、currentUserIDProvider が null の間は各プロバイダが
// Firestore を一切触らず空リストを流すことを検証する。
// Firebase を初期化しないまま各 future が完了することが、null 分岐が Firestore に
// アクセスしていないことの証拠になる（アクセスすれば FirebaseFirestore.instance で例外になる）。
void main() {
  group('未認証(uid=null)時は空リストを流し Firestore を参照しない', () {
    test('userGroups は空リストを流す', () async {
      final container = ProviderContainer(
        overrides: [currentUserIDProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(
        await readProviderFuture(
          container: container,
          provider: userGroupsProvider.future,
        ),
        isEmpty,
      );
    });

    test('groupCategoryAxes は空リストを流す', () async {
      final container = ProviderContainer(
        overrides: [currentUserIDProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(
        await readProviderFuture(
          container: container,
          provider: groupCategoryAxesProvider(groupID: 'group-001').future,
        ),
        isEmpty,
      );
    });

    test('groupCategories は空リストを流す', () async {
      final container = ProviderContainer(
        overrides: [currentUserIDProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(
        await readProviderFuture(
          container: container,
          provider:
              groupCategoriesProvider(
                groupID: 'group-001',
                categoryAxisID: 'axis-001',
              ).future,
        ),
        isEmpty,
      );
    });
  });
}
