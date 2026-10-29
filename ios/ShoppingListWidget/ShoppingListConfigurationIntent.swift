import AppIntents
import Foundation

// dev(Debug)ビルドは本番と App Group / UserDefaults を分離する(Issue #410 / ADR 0030)。
// Dart の app_identity.appGroupId / iOS entitlements の $(APP_GROUP_ID) と一致させる。
// Widget と Runner の Debug build config には SWIFT_ACTIVE_COMPILATION_CONDITIONS に DEBUG が入っている。
// ウィジェットの編集画面の選択肢 (ShoppingListEntityQuery) は Runner のプロセスで実行されるため、Runner にも DEBUG が要る。
// 無いと dev のビルドの Runner が本番の App Group を読み、選択肢が 0 件になって開かない。
#if DEBUG
let widgetAppGroupId = "group.com.bannzai.shoppinglist.dev"
#else
let widgetAppGroupId = "group.com.bannzai.shoppinglist"
#endif

@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
struct ShoppingListEntityQuery: EntityQuery {
    private let appGroupId = widgetAppGroupId

    func entities(for identifiers: [ShoppingListEntity.ID]) async throws -> [ShoppingListEntity] {
        return await availableEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ShoppingListEntity] {
        await availableEntities()
    }

    func defaultResult() async -> ShoppingListEntity? {
        await availableEntities().first
    }

    /// プレミアム状態に応じて返却するエンティティをフィルタリングする。
    /// 無料ユーザーは現在選択中のリスト1件のみ返却する。
    private func availableEntities() async -> [ShoppingListEntity] {
        let allEntities = await loadAllEntities()
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let isPremium = userDefaults?.bool(forKey: "widget_is_premium") ?? false
        if isPremium {
            return allEntities
        }

        let defaultListID = userDefaults?.string(forKey: "widget_current_shopping_list_id")
        if let defaultListID,
           let matched = allEntities.first(where: { $0.id == defaultListID }) {
            return [matched]
        }
        if let first = allEntities.first {
            return [first]
        }
        return []
    }

    private func loadAllEntities() async -> [ShoppingListEntity] {
        #if WIDGET_EXTENSION
        let firestoreEntities = await fetchFirestoreShoppingLists()
        if !firestoreEntities.isEmpty {
            return firestoreEntities
        }
        #endif
        // フォールバック: UserDefaults
        return loadEntitiesFromUserDefaults()
    }

    private func loadEntitiesFromUserDefaults() -> [ShoppingListEntity] {
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
