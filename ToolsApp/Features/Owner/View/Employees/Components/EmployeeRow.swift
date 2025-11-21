import SwiftUI

struct EmployeeRow: View {
    let employee: Employee

    var body: some View {
        HStack(spacing: 12) {

            if let imgPath = employee.img, !imgPath.isEmpty {
                AsyncImage(url: URL(string: imgPath)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(employee.username.displayName)
                    .font(.headline)
                Text(employee.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    Text(employee.role.displayName)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(roleColor(role: employee.role))
                        .clipShape(Capsule())

                    Text(employee.status.capitalized)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(status: employee.status))
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding()
    }

    private func roleColor(role: String) -> Color {
        switch role.lowercased() {
        case "admin": return .purple
        case "chief_supervisor": return .blue
        case "worker": return .green
        default: return .gray
        }
    }

    private func statusColor(status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        default: return .gray
        }
    }
}
