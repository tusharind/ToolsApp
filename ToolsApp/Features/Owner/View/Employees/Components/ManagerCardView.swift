struct ManagerCardView: View {
    let manager: Manager

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            if let imgUrl = manager.profileImage ?? manager.img,
                let url = URL(string: imgUrl)
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(manager.username)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    Text(manager.status)
                        .font(.caption)
                        .padding(4)
                        .background(statusColor(manager.status).opacity(0.2))
                        .foregroundColor(statusColor(manager.status))
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
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange)
                                .shadow(
                                    color: Color.orange.opacity(0.4),
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                        )
                }

            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
}
