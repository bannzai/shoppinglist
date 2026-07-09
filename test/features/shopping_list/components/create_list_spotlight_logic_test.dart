import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_spotlight.dart';

/// リスト追加スポットライトの表示判定純粋関数 [shouldShowCreateListSpotlight] の検証(Issue #494)。
/// 日付境界・1時間境界・機会ごとの表示済み抑止・再表示・null 入力を網羅する。
void main() {
  group('cond1 (日次ナッジ: 最後のリスト作成日から日付が変わった)', () {
    test('昨日 23:59 作成 → 今日 00:01 で true (24時間ではなくローカル日付で判定)', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 2, 0, 1),
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 23, 59),
          lastShoppingListItemCheckedDateTime: null,
          spotlightLastShownDateTime: null,
        ),
        isTrue,
      );
    });

    test('同日の作成なら false', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 1, 12, 0),
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 8, 0),
          lastShoppingListItemCheckedDateTime: null,
          spotlightLastShownDateTime: null,
        ),
        isFalse,
      );
    });

    test('今日すでに表示済みなら cond1 は抑止される', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 2, 10, 0),
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 20, 0),
          lastShoppingListItemCheckedDateTime: null,
          // 今日(1/2)の朝に表示済み。
          spotlightLastShownDateTime: DateTime(2024, 1, 2, 9, 0),
        ),
        isFalse,
      );
    });

    test('表示した翌日にリスト未作成なら cond1 で再表示される', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 2, 9, 0),
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 20, 0),
          lastShoppingListItemCheckedDateTime: null,
          // 昨日(1/1)に表示済み。日付が変わったので再度出す。
          spotlightLastShownDateTime: DateTime(2024, 1, 1, 20, 5),
        ),
        isTrue,
      );
    });
  });

  group('cond2 (チェック後の再訪ナッジ: 最後のチェックから1時間経過)', () {
    // cond1 を無効化するため lastCreated は同日(または null)にする。
    test('59分では false (1時間未満)', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      expect(
        shouldShowCreateListSpotlight(
          now: now,
          lastShoppingListCreatedDateTime: null,
          lastShoppingListItemCheckedDateTime: now.subtract(
            const Duration(minutes: 59),
          ),
          spotlightLastShownDateTime: null,
        ),
        isFalse,
      );
    });

    test('ちょうど60分で true (>= 1時間)', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      expect(
        shouldShowCreateListSpotlight(
          now: now,
          lastShoppingListCreatedDateTime: null,
          lastShoppingListItemCheckedDateTime: now.subtract(
            const Duration(minutes: 60),
          ),
          spotlightLastShownDateTime: null,
        ),
        isTrue,
      );
    });

    test('61分で true', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      expect(
        shouldShowCreateListSpotlight(
          now: now,
          lastShoppingListCreatedDateTime: null,
          lastShoppingListItemCheckedDateTime: now.subtract(
            const Duration(minutes: 61),
          ),
          spotlightLastShownDateTime: null,
        ),
        isTrue,
      );
    });

    test('そのチェックセッションに対して表示済みなら cond2 は抑止される', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 1, 12, 0),
          // 同日作成で cond1 は無効。
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 8, 0),
          lastShoppingListItemCheckedDateTime: DateTime(2024, 1, 1, 10, 0),
          // チェック(10:00)以降に表示済み。
          spotlightLastShownDateTime: DateTime(2024, 1, 1, 10, 30),
        ),
        isFalse,
      );
    });

    test('表示後に再チェックし1時間経過すると cond2 で再表示される', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 1, 12, 30),
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 8, 0),
          // 表示(10:00)より後に再チェック(11:00)。
          lastShoppingListItemCheckedDateTime: DateTime(2024, 1, 1, 11, 0),
          spotlightLastShownDateTime: DateTime(2024, 1, 1, 10, 0),
        ),
        isTrue,
      );
    });
  });

  group('null 入力', () {
    test('すべて null なら false', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 1, 12, 0),
          lastShoppingListCreatedDateTime: null,
          lastShoppingListItemCheckedDateTime: null,
          spotlightLastShownDateTime: null,
        ),
        isFalse,
      );
    });

    test('lastChecked のみ null なら cond2 は成立しない', () {
      expect(
        shouldShowCreateListSpotlight(
          now: DateTime(2024, 1, 1, 12, 0),
          lastShoppingListCreatedDateTime: DateTime(2024, 1, 1, 8, 0),
          lastShoppingListItemCheckedDateTime: null,
          spotlightLastShownDateTime: null,
        ),
        isFalse,
      );
    });

    test('lastCreated のみ null なら cond1 は成立しない (cond2 のみで判定)', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      expect(
        shouldShowCreateListSpotlight(
          now: now,
          lastShoppingListCreatedDateTime: null,
          lastShoppingListItemCheckedDateTime: now.subtract(
            const Duration(hours: 2),
          ),
          spotlightLastShownDateTime: null,
        ),
        isTrue,
      );
    });
  });
}
