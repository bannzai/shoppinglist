import 'package:shoppinglist/entity/group_shopping_list_item.dart';

/// 買い物リストをテキスト形式にフォーマットし、共有シートで送信できる文字列を生成する。
String buildShoppingListExportText({
  required String shoppingListName,
  required List<GroupShoppingListItem> shoppingListItems,
}) {
  String sanitizeLine(String value) =>
      value.replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();

  final buffer = StringBuffer();
  buffer.writeln(sanitizeLine(shoppingListName));
  buffer.writeln('---');
  for (final item in shoppingListItems) {
    final checkMark =
        item.status == GroupShoppingListItemStatus.checked ? '✓' : '・';
    buffer.writeln('$checkMark ${sanitizeLine(item.message)}');
  }
  return buffer.toString().trimRight();
}
