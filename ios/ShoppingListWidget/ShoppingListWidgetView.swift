import SwiftUI
import WidgetKit

/// `design_handoff_shoppinglist/preview/widgets-and-micro.jsx` 準拠の iOS Widget UI。
///
/// 仕様:
/// - 左上: 18×18 accent 四角 + cart icon、リスト名 11.5pt
/// - 右上: done/total を IBM Plex Mono 11.5pt（システム mono で代替）
/// - 各行: 14×14 checkbox + アイテム名 11.5pt + 5×5 cat color dot
/// - 底: 2.5px progress sliver（accent / accent 0.15）
struct ShoppingListWidgetView: View {
    let entry: ShoppingListEntry

    @Environment(\.widgetFamily) var widgetFamily
    // i-14 dark mode cross-fade に追従するための明示 colorScheme。
    // `design_handoff_shoppinglist/preview/widgets-and-micro.jsx` の WiOS (light/dark) 準拠。
    @Environment(\.colorScheme) var colorScheme

    private var themeColor: Color {
        Color(hex: entry.themeColorHex)
    }

    /// 和紙ベース背景。tokens.dart の AppNeutralColors.{light,dark}.paper と一致。
    private var paper: Color {
        colorScheme == .dark
            ? Color(hex: "#13110D")
            : Color(hex: "#F1EDE4")
    }

    /// card 背景 (現状は未使用だが、今後の Light/Dark 統一のためプロパティとして保持)。
    /// tokens.dart の AppNeutralColors.{light,dark}.card と一致。
    private var card: Color {
        colorScheme == .dark
            ? Color(hex: "#26221C")
            : Color(hex: "#FFFFFF")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            if entry.items.isEmpty {
                emptyBody
            } else {
                itemsBody
            }
            progressSliver
        }
        .padding(.vertical, 4)
        .containerBackground(paper, for: .widget)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeColor)
                    .frame(width: 18, height: 18)
                Image(systemName: "cart.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(entry.shoppingListName)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer()
            Text("\(entry.doneCount)/\(entry.totalCount)")
                .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Body

    private var emptyBody: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("アイテムがありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Spacer()
        }
    }

    private var itemsBody: some View {
        let maxItems = maxItemCount
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(entry.items.prefix(maxItems))) { item in
                ShoppingListItemRow(item: item, accent: themeColor)
            }
            if entry.items.count > maxItems {
                Text("他 \(entry.items.count - maxItems) 件")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: Progress sliver (2.5px)

    private var progressSliver: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(themeColor.opacity(0.15))
                    .frame(height: 2.5)
                Rectangle()
                    .fill(themeColor)
                    .frame(width: geo.size.width * progressRatio, height: 2.5)
            }
        }
        .frame(height: 2.5)
    }

    private var progressRatio: CGFloat {
        guard entry.totalCount > 0 else { return 0 }
        return CGFloat(entry.doneCount) / CGFloat(entry.totalCount)
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
    let accent: Color

    var body: some View {
        Button(intent: ToggleItemIntent(
            groupID: item.groupID,
            shoppingListID: item.shoppingListID,
            itemID: item.id,
            currentStatus: item.status
        )) {
            HStack(spacing: 6) {
                checkboxView
                Text(item.message)
                    .font(.system(size: 11.5))
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                    .lineLimit(1)
                Spacer()
                if let color = item.color, !color.isEmpty {
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 5, height: 5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var checkboxView: some View {
        ZStack {
            Circle()
                .stroke(item.isChecked ? accent : Color.secondary, lineWidth: 1.4)
                .frame(width: 14, height: 14)
            if item.isChecked {
                Circle()
                    .fill(accent)
                    .frame(width: 14, height: 14)
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
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
