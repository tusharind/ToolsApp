import SwiftUI

struct FactoryDetailView: View {
    let factory: Factory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Factory Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(factory.name)
                        .font(.title2.bold())

                    HStack {
                        Label(factory.city, systemImage: "mappin.and.ellipse")
                        Label(factory.address, systemImage: "house.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    HStack {
                        Text("Status: \(factory.status)")
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                factory.status == "ACTIVE"
                                    ? .green.opacity(0.2) : .red.opacity(0.2)
                            )
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // MARK: - Plant Head Info
                if let head = factory.plantHead {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Plant Head")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(head.username)
                                .font(.subheadline.bold())
                            Text("Email: \(head.email)")
                            Text("Phone: \(head.phone)")
                            Text("Role: \(head.role)")
                            Text("Status: \(head.status)")
                        }
                        .font(.footnote)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                } else {
                    Text("No Plant Head assigned.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Factory Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
