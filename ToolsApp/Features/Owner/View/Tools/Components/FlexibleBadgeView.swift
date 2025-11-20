import SwiftUI

struct FlexibleBadgeView: View {
    let tool: ToolItem

    var formattedType: String {
        switch tool.type {
        case "NOT_PERISHABLE":
            return "Reusable"
        default:
            return tool.type.replacingOccurrences(of: "_", with: " ")
        }
    }

    var badges: [(String, Color)] {
        [
            (formattedType, .purple.opacity(0.6)),
            (
                "Threshold: \(tool.threshold)",
                (tool.threshold < 20 ? Color.red : Color.green).opacity(0.6)
            ),
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(badges, id: \.0) { text, color in
                    Text(text)
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.2))
                        .foregroundColor(color.opacity(0.8))
                        .cornerRadius(8)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .padding(.top, 4)
    }
}
