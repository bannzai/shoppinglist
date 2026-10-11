import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/provider/store_review_request.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// [initialValues] で初期化した SharedPreferences と、requestReview の呼び出し回数を
/// 数える関数を注入した [RequestStoreReviewOnPurchasedItemCheck] を作る。
Future<({RequestStoreReviewOnPurchasedItemCheck request, List<int> calls})>
_subject(Map<String, Object> initialValues) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues(initialValues);
  final sharedPreferences = await SharedPreferences.getInstance();
  // 呼び出しごとに 1 要素足す。length が呼び出し回数。
  final calls = <int>[];
  return (
    request: RequestStoreReviewOnPurchasedItemCheck(
      sharedPreferences: sharedPreferences,
      requestReview: () async => calls.add(calls.length),
    ),
    calls: calls,
  );
}

void main() {
  group('RequestStoreReviewOnPurchasedItemCheck (Issue #651)', () {
    test('しきい値の 1 回手前 (9 回目) では requestReview を呼ばず、累計だけ進める', () async {
      final (:request, :calls) = await _subject({
        IntKey.purchasedItemCheckCount:
            purchasedItemCheckCountForStoreReviewRequest - 2,
      });

      await request.call();

      expect(calls, isEmpty);
      expect(
        request.sharedPreferences.getInt(IntKey.purchasedItemCheckCount),
        purchasedItemCheckCountForStoreReviewRequest - 1,
      );
      expect(
        request.sharedPreferences.getBool(BoolKey.hasRequestedStoreReview),
        isNull,
      );
    });

    test('しきい値 (10 回目) に達した時に requestReview を 1 回呼び、依頼済みフラグを立てる', () async {
      final (:request, :calls) = await _subject({
        IntKey.purchasedItemCheckCount:
            purchasedItemCheckCountForStoreReviewRequest - 1,
      });

      await request.call();

      expect(calls, hasLength(1));
      expect(
        request.sharedPreferences.getBool(BoolKey.hasRequestedStoreReview),
        isTrue,
      );
    });

    test('依頼済みなら 11 回目以降も requestReview を呼ばず、累計も進めない', () async {
      final (:request, :calls) = await _subject({
        IntKey.purchasedItemCheckCount:
            purchasedItemCheckCountForStoreReviewRequest,
        BoolKey.hasRequestedStoreReview: true,
      });

      await request.call();
      await request.call();

      expect(calls, isEmpty);
      expect(
        request.sharedPreferences.getInt(IntKey.purchasedItemCheckCount),
        purchasedItemCheckCountForStoreReviewRequest,
      );
    });

    test('0 からしきい値まで連続で呼んでも requestReview は合計 1 回だけ', () async {
      final (:request, :calls) = await _subject({});

      for (
        var i = 0;
        i < purchasedItemCheckCountForStoreReviewRequest + 5;
        i++
      ) {
        await request.call();
      }

      expect(calls, hasLength(1));
    });

    test('requestReview が失敗しても例外を外へ出さず、依頼済みフラグは立つ', () async {
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({
        IntKey.purchasedItemCheckCount:
            purchasedItemCheckCountForStoreReviewRequest - 1,
      });
      final sharedPreferences = await SharedPreferences.getInstance();
      final request = RequestStoreReviewOnPurchasedItemCheck(
        sharedPreferences: sharedPreferences,
        requestReview: () async => throw Exception('unavailable'),
      );

      await expectLater(request.call(), completes);

      expect(
        sharedPreferences.getBool(BoolKey.hasRequestedStoreReview),
        isTrue,
      );
    });
  });
}
