import SwiftUI

struct FactoryDetailView: View {
    let factory: Factory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Factory Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(factory.name).font(.title2.bold())
                    HStack {
                        Label(factory.city, systemImage: "mappin.and.ellipse")
                        Label(factory.address, systemImage: "house.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Text("Status: \(factory.status)")
                        .font(.footnote)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(factory.status == "ACTIVE" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Plant Head
                if let head = factory.plantHead {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Plant Head").font(.headline)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(head.username).bold()
                            Text("Email: \(head.email)")
                            Text("Phone: \(head.phone)")
                            Text("Role: \(head.role)")
                            Text("Status: \(head.status)")
                        }
                        .font(.footnote)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                } else {
                    Text("No Plant Head assigned.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Factory Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

