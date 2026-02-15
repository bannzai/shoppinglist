import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_shopping_list_item_category_keyword.g.dart';
part 'group_shopping_list_item_category_keyword.freezed.dart';

enum GroupShoppingListItemCategoryKeywordMatchingType {
  @JsonValue('exact')
  exact,
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
