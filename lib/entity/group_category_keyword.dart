import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_category_keyword.g.dart';
part 'group_category_keyword.freezed.dart';

enum GroupCategoryKeywordMatchingType {
  /// 完全一致: キーワードとアイテムのmessageが完全に一致する場合にマッチ
  @JsonValue('exact')
  exact,

  /// 部分一致: アイテムのmessageにキーワードが含まれる場合にマッチ
  @JsonValue('partial')
  partial,
}

@freezed
abstract class GroupCategoryKeyword with _$GroupCategoryKeyword {
  @JsonSerializable(explicitToJson: true)
  const factory GroupCategoryKeyword({
    required String keyword,
    required GroupCategoryKeywordMatchingType matchingType,
  }) = _GroupCategoryKeyword;

  factory GroupCategoryKeyword.fromJson(Map<String, dynamic> json) =>
      _$GroupCategoryKeywordFromJson(json);
}
