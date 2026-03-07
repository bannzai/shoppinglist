import AppIntents
import Foundation
import WidgetKit

@available(iOS 17, *)
struct ToggleItemIntent: AppIntent {
    static var title: LocalizedStringResource = "アイテムのチェック切り替え"

    @Parameter(title: "Group ID")
    var groupID: String

    @Parameter(title: "Shopping List ID")
    var shoppingListID: String

    @Parameter(title: "Item ID")
    var itemID: String

    @Parameter(title: "Current Status")
    var currentStatus: String

    init() {
        self.groupID = ""
        self.shoppingListID = ""
        self.itemID = ""
        self.currentStatus = ""
    }

    init(groupID: String, shoppingListID: String, itemID: String, currentStatus: String) {
        self.groupID = groupID
        self.shoppingListID = shoppingListID
        self.itemID = itemID
        self.currentStatus = currentStatus
    }

    private let appGroupId = "group.com.bannzai.shoppinglist"

    func perform() async throws -> some IntentResult {
        let success = await FirestoreService.shared.toggleItemStatus(
            groupID: groupID,
            shoppingListID: shoppingListID,
            itemID: itemID,
            currentStatus: currentStatus
        )

        if !success {
            // Firestore 書き込み失敗時は UserDefaults のみ更新（オフラインフォールバック）
            updateUserDefaults()
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    private func updateUserDefaults() {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let key = "widget_items_\(groupID)_\(shoppingListID)"

        guard let jsonString = userDefaults?.string(forKey: key),
              let data = jsonString.data(using: .utf8),
              var items = try? JSONDecoder().decode([ShoppingListItemData].self, from: data) else {
            return
        }

        if let index = items.firstIndex(where: { $0.id == itemID }) {
            let newStatus = currentStatus == "checked" ? "unchecked" : "checked"
            let item = items[index]
            items[index] = ShoppingListItemData(
                id: item.id,
                groupID: item.groupID,
                shoppingListID: item.shoppingListID,
                message: item.message,
                status: newStatus,
                order: item.order,
                color: item.color
            )
        }

        if let encoded = try? JSONEncoder().encode(items),
           let jsonStr = String(data: encoded, encoding: .utf8) {
            userDefaults?.set(jsonStr, forKey: key)
        }

        // 切り替え情報をアプリに通知するためにpendingトグル情報を保存
        let pendingKey = "widget_pending_toggle"
        let pendingData: [String: String] = [
            "groupID": groupID,
            "shoppingListID": shoppingListID,
            "itemID": itemID,
            "currentStatus": currentStatus
        ]
        if let encoded = try? JSONEncoder().encode(pendingData),
           let jsonStr = String(data: encoded, encoding: .utf8) {
            userDefaults?.set(jsonStr, forKey: pendingKey)
        }
    }
}
