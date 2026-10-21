import Foundation

/// Firestore のパスの 1 セグメントとして使える ID かを返す。
/// 空・`/` を含む・`.`・`..` は別のパスを指すか SDK が例外を投げるため拒否する。
func isValidFirestorePathSegment(id: String) -> Bool {
    !id.isEmpty && !id.contains("/") && id != "." && id != ".."
}

/// ウィジェットが表示する買い物リストのアイテムのコレクションパスを返す。ID が不正な時は nil。
func widgetItemsCollectionPath(groupID: String, shoppingListID: String) -> String? {
    guard isValidFirestorePathSegment(id: groupID),
          isValidFirestorePathSegment(id: shoppingListID) else { return nil }
    return "groups/\(groupID)/shoppingLists/\(shoppingListID)/items"
}

/// ウィジェットがトグルするアイテムの文書パスを返す。ID が不正な時は nil。
/// groupID・shoppingListID はアイテム文書のフィールドではなく、アイテムを取得したリストの ID を渡す。
func widgetItemDocumentPath(groupID: String, shoppingListID: String, itemID: String) -> String? {
    guard let collectionPath = widgetItemsCollectionPath(groupID: groupID, shoppingListID: shoppingListID),
          isValidFirestorePathSegment(id: itemID) else { return nil }
    return "\(collectionPath)/\(itemID)"
}
