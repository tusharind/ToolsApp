import SwiftUI

struct ProductRowSection: View {
    let product: Product
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Image
            if let imageUrl = product.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name).font(.headline)
                let category = product.categoryName
                Text(category).font(.subheadline).foregroundColor(.gray)
                let description = product.prodDescription.description
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)

            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
