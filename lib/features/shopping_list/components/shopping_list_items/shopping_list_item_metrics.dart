import 'package:shoppinglist/entity/group_shopping_list_item.dart';

/// 入力用の空行(message が空)を除いた、表示上の進捗集計(チェック済み件数と総数)を返す。
///
/// 連続入力では `message == ''` の行を次の入力先として保持するため、
/// その行を進捗やカテゴリ件数に含めると `0/2` のように実アイテム数とズレる。
/// そのため空メッセージ行は集計から除外する。
///
/// 進捗ピル・カテゴリ見出し件数・通知トリガーの3箇所で同じ集計ルールを共有するため
/// 関数として切り出している(クラス/中間表現を作らず record で返す)。
({int checkedCount, int totalCount}) shoppingListItemMetrics(
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

  return (checkedCount: checkedCount, totalCount: totalCount);
}
