import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_shopping_list_source_image.freezed.dart';
part 'group_shopping_list_source_image.g.dart';

/// 1つの買い物リストに保存できる元画像の上限枚数。
/// サーバー側（generateShoppingListItemsFromImage の maxSourceImagesPerShoppingList）と
/// 揃えた値（Issue #530 の仕様）。超過分はサーバー側で古い順に削除される。
const maxShoppingListSourceImageCount = 5;

/// Firestore 上のフィールド名定数。クエリの orderBy 等で使用する。
abstract class GroupShoppingListSourceImageFirestoreKeys {
  static const createdDateTime = 'createdDateTime';
}

/// 「写真から追加」（AI 画像認識）で使った元画像を表すエンティティ。
///
/// 画像本体は Firebase Storage に保存し、本エンティティはそのメタデータを持つ。
/// 作成・削除は generateShoppingListItemsFromImage Function（Admin SDK）経由のみで、
/// クライアントからは読み取り専用。1つの買い物リストに最大
/// [maxShoppingListSourceImageCount] 枚保存され、超過分はサーバー側で
/// 古い順に削除される（Issue #530）。
/// 親ドキュメントの ID（[groupID] / [shoppingListID]）をフィールドとして保持する。
@freezed
abstract class GroupShoppingListSourceImage
    with _$GroupShoppingListSourceImage {
  @JsonSerializable(explicitToJson: true)
  const factory GroupShoppingListSourceImage({
    required String id,
    required String groupID,
    required String shoppingListID,
    required String userID,

    /// Firebase Storage 上の元画像のパス。
    /// 例: groups/{groupID}/shoppingLists/{shoppingListID}/sourceImages/{sourceImageID}.jpeg
    /// download URL は Firestore に保存せず、表示時に storagePath から getDownloadURL で
    /// 都度取得する（storage.rules で認証済みユーザーに read 許可）。
    required String? storagePath,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupShoppingListSourceImage;

  factory GroupShoppingListSourceImage.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListSourceImageFromJson(json);

  static GroupShoppingListSourceImage fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) => GroupShoppingListSourceImage.fromJson(
    Map<String, dynamic>.from(snapshot.data() ?? {})..['id'] = snapshot.id,
  );

  static Map<String, dynamic> toFirestore(
    GroupShoppingListSourceImage sourceImage,
    SetOptions? options,
  ) => sourceImage.toJson();
}
