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

// 商品名に当てるパターンとして十分な長さで、巨大なパターンによる照合の負荷を抑えるため。
const groupCategoryKeywordRegexMaxLength = 100;

/// [GroupCategoryKeywordMatchingType.regex] のキーワードとして保存してよいかを返す。
///
/// 照合は build 内で同期的に全アイテムへ行うため、壊滅的なバックトラック (ReDoS) を
/// 起こしやすい形を保存前に拒否する。拒否するのは [groupCategoryKeywordRegexMaxLength]
/// を超える長さと、量指定子を含むグループに繰り返しの量指定子 (`*` `+` `{n,m}`) が付く
/// 入れ子 (`(a+)+` 等)。Dart の `RegExp` はバックトラック型のため、この検証で全ての
/// ReDoS を防げるわけではない (`(a|aa)+` のような選択肢の重なりは通す)。
bool isSafeGroupCategoryKeywordRegex({required String keyword}) {
  if (keyword.length > groupCategoryKeywordRegexMaxLength) {
    return false;
  }
  // 開いているグループごとに、その中に量指定子があるかを積む。
  final groupContainsQuantifierStack = <bool>[];
  var followsGroupContainingQuantifier = false;
  var isInCharacterClass = false;
  var index = 0;
  while (index < keyword.length) {
    final character = keyword[index];
    final isRepeatQuantifier =
        character == '*' ||
        character == '+' ||
        // 数字が続かない `{` は量指定子ではなく文字として扱われる。
        (character == '{' &&
            index + 1 < keyword.length &&
            RegExp(r'\d').hasMatch(keyword[index + 1]));
    if (!isInCharacterClass &&
        followsGroupContainingQuantifier &&
        isRepeatQuantifier) {
      return false;
    }
    followsGroupContainingQuantifier = false;

    if (character == r'\') {
      index += 2;
      continue;
    }
    if (isInCharacterClass) {
      isInCharacterClass = character != ']';
      index++;
      continue;
    }
    switch (character) {
      case '[':
        isInCharacterClass = true;
      case '(':
        groupContainsQuantifierStack.add(false);
        // `(?:` `(?=` `(?<name>` の `?` はグループの種類の指定で、量指定子ではない。
        if (index + 1 < keyword.length && keyword[index + 1] == '?') {
          index++;
        }
      case ')':
        if (groupContainsQuantifierStack.isNotEmpty) {
          followsGroupContainingQuantifier =
              groupContainsQuantifierStack.removeLast();
          if (followsGroupContainingQuantifier &&
              groupContainsQuantifierStack.isNotEmpty) {
            groupContainsQuantifierStack.last = true;
          }
        }
      case '?':
        if (groupContainsQuantifierStack.isNotEmpty) {
          groupContainsQuantifierStack.last = true;
        }
      default:
        if (isRepeatQuantifier && groupContainsQuantifierStack.isNotEmpty) {
          groupContainsQuantifierStack.last = true;
        }
    }
    index++;
  }
  return true;
}
