import AppIntents
import Flutter
import Foundation
import home_widget

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

    func perform() async throws -> some IntentResult {
        let url = URL(string: "shoppinglist://toggle-item?groupID=\(groupID)&shoppingListID=\(shoppingListID)&itemID=\(itemID)&currentStatus=\(currentStatus)")
        await HomeWidgetBackgroundWorker.run(
            url: url,
            appGroup: "group.com.bannzai.shoppinglist"
        )
        return .result()
    }
}
