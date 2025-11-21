import SwiftUI

struct OfficerRowView: View {
    let officer: CentralOfficer
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ProfileImageView(urlString: officer.img)

            VStack(alignment: .leading, spacing: 4) {
                Text(officer.username)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(officer.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if let phone = officer.phone {
                    Text(phone)
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Text("Status: \(officer.status)")
                    .font(.caption2)
                    .foregroundColor(statusColor(officer.status))
                    .padding(4)
                    .background(statusColor(officer.status).opacity(0.2))
                    .cornerRadius(4)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }

    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }
}
