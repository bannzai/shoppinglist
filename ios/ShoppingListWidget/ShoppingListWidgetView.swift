import SwiftUI
import WidgetKit

struct ShoppingListWidgetView: View {
    let entry: ShoppingListEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.shoppingListName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.bottom, 2)

            if entry.items.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("アイテムがありません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                Spacer()
            } else {
                let maxItems = maxItemCount
                ForEach(Array(entry.items.prefix(maxItems))) { item in
                    ShoppingListItemRow(item: item)
                }
                if entry.items.count > maxItems {
                    Text("他 \(entry.items.count - maxItems) 件")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 4)
    }

    private var maxItemCount: Int {
        switch widgetFamily {
        case .systemSmall: return 4
        case .systemMedium: return 4
        case .systemLarge: return 10
        default: return 4
        }
    }
}

struct ShoppingListItemRow: View {
    let item: ShoppingListItemData

    var body: some View {
        Button(intent: ToggleItemIntent(
            groupID: item.groupID,
            shoppingListID: item.shoppingListID,
            itemID: item.id,
            currentStatus: item.status
        )) {
            HStack(spacing: 6) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(item.isChecked ? .green : .secondary)

                Text(item.message)
                    .font(.subheadline)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                    .lineLimit(1)

                Spacer()

                if let color = item.color, !color.isEmpty {
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
