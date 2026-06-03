import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';

part 'current_shopping_list_id.g.dart';

/// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
/// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。
@riverpod
class CurrentShoppingListID extends _$CurrentShoppingListID {
  @override
  String? build() => null;

  /// 表示中の買い物リストを切り替える。null で先頭フォールバックに戻す。
  void update(String? shoppingListID) => state = shoppingListID;
}

/// 選択IDとリスト一覧から、実際に表示すべき買い物リストIDを解決する。
/// 選択が null / 一覧に存在しない場合は先頭リストにフォールバックする。一覧が空なら null。
///
/// ShoppingListPage と HomeWidgetSync の双方で同じ解決ルールを共有するための純粋関数
/// (provider 化しないことで scope 依存を避ける)。
String? resolveShoppingListID({
  required String? selected,
  required List<GroupShoppingList> shoppingLists,
}) {
  if (shoppingLists.isEmpty) {
    return null;
  }
  if (selected != null && shoppingLists.any((e) => e.id == selected)) {
    return selected;
  }
  return shoppingLists.first.id;
}
