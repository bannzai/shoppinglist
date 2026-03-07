import SwiftUI
import WidgetKit

struct ShoppingListEntry: TimelineEntry {
    let date: Date
    let shoppingListName: String
    let items: [ShoppingListItemData]
    let showCheckedItems: Bool
}

struct ShoppingListItemData: Identifiable, Codable {
    let id: String
    let groupID: String
    let shoppingListID: String
    let message: String
    var status: String
    let order: Int
    let color: String?

    var isChecked: Bool {
        status == "checked"
    }
}

struct Provider: AppIntentTimelineProvider {
    typealias Entry = ShoppingListEntry
    typealias Intent = ShoppingListConfigurationIntent

    func placeholder(in context: Context) -> ShoppingListEntry {
        ShoppingListEntry(
            date: Date(),
            shoppingListName: "買い物リスト",
            items: [
                ShoppingListItemData(id: "1", groupID: "", shoppingListID: "", message: "牛乳", status: "unchecked", order: 0, color: nil),
                ShoppingListItemData(id: "2", groupID: "", shoppingListID: "", message: "卵", status: "checked", order: 1, color: nil),
            ],
            showCheckedItems: true
        )
    }

    func snapshot(for configuration: ShoppingListConfigurationIntent, in context: Context) async -> ShoppingListEntry {
        await loadEntry(for: configuration)
    }

    func timeline(for configuration: ShoppingListConfigurationIntent, in context: Context) async -> Timeline<ShoppingListEntry> {
        let entry = await loadEntry(for: configuration)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func loadEntry(for configuration: ShoppingListConfigurationIntent) async -> ShoppingListEntry {
        let showChecked = configuration.showCheckedItems

        let groupID: String
        let shoppingListID: String
        let shoppingListName: String

        if let selectedList = configuration.shoppingList {
            groupID = selectedList.groupID
            shoppingListID = selectedList.id
            shoppingListName = selectedList.name
        } else {
            let userDefaults = UserDefaults(suiteName: widgetAppGroupId)
            groupID = userDefaults?.string(forKey: "widget_current_group_id") ?? ""
            shoppingListID = userDefaults?.string(forKey: "widget_current_shopping_list_id") ?? ""
            shoppingListName = userDefaults?.string(forKey: "widget_current_shopping_list_name") ?? "買い物リスト"
        }

        // Firestore から直接取得
        var items = await fetchFirestoreItems(groupID: groupID, shoppingListID: shoppingListID)

        // フォールバック: Firestore 失敗時は UserDefaults から読み込み
        if items.isEmpty {
            items = loadItemsFromUserDefaults(groupID: groupID, shoppingListID: shoppingListID)
        }

        if !showChecked {
            items = items.filter { !$0.isChecked }
        }

        return ShoppingListEntry(
            date: Date(),
            shoppingListName: shoppingListName,
            items: items,
            showCheckedItems: showChecked
        )
    }

    private func loadItemsFromUserDefaults(groupID: String, shoppingListID: String) -> [ShoppingListItemData] {
        let userDefaults = UserDefaults(suiteName: widgetAppGroupId)
        let key = "widget_items_\(groupID)_\(shoppingListID)"
        guard let jsonString = userDefaults?.string(forKey: key),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        do {
            return try JSONDecoder().decode([ShoppingListItemData].self, from: data)
        } catch {
            return []
        }
    }
}

struct ShoppingListWidget: Widget {
    let kind: String = "ShoppingListWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ShoppingListConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            ShoppingListWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("買い物リスト")
        .description("買い物リストのアイテムを確認・チェックできます")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
