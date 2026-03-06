import AppIntents
import Foundation

struct ShoppingListConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "買い物リスト設定"
    static var description: IntentDescription = "表示する買い物リストを選択します"

    @Parameter(title: "買い物リスト")
    var shoppingList: ShoppingListEntity?

    @Parameter(title: "チェック済みを表示", default: true)
    var showCheckedItems: Bool

    init() {}

    init(shoppingList: ShoppingListEntity?, showCheckedItems: Bool) {
        self.shoppingList = shoppingList
        self.showCheckedItems = showCheckedItems
    }
}

struct ShoppingListEntity: AppEntity, Codable {
    let id: String
    let name: String
    let groupID: String
    let groupName: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "買い物リスト"
    static var defaultQuery = ShoppingListEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ShoppingListEntityQuery: EntityQuery {
    private let appGroupId = "group.com.bannzai.shoppinglist"

    func entities(for identifiers: [ShoppingListEntity.ID]) async throws -> [ShoppingListEntity] {
        let allEntities = loadEntities()
        return allEntities.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ShoppingListEntity] {
        loadEntities()
    }

    func defaultResult() async -> ShoppingListEntity? {
        loadEntities().first
    }

    private func loadEntities() -> [ShoppingListEntity] {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        guard let jsonString = userDefaults?.string(forKey: "widget_shopping_lists"),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        do {
            return try JSONDecoder().decode([ShoppingListEntity].self, from: data)
        } catch {
            return []
        }
    }
}
