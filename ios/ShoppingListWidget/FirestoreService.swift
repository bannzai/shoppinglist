import FirebaseAuth
import FirebaseFirestore
import Foundation

@available(iOS 17.0, *)
actor FirestoreService {
    static let shared = FirestoreService()

    private func currentUserID() -> String? {
        Auth.auth().currentUser?.uid
    }

    private func teardown() async {
        try? await Firestore.firestore().terminate()
    }

    /// ユーザーが所属するグループの買い物リスト一覧を取得
    func fetchShoppingLists() async -> [ShoppingListEntity] {
        guard let userID = currentUserID() else { return [] }
        do {
            let groupsSnapshot = try await Firestore.firestore()
                .collection("groups")
                .whereField("memberUserIDs", arrayContains: userID)
                .getDocuments()

            var entities: [ShoppingListEntity] = []
            for groupDoc in groupsSnapshot.documents {
                let groupData = groupDoc.data()
                let groupID = groupDoc.documentID
                let groupName = groupData["name"] as? String ?? ""

                let listsSnapshot = try await Firestore.firestore()
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
            await teardown()
            return entities
        } catch {
            await teardown()
            return []
        }
    }

    /// 指定した買い物リストのアイテムを取得
    func fetchItems(groupID: String, shoppingListID: String) async -> [ShoppingListItemData] {
        guard currentUserID() != nil else { return [] }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("groups/\(groupID)/shoppingLists/\(shoppingListID)/items")
                .order(by: "order", descending: false)
                .getDocuments()

            let items = snapshot.documents.compactMap { doc -> ShoppingListItemData? in
                let data = doc.data()
                guard let message = data["message"] as? String,
                      let status = data["status"] as? String,
                      let order = data["order"] as? Int else { return nil }
                return ShoppingListItemData(
                    id: doc.documentID,
                    groupID: data["groupID"] as? String ?? groupID,
                    shoppingListID: data["shoppingListID"] as? String ?? shoppingListID,
                    message: message,
                    status: status,
                    order: order,
                    color: data["color"] as? String
                )
            }
            await teardown()
            return items
        } catch {
            await teardown()
            return []
        }
    }

    /// アイテムのステータスを切り替え
    func toggleItemStatus(groupID: String, shoppingListID: String, itemID: String, currentStatus: String) async -> Bool {
        guard currentUserID() != nil else { return false }
        let newStatus = currentStatus == "checked" ? "unchecked" : "checked"
        do {
            try await Firestore.firestore()
                .collection("groups/\(groupID)/shoppingLists/\(shoppingListID)/items")
                .document(itemID)
                .setData(["status": newStatus], merge: true)
            await teardown()
            return true
        } catch {
            await teardown()
            return false
        }
    }
}
