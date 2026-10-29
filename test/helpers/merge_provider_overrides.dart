import 'package:hooks_riverpod/misc.dart';

/// [base] の override に [extra] の override を後勝ちで重ねた一覧を返す。
///
/// Riverpod 3 は同じ provider を 1 つの ProviderScope で 2 回 override すると
/// AssertionError を投げるため、[extra] と同じ provider を指す override を [base] から除く。
/// テストでプレビュー用の override 一式の一部を記録用のフェイクに差し替える時に使う。
List<Override> mergeProviderOverrides({
  required List<Override> base,
  required List<Override> extra,
}) {
  // ignore: invalid_use_of_visible_for_testing_member
  final extraOrigins = {for (final override in extra) override.origin};
  return [
    // ignore: invalid_use_of_visible_for_testing_member
    ...base.where((override) => !extraOrigins.contains(override.origin)),
    ...extra,
  ];
}
