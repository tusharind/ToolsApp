import SwiftUI

struct RestockRequestRow: View {
    let request: RestockRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(request.productName.capitalized)
                    .font(.headline)

                Spacer()

                Text("Qty: \(request.qtyRequested)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Text("Factory: \(request.factoryName)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Text("Factory Stock: \(request.currentFactoryStock)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("CO Stock: \(request.centralOfficeStock)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Created: \(request.createdAt.formattedDate())")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack {
                Spacer()

                Text(request.status)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor(for: request.status).opacity(0.15))
                    .foregroundColor(statusColor(for: request.status))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }

    func statusColor(for status: String) -> Color {
        switch status.uppercased() {
        case "PENDING": return .orange
        case "APPROVED": return .green
        case "REJECTED": return .red
        default: return .gray
        }
    }
}
