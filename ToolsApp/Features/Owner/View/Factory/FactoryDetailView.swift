import SwiftUI

struct FactoryDetailView: View {
    let factory: Factory
    @ObservedObject var viewModel: FactoryViewModel

    @State private var showConfirmation = false
    @State private var showManagerPicker = false
    @State private var selectedManagerId: Int?
    @State private var managerSearchText: String = ""
    @State private var isProcessing = false
    @State private var alertMessage: AlertMessage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

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
                    .cornerRadius(12)
                } else {
                    Text("No Plant Head assigned.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Assign / Change Manager")
                        .font(.headline)

                    Button {
                        Task {
                            await viewModel.fetchAvailableManagers()
                            selectedManagerId = factory.plantHead?.id
                            withAnimation { showManagerPicker.toggle() }
                        }
                    } label: {
                        HStack {
                            Text(
                                viewModel.availableManagers.first(where: {
                                    $0.id == selectedManagerId
                                })?.username ?? factory.plantHead?.username
                                    ?? "Select Manager"
                            )
                            Spacer()
                            Image(
                                systemName: showManagerPicker
                                    ? "chevron.up" : "chevron.down"
                            )
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    if showManagerPicker {
                        VStack(spacing: 4) {
                            TextField(
                                "Search manager",
                                text: $managerSearchText
                            )
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: managerSearchText) { _,query in
                                Task {
                                    await viewModel.searchManagers(query: query)
                                }
                            }
                            .padding(.horizontal)

                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.availableManagers) {
                                        manager in
                                        HStack {
                                            Text(
                                                "\(manager.username) id:\(manager.id)"
                                            )
                                            .padding(.vertical, 8)
                                            Spacer()
                                            if selectedManagerId == manager.id {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation {
                                                selectedManagerId = manager.id
                                            }
                                        }
                                        Divider()
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding(.vertical, 4)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2))
                        )

                        if let managerId = selectedManagerId {
                            Button("Assign Manager") {
                                Task {
                                    await assignManager(managerId: managerId)
                                }
                                withAnimation { showManagerPicker = false }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.top, 4)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

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

    private func toggleStatus() async {
        isProcessing = true
        let success = await viewModel.toggleFactoryStatus(id: factory.factoryId)
        isProcessing = false

        alertMessage = AlertMessage(
            message: success
                ? (viewModel.errorMessage
                    ?? "Factory status toggled successfully")
                : (viewModel.errorMessage ?? "Failed to toggle factory status")
        )
    }

    private func assignManager(managerId: Int) async {
        isProcessing = true
        let success = await viewModel.updateFactoryManager(
            factoryId: factory.factoryId,
            managerId: managerId
        )
        isProcessing = false

        alertMessage = AlertMessage(
            message: success
                ? (viewModel.errorMessage ?? "Manager assigned successfully")
                : (viewModel.errorMessage ?? "Failed to assign manager")
        )
    }
}
