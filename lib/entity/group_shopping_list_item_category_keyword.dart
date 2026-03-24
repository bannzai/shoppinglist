import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_shopping_list_item_category_keyword.g.dart';
part 'group_shopping_list_item_category_keyword.freezed.dart';

enum GroupShoppingListItemCategoryKeywordMatchingType {
  /// 完全一致: キーワードとアイテムのmessageが完全に一致する場合にマッチ
  @JsonValue('exact')
  exact,

  /// 部分一致: アイテムのmessageにキーワードが含まれる場合にマッチ
  @JsonValue('partial')
  partial,
}

@freezed
abstract class GroupShoppingListItemCategoryKeyword
    with _$GroupShoppingListItemCategoryKeyword {
  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListItemCategoryKeyword({
    required String keyword,
    required GroupShoppingListItemCategoryKeywordMatchingType matchingType,
  }) = _GroupShoppingListItemCategoryKeyword;

  factory GroupShoppingListItemCategoryKeyword.fromJson(
          Map<String, dynamic> json) =>
      _$GroupShoppingListItemCategoryKeywordFromJson(json);
}
