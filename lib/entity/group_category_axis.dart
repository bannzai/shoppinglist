import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_category_axis.g.dart';
part 'group_category_axis.freezed.dart';

abstract class GroupCategoryAxisFirestoreKeys {
  static const userID = 'userID';
  static const order = 'order';
  static const categoryRevision = 'categoryRevision';
}

/// [Group] 内でユーザーが定義するカテゴリの軸を表すエンティティ。
///
/// 1つの軸の下に複数の [GroupCategory] が属する。
/// 各 [AppUser] が独自の軸を作成でき、Firestore 上では
/// `/groups/{groupID}/userCategoryAxes/` コレクションに保存される。
///
/// ## ユースケース
/// - ユーザーが「食品カテゴリ」「売り場」などの分類軸を作成する
/// - 軸の中にカテゴリ（野菜、肉、飲料など）を追加する
@freezed
abstract class GroupCategoryAxis with _$GroupCategoryAxis {
  const GroupCategoryAxis._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupCategoryAxis({
    required String id,
    required String groupID,
    required String userID,
    required String name,
    required int order,
    @Default(0) int categoryRevision,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupCategoryAxis;

  factory GroupCategoryAxis.fromJson(Map<String, dynamic> json) =>
      _$GroupCategoryAxisFromJson(json);

  static GroupCategoryAxis fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) => GroupCategoryAxis.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
    GroupCategoryAxis categoryAxis,
    SetOptions? options,
  ) => categoryAxis.toJson();
}
