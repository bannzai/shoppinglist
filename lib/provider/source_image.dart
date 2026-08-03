import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group_shopping_list_source_image.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'source_image.g.dart';

/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
@Riverpod(dependencies: [groupDatabase])
Stream<List<GroupShoppingListSourceImage>> sourceImages(
  Ref ref, {
  required String groupID,
  required String shoppingListID,
}) {
  return ref
      .watch(groupDatabaseProvider(groupID: groupID))
      .sourceImagesReference(shoppingListID: shoppingListID)
      .orderBy(
        GroupShoppingListSourceImageFirestoreKeys.createdDateTime,
        descending: true,
      )
      .snapshots()
      .map((event) => event.docs.map((doc) => doc.data()).toList());
}
