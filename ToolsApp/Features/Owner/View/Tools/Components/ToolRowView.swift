import SwiftUI

struct ToolRowView: View {
    let tool: Tools

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: tool.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(tool.toolName)
                    .font(.headline)

                Text(tool.toolCategory)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Available: \(tool.availableQuantity)")
                    Text("Total: \(tool.totalQuantity)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            if tool.isExpensive.uppercased() == "YES" {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 8)
    }
}
