import SwiftUI

struct ProductCard: View {
    let product: Product
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.name)
                .font(.headline)

            Text("₹\(product.price, specifier: "%.2f")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 150, height: 90)
        .background(
            isSelected ? Color.green.opacity(0.2) : Color.gray.opacity(0.1)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case id, name, quantity, totalReceived
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .id: return "ID"
        case .name: return "Name"
        case .quantity: return "Quantity"
        case .totalReceived: return "Total Received"
        }
    }
}
