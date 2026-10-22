import SwiftUI
import WidgetKit

// 朱（5 色プリセットのデフォルト）。Flutter 側 AccentPreset.shu と一致。
private let defaultThemeColorHex = "#C2410C"

/// プレミアムで切り替え可能な 5 色プリセット（朱 / 抹茶 / 藍 / 墨 / 朽葉）の HEX。
/// Flutter 側 AccentPreset の persistHex と同期させること。
private let supportedThemeColorHexes: Set<String> = [
    "#C2410C", // 朱
    "#1F6B4E", // 抹茶
    "#0F4C81", // 藍
    "#1B1B1B", // 墨
    "#B45309", // 朽葉
]

struct ShoppingListEntry: TimelineEntry {
    let date: Date
    /// アイテムを取得したリストの groupID。トグルの書き込み先はこれと shoppingListID から組み立てる。
    let groupID: String
    /// アイテムを取得したリストの ID。
    let shoppingListID: String
    let shoppingListName: String
    let items: [ShoppingListItemData]
    let showCheckedItems: Bool
    /// ウィジェットのアクセントカラー。無料ユーザーは常にデフォルト色。
    let themeColorHex: String
    /// 完了済みアイテム数 / 全アイテム数（progress sliver / mono done/total 表示用）。
    let doneCount: Int
    let totalCount: Int
}

struct ShoppingListItemData: Identifiable, Codable {
    let id: String
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
            groupID: "",
            shoppingListID: "",
            shoppingListName: "買い物リスト",
            items: [
                ShoppingListItemData(id: "1", message: "牛乳", status: "unchecked", order: 0, color: nil),
                ShoppingListItemData(id: "2", message: "卵", status: "checked", order: 1, color: nil),
            ],
            showCheckedItems: true,
            themeColorHex: defaultThemeColorHex,
            doneCount: 1,
            totalCount: 2
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
        let userDefaults = UserDefaults(suiteName: widgetAppGroupId)
        let isPremium = userDefaults?.bool(forKey: "widget_is_premium") ?? false

        let syncedThemeColorHex = normalizeThemeColorHex(userDefaults?.string(forKey: "widget_theme_color_hex"))
        let themeColorHex = isPremium ? syncedThemeColorHex : defaultThemeColorHex

        let groupID: String
        let shoppingListID: String
        let shoppingListName: String

        if isPremium, let selectedList = configuration.shoppingList {
            groupID = selectedList.groupID
            shoppingListID = selectedList.id
            shoppingListName = selectedList.name
        } else {
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

        // done/total は filter 前の全アイテムで計算する（progress sliver と mono 表記用）。
        let totalCount = items.count
        let doneCount = items.filter { $0.isChecked }.count

        if !showChecked {
            items = items.filter { !$0.isChecked }
        }

        return ShoppingListEntry(
            date: Date(),
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListName: shoppingListName,
            items: items,
            showCheckedItems: showChecked,
            themeColorHex: themeColorHex,
            doneCount: doneCount,
            totalCount: totalCount
        )
    }

    /// HEX値を正規化する。フォーマット不正値・5 色プリセット外（旧 10 色含む）はデフォルトカラーにフォールバックする。
    private func normalizeThemeColorHex(_ value: String?) -> String {
        guard let value else { return defaultThemeColorHex }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard trimmed.range(of: "^#([0-9A-F]{6}|[0-9A-F]{8})$", options: .regularExpression) != nil else {
            return defaultThemeColorHex
        }
        return supportedThemeColorHexes.contains(trimmed) ? trimmed : defaultThemeColorHex
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
