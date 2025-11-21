import SwiftUI

struct FactoryRowView: View {
    let factory: Factory

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(factory.name).font(.headline)
                Text(factory.city).font(.subheadline).foregroundColor(
                    .secondary
                )
                if let plantHead = factory.plantHead {
                    Text("Manager: \(plantHead.username)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(factory.status)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    factory.status == "ACTIVE"
                        ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
                )
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}
