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

                // MARK: - Plant Head Info
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

                // MARK: - Toggle Button
                Button {
                    showConfirmation = true
                } label: {
                    Text(
                        isProcessing
                            ? (factory.status == "ACTIVE"
                                ? "Deactivating..."
                                : "Activating...")
                            : (factory.status == "ACTIVE"
                                ? "Deactivate Factory"
                                : "Activate Factory")
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        factory.status == "ACTIVE"
                            ? Color.red.opacity(0.2)
                            : Color.green.opacity(0.2)
                    )
                    .foregroundColor(
                        factory.status == "ACTIVE" ? .red : .green
                    )
                    .cornerRadius(12)
                    .bold()
                }
                .disabled(isProcessing)
                .padding(.top)
                .confirmationDialog(
                    factory.status == "ACTIVE"
                        ? "Are you sure you want to deactivate this factory?"
                        : "Are you sure you want to activate this factory?",
                    isPresented: $showConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(
                        factory.status == "ACTIVE"
                            ? "Yes, Deactivate"
                            : "Yes, Activate",
                        role: .destructive
                    ) {
                        Task { await toggleStatus() }
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

    // MARK: - Action
    private func toggleStatus() async {
        isProcessing = true
        let success = await viewModel.toggleFactoryStatus(id: factory.factoryId)
        isProcessing = false

        alertMessage = AlertMessage(
            message: success
                ? (viewModel.errorMessage ?? "Factory status toggled successfully")
                : (viewModel.errorMessage ?? "Failed to toggle factory status")
        )
    }
}

