import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_category_keyword.g.dart';
part 'group_category_keyword.freezed.dart';

/// [GroupCategoryKeyword] のマッチング方式。
enum GroupCategoryKeywordMatchingType {
  /// 完全一致: キーワードとアイテムのmessageが完全に一致する場合にマッチ
  @JsonValue('exact')
  exact,

  /// 部分一致: アイテムのmessageにキーワードが含まれる場合にマッチ
  @JsonValue('partial')
  partial,

  /// 正規表現マッチ: keyword を `RegExp` として評価し、message に対して `hasMatch` する。
  /// `FormatException` (不正な regex 文字列) のときはマッチさせない。
  @JsonValue('regex')
  regex,
}

/// [GroupCategory] に設定される自動分類用キーワードを表すエンティティ。
///
/// [GroupShoppingListItem] の message とキーワードを照合し、
/// [GroupCategoryKeywordMatchingType] に応じた方式（完全一致・部分一致）でカテゴリに自動分類する。
/// [GroupCategory] に埋め込みオブジェクトとして保存される。
///
/// ## ユースケース
/// - 「にんじん」を完全一致キーワードとして設定し、アイテムを「野菜」カテゴリに自動分類する
/// - 「肉」を部分一致キーワードとして設定し、「鶏肉」「豚肉」等を一括分類する
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
