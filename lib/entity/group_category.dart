import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_category.g.dart';
part 'group_category.freezed.dart';

abstract class GroupCategoryFirestoreKeys {
  static const order = 'order';
}

/// [GroupCategoryAxis] に属する個別のカテゴリを表すエンティティ。
///
/// [GroupCategoryKeyword] を持ち、[GroupShoppingListItem] の自動分類に使用される。
/// Firestore 上では `/groups/{groupID}/userCategoryAxes/{axisID}/categories/`
/// サブコレクションに保存される。
///
/// ## ユースケース
/// - ユーザーが「野菜」「肉」などのカテゴリを作成する
/// - カテゴリにキーワードを設定し、買い物アイテムを自動分類する
@freezed
abstract class GroupCategory with _$GroupCategory {
  const GroupCategory._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupCategory({
    required String id,
    required String groupID,
    required String userID,
    required String groupCategoryAxisID,
    required String name,
    required int order,
    /// 買い物場所ごとのカテゴリ表示順序。
    /// key = shoppingLocationID、value = その場所での表示順序。
    /// エントリがない場合は [order] にフォールバックする。
    @Default({}) Map<String, int> locationOrders,
    @Default([]) List<GroupCategoryKeyword> keywords,
    String? color,
    String? iconName,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupCategory;

  factory GroupCategory.fromJson(Map<String, dynamic> json) =>
      _$GroupCategoryFromJson(json);

  static GroupCategory fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupCategory.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupCategory category, SetOptions? options) =>
      category.toJson();
}
