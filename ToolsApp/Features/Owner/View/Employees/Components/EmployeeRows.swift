import SwiftUI

struct EmployeeRow: View {
    let employee: Employee
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(employee.username)
                    .font(.headline)
                Text(employee.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Role: \(employee.role), Status: \(employee.status)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundColor(.gray)
        }
        .padding()
    }
}

func statusColor(_ status: String) -> Color {
    switch status.lowercased() {
    case "active": return .green
    case "inactive": return .red
    case "pending": return .orange
    default: return .blue
    }
}
