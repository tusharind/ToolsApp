import SwiftUI

struct ManagerCardView: View {
    let manager: Manager
    var onDelete: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 12) {
                profileImage
                managerInfo
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .padding(.horizontal)

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(6)
                }
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 2)
                .padding(8)
            }
        }
    }

    private var profileImage: some View {
        Group {
            if let urlString = manager.profileImage ?? manager.img,
                let url = URL(string: urlString)
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    case .failure:
                        defaultImage
                    @unknown default:
                        defaultImage
                    }
                }
            } else {
                defaultImage
            }
        }
    }

    private var defaultImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(.gray)
    }

    private var managerInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(manager.username)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Text(manager.status.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
            }

            Text(manager.email)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.tail)

            if let factoryName = manager.factoryName {
                Text("Factory: \(factoryName)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(6)
            }
        }
    }

    private var statusColor: Color {
        switch manager.status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }
}
