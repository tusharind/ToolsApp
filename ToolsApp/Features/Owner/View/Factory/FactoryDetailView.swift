import SwiftUI

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct FactoryDetailView: View {
    let factory: Factory
    @ObservedObject var viewModel: FactoryViewModel

    @State private var showConfirmation = false
    @State private var isProcessing = false
    @State private var alertMessage: AlertMessage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

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
                        .background(
                            factory.status == "ACTIVE"
                                ? Color.green.opacity(0.2)
                                : Color.red.opacity(0.2)
                        )
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

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

                Button(role: .destructive) {
                    showConfirmation = true
                } label: {
                    Text(
                        isProcessing ? "Deactivating..." : "Deactivate Factory"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .bold()
                }
                .disabled(isProcessing)
                .padding(.top)
                .confirmationDialog(
                    "Are you sure you want to deactivate this factory?",
                    isPresented: $showConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Yes, Deactivate", role: .destructive) {
                        Task { await deactivateFactory() }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .padding()
        }
        .navigationTitle("Factory Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $alertMessage) { alert in
            Alert(
                title: Text("Info"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func deactivateFactory() async {
        isProcessing = true
        let success = await viewModel.deactivateFactory(id: factory.factoryId)
        isProcessing = false
        alertMessage = AlertMessage(
            message: success
                ? "Factory deactivated successfully"
                : (viewModel.errorMessage ?? "Unknown error")
        )
    }
}
