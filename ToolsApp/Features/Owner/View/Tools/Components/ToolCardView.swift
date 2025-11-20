import SwiftUI

struct ToolCardView: View {
    let tool: ToolItem
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ToolImageView(url: tool.imageUrl)
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(tool.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(tool.categoryName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                FlexibleBadgeView(tool: tool)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
    }
}
