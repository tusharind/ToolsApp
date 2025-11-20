import SwiftUI

struct ProductRowCard: View {
    let product: Product
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {

                if let urlString = product.image,
                    let url = URL(string: urlString)
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: ProgressView()
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure: placeholderImage
                        @unknown default: placeholderImage
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderImage
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.headline)
                    if !product.prodDescription.isEmpty {
                        Text(product.prodDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(product.categoryName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    HStack {
                        Text("₹\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text("\(product.rewardPts) pts")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Spacer()
                        Text(product.status.capitalized)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                product.status.lowercased() == "active"
                                    ? Color.green
                                    : Color.red
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                    }
                }
                Spacer()
            }

            HStack(spacing: 40) {
                Spacer()
                Button {
                    onEdit()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .foregroundColor(.green)
                }
                Button {
                    onDelete()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .foregroundColor(.red)
                }
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            )
    }
}
