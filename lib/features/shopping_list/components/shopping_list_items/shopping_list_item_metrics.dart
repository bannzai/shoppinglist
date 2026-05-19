import 'package:shoppinglist/entity/group_shopping_list_item.dart';

/// 入力用の空行を除いた、表示上の進捗集計。
///
/// 連続入力では `message == ''` の行を次の入力先として保持するため、
/// その行を進捗やカテゴリ件数に含めると `0/2` のように実アイテム数とズレる。
class ShoppingListItemMetrics {
  final int checkedCount;
  final int totalCount;

  const ShoppingListItemMetrics({
    required this.checkedCount,
    required this.totalCount,
  });

  factory ShoppingListItemMetrics.fromItems(
    Iterable<GroupShoppingListItem> items,
  ) {
    var checkedCount = 0;
    var totalCount = 0;

    for (final item in items) {
      if (item.message.trim().isEmpty) {
        continue;
      }
      totalCount++;
      if (item.status == GroupShoppingListItemStatus.checked) {
        checkedCount++;
      }
    }

    return ShoppingListItemMetrics(
      checkedCount: checkedCount,
      totalCount: totalCount,
    );
  }
}
