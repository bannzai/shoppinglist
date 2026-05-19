import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group.g.dart';
part 'group.freezed.dart';

/// 無料ユーザーがソログループに加えて作成できるグループ数の上限。
/// NOTE: サーバー側(firebase/functions/src/functions/createGroup/function.ts の FREE_ADDITIONAL_GROUP_CREATION_LIMIT)と同じ値を維持すること。
const int freeAdditionalGroupCreationLimit = 1;

/// 買い物リストを共有するグループを表すエンティティ。
///
/// 複数の [AppUser] が所属し、[GroupShoppingList] や [GroupShoppingLocation]、
/// [GroupCategoryAxis] などのリソースをグループ単位で管理する。
///
/// ## ユースケース
/// - ユーザーがグループを作成し、他ユーザーを [GroupInvitation] で招待する
/// - グループ内で買い物リストを作成・共有する
@freezed
abstract class Group with _$Group {
  const Group._();

  @JsonSerializable(explicitToJson: true)
  const factory Group({
    required String id,

    /// グループに所属するユーザーのAppUser.idの配列
    required List<String> memberUserIDs,

    /// グループ名
    required String? name,

    /// グループを作成したユーザーのAppUser.id
    /// NOTE: 既存のグループドキュメントにはこのフィールドが存在しない場合があるためnullable
    String? ownerUserID,

    /// グループに紐づくアイコンの識別子。
    /// `design_handoff_shoppinglist/preview/screens-groups.jsx` の GroupCreatePage で
    /// 選択する 6 種 (`home` / `cart` / `fork` / `cookie` / `pets` / `bag`) のいずれか。
    /// 既存ドキュメントにはこのフィールドが存在しないため default で `home` を返す。
    @Default('home') String iconName,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  static Group fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      Group.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(Group group, SetOptions? options) =>
      group.toJson();
}
