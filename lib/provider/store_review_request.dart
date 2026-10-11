import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

part 'store_review_request.g.dart';

/// ストア評価依頼を出す「買った」チェックの累計回数。
///
/// 買い物を 1 度以上完了した利用者だけに出すための値で、公開 52 日で評価 0 件という
/// 実測から無人ループが決めた (Issue #651、`documents/DIRECTION.md` の「決めたこと」
/// 2026-10-11 の行)。後から変える時はこの定数だけを変える。
const int purchasedItemCheckCountForStoreReviewRequest = 10;

/// 買い物リストのアイテムを「買った」にチェックした累計回数を数え、
/// [purchasedItemCheckCountForStoreReviewRequest] 回に達した時に 1 回だけ
/// OS 標準のストア評価依頼を出す。
///
/// 累計回数 ([IntKey.purchasedItemCheckCount]) と依頼済みフラグ
/// ([BoolKey.hasRequestedStoreReview]) は [sharedPreferences] に持つ。
/// 依頼済みなら数えもせず何もしない。
///
/// [requestReview] は本番では `InAppReview.instance.requestReview` で、
/// 単体テストで呼び出し回数を数えるために差し替えられるようにしている
/// (`InAppReview` はコンストラクタが private で継承できないため関数で注入する)。
class RequestStoreReviewOnPurchasedItemCheck {
  final SharedPreferences sharedPreferences;
  final Future<void> Function() requestReview;

  RequestStoreReviewOnPurchasedItemCheck({
    required this.sharedPreferences,
    required this.requestReview,
  });

  /// 「買った」チェック 1 回分を加算し、条件を満たせば評価依頼を出す。
  ///
  /// 依頼済みフラグは [requestReview] を待つ前に立てる。失敗しても、累計が同時に
  /// しきい値へ達しても、依頼が 2 回出ないようにするため。
  /// [requestReview] の失敗 (Android で Play ストアが無い・iOS の unavailable 等。
  /// どちらもプラグインが PlatformException を投げる) は握りつぶして debugPrint に出す。
  /// 評価依頼はチェック処理の付随であり、呼び出し元のチェック自体を失敗させないため。
  Future<void> call() async {
    if (sharedPreferences.getBool(BoolKey.hasRequestedStoreReview) ?? false) {
      return;
    }
    final purchasedItemCheckCount =
        (sharedPreferences.getInt(IntKey.purchasedItemCheckCount) ?? 0) + 1;
    await sharedPreferences.setInt(
      IntKey.purchasedItemCheckCount,
      purchasedItemCheckCount,
    );
    if (purchasedItemCheckCount <
        purchasedItemCheckCountForStoreReviewRequest) {
      return;
    }
    await sharedPreferences.setBool(BoolKey.hasRequestedStoreReview, true);
    try {
      await requestReview();
    } catch (e) {
      debugPrint(
        '[RequestStoreReviewOnPurchasedItemCheck] requestReview 失敗: $e',
      );
    }
  }
}

/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
RequestStoreReviewOnPurchasedItemCheck requestStoreReviewOnPurchasedItemCheck(
  Ref ref,
) {
  return RequestStoreReviewOnPurchasedItemCheck(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
    requestReview: InAppReview.instance.requestReview,
  );
}
