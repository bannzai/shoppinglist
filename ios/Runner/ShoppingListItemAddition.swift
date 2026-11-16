import FirebaseFirestore
import Foundation

/// Siri・ショートカットからのアイテムの追加が、書き込まずに返す理由。
enum ShoppingListItemAdditionError: Error, Equatable, CustomLocalizedStringResourceConvertible {
    /// アプリにログインしているユーザーがいない。
    case notSignedIn
    /// アイテムの名前が空か空白だけ。
    case emptyItemName
    /// 追加先の買い物リストが選べないか、サーバーに存在しない。
    case shoppingListNotFound
    /// アプリの Firebase の設定を読めず、書き込み先に接続できない。
    case firebaseUnavailable

    /// Siri とショートカットアプリが利用者に見せる理由の文言。
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notSignedIn:
            return "ログインしていないため追加できませんでした\nアプリを開いてからもう一度お試しください"
        case .emptyItemName:
            return "アイテムの名前が空のため追加できませんでした"
        case .shoppingListNotFound:
            return "追加先の買い物リストが見つかりませんでした\nアプリを開いて買い物リストを確かめてください"
        case .firebaseUnavailable:
            return "買い物リストに接続できませんでした"
        }
    }
}

/// 追加先の買い物リストの ID を、選べる買い物リストの ID の中から返す。追加先が無ければ nil。
///
/// 指定があればその買い物リスト (選べる中に無ければ nil)。指定が無ければアプリで開いている買い物リスト、
/// それが選べる中に無ければ選べる買い物リストの先頭 (ウィジェットの設定の既定 `ShoppingListEntityQuery.defaultResult` と同じ)。
func destinationShoppingListID(
    specifiedShoppingListID: String?,
    currentShoppingListID: String?,
    availableShoppingListIDs: [String]
) -> String? {
    if let specifiedShoppingListID {
        return availableShoppingListIDs.contains(specifiedShoppingListID) ? specifiedShoppingListID : nil
    }
    if let currentShoppingListID, availableShoppingListIDs.contains(currentShoppingListID) {
        return currentShoppingListID
    }
    return availableShoppingListIDs.first
}

/// 新しく追加するアイテムの Firestore の文書を返す。
///
/// フィールドの正はアプリ (Dart) の `GroupShoppingListItem` で、`AddShoppingListItem` が書く文書と同じキーと値にする。
/// 両者が同じ形であることは、`test/fixtures/new_shopping_list_item_document.json` と照合するテストが確かめる。
func newShoppingListItemDocumentData(
    itemID: String,
    groupID: String,
    shoppingListID: String,
    userID: String,
    message: String,
    order: Int
) -> [String: Any] {
    [
        "id": itemID,
        "groupID": groupID,
        "shoppingListID": shoppingListID,
        "userID": userID,
        "message": message,
        "order": order,
        "status": "unchecked",
        "description": NSNull(),
        "color": NSNull(),
        "imageURL": NSNull(),
        "reminderDateTime": NSNull(),
        "checkedByUserID": NSNull(),
        "lastCheckedDateTime": NSNull(),
        "lastEditedByUserID": NSNull(),
        "lastEditedDateTime": NSNull(),
        "createdDateTime": Timestamp(date: Date()),
        "updatedDateTime": NSNull(),
        "serverCreatedDateTime": FieldValue.serverTimestamp(),
        "serverUpdatedDateTime": FieldValue.serverTimestamp(),
    ]
}

/// 買い物リストの末尾にアイテムを 1 件追加し、書き込んだアイテムの名前 (itemName の前後の空白と改行を落としたもの) を返す。
///
/// userID が nil・itemName が空白だけ・ID が Firestore のパスに使えない・買い物リストがサーバーに無い、のどれかの時は
/// `write` を呼ばずに `ShoppingListItemAdditionError` を投げる。Firestore への読み書きは引数で受け取り、この関数は順序と判定だけを持つ。
/// 冪等ではない: 呼ぶたびに新しいアイテムを 1 件足す (同じ名前のアイテムを 2 回追加する操作を区別しないため)。
///
/// - Parameters:
///   - shoppingListExists: アイテムのコレクションパスを受け取り、その親の買い物リストがサーバーにあるかを返す
///   - lastItemOrder: アイテムのコレクションパスを受け取り、order が最大のアイテムの order を返す。アイテムが無ければ nil
///   - newItemID: アイテムのコレクションパスを受け取り、新しい文書の ID を返す
///   - write: アイテムの文書パスと文書を受け取り、書き込む
@discardableResult
func addShoppingListItem(
    userID: String?,
    itemName: String,
    groupID: String,
    shoppingListID: String,
    shoppingListExists: (String) async throws -> Bool,
    lastItemOrder: (String) async throws -> Int?,
    newItemID: (String) -> String,
    write: (String, [String: Any]) async throws -> Void
) async throws -> String {
    guard let userID else { throw ShoppingListItemAdditionError.notSignedIn }
    let message = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !message.isEmpty else { throw ShoppingListItemAdditionError.emptyItemName }
    guard let itemsCollectionPath = widgetItemsCollectionPath(groupID: groupID, shoppingListID: shoppingListID),
          try await shoppingListExists(itemsCollectionPath) else {
        throw ShoppingListItemAdditionError.shoppingListNotFound
    }
    let itemID = newItemID(itemsCollectionPath)
    try await write(
        "\(itemsCollectionPath)/\(itemID)",
        newShoppingListItemDocumentData(
            itemID: itemID,
            groupID: groupID,
            shoppingListID: shoppingListID,
            userID: userID,
            message: message,
            // アプリの `GroupShoppingListItems.nextOrder` と同じ: 末尾の order + 1、アイテムが無ければ 0
            order: (try await lastItemOrder(itemsCollectionPath) ?? -1) + 1
        )
    )
    return message
}
