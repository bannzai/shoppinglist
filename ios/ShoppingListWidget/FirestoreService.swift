import FirebaseAuth
import FirebaseFirestore
import Foundation

private func currentUserID() -> String? {
    Auth.auth().currentUser?.uid
}

// Widget Extension で Firestore 操作後にファイルロックを解放する（0xdead10cc 回避）
private func teardownFirestore() async {
    try? await Firestore.firestore().terminate()
}

/// ユーザーが所属するグループの買い物リスト一覧を取得
@available(iOS 17.0, *)
func fetchFirestoreShoppingLists() async -> [ShoppingListEntity] {
    guard let userID = currentUserID() else { return [] }
    defer { Task { await teardownFirestore() } }
    do {
        let db = Firestore.firestore()
        let groupsSnapshot = try await db
            .collection("groups")
            .whereField("memberUserIDs", arrayContains: userID)
            .getDocuments()

        var entities: [ShoppingListEntity] = []
        for groupDoc in groupsSnapshot.documents {
            let groupData = groupDoc.data()
            let groupID = groupDoc.documentID
            let groupName = groupData["name"] as? String ?? ""

            let listsSnapshot = try await db
                .collection("groups/\(groupID)/shoppingLists")
                .getDocuments()

            for listDoc in listsSnapshot.documents {
                let listData = listDoc.data()
                entities.append(ShoppingListEntity(
                    id: listDoc.documentID,
                    name: listData["name"] as? String ?? "",
                    groupID: groupID,
                    groupName: groupName
                ))
            }
        }
        return entities
    } catch {
        return []
    }
}

/// 指定した買い物リストのアイテムを取得
func fetchFirestoreItems(groupID: String, shoppingListID: String) async -> [ShoppingListItemData] {
    guard currentUserID() != nil,
          let collectionPath = widgetItemsCollectionPath(groupID: groupID, shoppingListID: shoppingListID) else { return [] }
    defer { Task { await teardownFirestore() } }
    do {
        let snapshot = try await Firestore.firestore()
            .collection(collectionPath)
            .order(by: "order", descending: false)
            .limit(to: 20)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> ShoppingListItemData? in
            let data = doc.data()
            guard let message = data["message"] as? String,
                  let status = data["status"] as? String,
                  let order = data["order"] as? Int else { return nil }
            return ShoppingListItemData(
                id: doc.documentID,
                message: message,
                status: status,
                order: order,
                color: data["color"] as? String
            )
        }
    } catch {
        return []
    }
}

/// アイテムのステータスを切り替え。groupID・shoppingListID はアイテムを取得したリストの ID を渡す。
/// ID が不正な時と文書が存在しない時は書き込まず false を返す。
func toggleFirestoreItemStatus(groupID: String, shoppingListID: String, itemID: String, currentStatus: String) async -> Bool {
    guard currentUserID() != nil,
          let documentPath = widgetItemDocumentPath(groupID: groupID, shoppingListID: shoppingListID, itemID: itemID) else { return false }
    defer { Task { await teardownFirestore() } }
    let newStatus = currentStatus == "checked" ? "unchecked" : "checked"
    do {
        // updateData は文書が無ければ失敗するため、存在しないアイテム文書を作らない
        try await Firestore.firestore()
            .document(documentPath)
            .updateData([
                "status": newStatus,
                "updatedDateTime": FieldValue.serverTimestamp(),
                "serverUpdatedDateTime": FieldValue.serverTimestamp()
            ])
        return true
    } catch {
        return false
    }
}
