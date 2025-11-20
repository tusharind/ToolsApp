import SwiftUI

struct CategoryRowView: View {
    let category: CategoryName
    var onEdit: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text(category.categoryName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(category.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "cube.box")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Products: \(category.productCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )

            if let onEdit = onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(10)
                }
                .padding(8)
            }
        }
        .padding(.horizontal, 8)
    }
}
